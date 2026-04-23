-- Tracks the engine's world camera. Subscribes to Events.CameraViewChanged,
-- which the events catalog claims is no-arg but actually fires with a 4x4
-- row-major view matrix every frame the camera animates. The matrix's bottom
-- row is the world-to-camera translation; inverting it (eye = -t * R^T)
-- gives the eye world position, then we cast a ray through the camera's
-- forward axis to the Z=0 ground plane to get the look-at point.
--
-- Why this matters: the engine's notification activate path (default branch
-- in CvNotifications::Activate) calls lookAt(plot) directly in C++ for
-- camera-only notifications (NOTIFICATION_GOODY, BARBARIAN, ENEMY_*, WAR,
-- etc). No Lua-observable selection event fires, no plot accessor exists on
-- the notification record, and there's no UI.GetMapCenter. CameraViewChanged
-- is the only signal that survives back into Lua, and the matrix it carries
-- is the only way to recover where the camera ended up.
--
-- World <-> grid math is hex-offset: row Y has X stride 64, alternating
-- rows offset by 32. World origin (the world-space coords of grid (0,0))
-- and per-grid strides are read once at install via HexToWorld so the same
-- code works across map sizes.
--
-- followNextSettle(callback) installs a tick poller that waits for the
-- camera to move and then settle (no CameraViewChanged for SETTLE_FRAMES),
-- computes the look-at, and fires callback(gx, gy). Used by notification
-- activate to jump the cursor onto whatever the engine pans to.

CameraTracker = {}

local SETTLE_FRAMES = 8
local MAX_WAIT_FRAMES = 120

local function readOriginAndStride()
    -- Vector2 lives in FLuaVector, pulled in only by IconSupport-using files;
    -- HexToWorld accepts the bare {x,y} table shape FLuaVector itself uses.
    local w00 = HexToWorld(ToHexFromGrid({ x = 0, y = 0 }))
    local w10 = HexToWorld(ToHexFromGrid({ x = 1, y = 0 }))
    -- Rows 0 and 2 share parity, so their Y delta is 2x the per-row stride.
    local w02 = HexToWorld(ToHexFromGrid({ x = 0, y = 2 }))
    civvaccess_shared.cameraOriginX = w00.x
    civvaccess_shared.cameraOriginY = w00.y
    civvaccess_shared.cameraStrideX = w10.x - w00.x
    civvaccess_shared.cameraStrideY = (w02.y - w00.y) / 2
end

local function onCameraViewChanged(matrix)
    civvaccess_shared.cameraMatrix = matrix
    civvaccess_shared.cameraMatrixFrame = TickPump.frame()
end

function CameraTracker.install()
    -- Origin and stride are map-layout-constant within a game but can change
    -- across games in the same lua_State (different map size). Re-read on
    -- every install; the listener-subscribe below is the only part the
    -- cross-Context idempotency guard needs to protect.
    readOriginAndStride()
    if civvaccess_shared.cameraTrackerInstalled then
        return
    end
    civvaccess_shared.cameraTrackerInstalled = true
    Events.CameraViewChanged.Add(onCameraViewChanged)
    Log.info(
        "CameraTracker: installed, origin=("
        .. tostring(civvaccess_shared.cameraOriginX) .. ", "
        .. tostring(civvaccess_shared.cameraOriginY) .. ") stride=("
        .. tostring(civvaccess_shared.cameraStrideX) .. ", "
        .. tostring(civvaccess_shared.cameraStrideY) .. ")"
    )
end

-- Compute look-at grid coords from a stored matrix. Returns nil if the
-- matrix isn't usable (no fires yet, malformed, camera looking away from
-- the ground plane).
function CameraTracker.getLookAtGrid()
    local m = civvaccess_shared.cameraMatrix
    if m == nil then
        return nil, nil
    end
    local r1, r2, r3, t = m[1], m[2], m[3], m[4]
    if r1 == nil or r2 == nil or r3 == nil or t == nil then
        return nil, nil
    end
    -- eye_world = -t * R^T. With R rows = r1, r2, r3, then
    -- eye[j] = -sum_k(t[k] * R[j][k]) = -(t[1]*r_j[1] + t[2]*r_j[2] + t[3]*r_j[3]).
    local eye_x = -(t[1] * r1[1] + t[2] * r1[2] + t[3] * r1[3])
    local eye_y = -(t[1] * r2[1] + t[2] * r2[2] + t[3] * r2[3])
    local eye_z = -(t[1] * r3[1] + t[2] * r3[2] + t[3] * r3[3])
    -- Forward in world = R[2], not the OpenGL-standard -R[3]. Civ V's
    -- view matrix lays the rotation out as right / forward / up rather
    -- than right / up / -forward. Verified empirically: with R[2]'s
    -- (0, +sqrt(2)/2, -sqrt(2)/2) the projected look-at lands on the
    -- correct plot; -R[3]'s (0, -sqrt(2)/2, -sqrt(2)/2) lands ~15 plots
    -- south of it (the camera ends up "looking" the wrong way along Y).
    local fwd_x, fwd_y, fwd_z = r2[1], r2[2], r2[3]
    if fwd_z == 0 then
        return nil, nil
    end
    -- Project ray to ground plane Z=0.
    local k = -eye_z / fwd_z
    if k <= 0 then
        return nil, nil
    end
    local lookat_x = eye_x + k * fwd_x
    local lookat_y = eye_y + k * fwd_y
    -- World -> grid inverse of the HexToWorld mapping derived empirically:
    --   world.y = grid.y * strideY + originY
    --   world.x = grid.x * strideX + (grid.y % 2) * (strideX / 2) + originX
    local strideX = civvaccess_shared.cameraStrideX
    local strideY = civvaccess_shared.cameraStrideY
    local originX = civvaccess_shared.cameraOriginX
    local originY = civvaccess_shared.cameraOriginY
    if strideX == nil or strideY == nil then
        return nil, nil
    end
    local gy = math.floor((lookat_y - originY) / strideY + 0.5)
    local gx = math.floor((lookat_x - originX - (gy % 2) * (strideX / 2)) / strideX + 0.5)
    return gx, gy
end

-- Convenience wrapper around followNextSettle: drop the cursor on the
-- settled camera target and queue the destination plot announcement.
-- Cursor lives in InGame Context only; reach it via the shared modules
-- table that Boot publishes. SpeechPipeline is per-Context, so the
-- caller must have included it.
function CameraTracker.followAndJumpCursor()
    CameraTracker.followNextSettle(function(gx, gy)
        local Cursor = civvaccess_shared.modules and civvaccess_shared.modules.Cursor
        if Cursor == nil then
            Log.warn("CameraTracker.followAndJumpCursor: Cursor module not published")
            return
        end
        local text = Cursor.jumpTo(gx, gy)
        if text ~= nil and text ~= "" then
            -- Queued so a notification's own announcement (already spoken
            -- via NotificationAnnounce) doesn't get clobbered.
            SpeechPipeline.speakQueued(text)
        end
    end)
end

-- Wait for the camera to (a) start moving since we were called and (b)
-- settle, then fire callback(gx, gy). Times out silently if the camera
-- never moves -- common for notifications that open a popup instead of
-- panning (NOTIFICATION_PRODUCTION, NOTIFICATION_TECH, diplomacy ones).
--
-- Two followers racing: if a second follower registers while the first is
-- still waiting, the later follower's pan would satisfy the first's
-- "cameraMoved" gate, firing its callback with the second pan's matrix.
-- Each follower captures a generation stamp; a newer call supersedes it.
function CameraTracker.followNextSettle(callback)
    local gen = (civvaccess_shared.followGeneration or 0) + 1
    civvaccess_shared.followGeneration = gen
    local startFrame = TickPump.frame()
    local function check()
        if civvaccess_shared.followGeneration ~= gen then
            return
        end
        local lastFire = civvaccess_shared.cameraMatrixFrame or -1
        local elapsed = TickPump.frame() - startFrame
        local cameraMoved = lastFire >= startFrame
        if cameraMoved and (TickPump.frame() - lastFire >= SETTLE_FRAMES) then
            local gx, gy = CameraTracker.getLookAtGrid()
            if gx ~= nil then
                local ok, err = pcall(callback, gx, gy)
                if not ok then
                    Log.error("CameraTracker followNextSettle callback failed: " .. tostring(err))
                end
            else
                Log.warn("CameraTracker followNextSettle: getLookAtGrid returned nil after settle")
            end
            return
        end
        if elapsed >= MAX_WAIT_FRAMES then
            return
        end
        TickPump.runOnce(check)
    end
    TickPump.runOnce(check)
end

function CameraTracker._reset()
    if civvaccess_shared ~= nil then
        civvaccess_shared.cameraTrackerInstalled = nil
        civvaccess_shared.cameraMatrix = nil
        civvaccess_shared.cameraMatrixFrame = nil
        civvaccess_shared.cameraOriginX = nil
        civvaccess_shared.cameraOriginY = nil
        civvaccess_shared.cameraStrideX = nil
        civvaccess_shared.cameraStrideY = nil
        civvaccess_shared.followGeneration = nil
    end
end
