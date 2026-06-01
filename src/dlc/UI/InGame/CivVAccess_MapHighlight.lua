-- On-screen hex rings for sighted companions. Draws a ring on the cursor's
-- tile and another on the scanner's current target so a sighted partner can
-- see where the blind player's attention is. Purely visual: nothing here
-- speaks, and the feature is off-limits to no one -- it costs the blind
-- player nothing, so it ships on by default with an F12 Settings toggle.
--
-- Why these styles: the rings use TempBorder / EditorHexStyle1, two styles
-- defined in Assets/Overlays/Highlights.xml that no shipped Lua ever draws or
-- clears. BNW's InGame.lua / WorldView.lua never call the global
-- Events.ClearHexHighlights() (commented out, "other systems might be using
-- these!"); every clear is style-scoped over a fixed set that excludes ours.
-- So the engine never wipes these rings on unit select / interface-mode
-- change / city-screen exit, and we don't need any re-apply listener -- the
-- cursor ring is simply re-set on every cursor move. Each ring owns a
-- distinct style so clearScanner doesn't disturb the cursor ring. The per-
-- call Vector4 overrides whatever color the style declares in XML, exactly
-- as the base game tints GUHB many different colors.
--
-- Grid-to-hex uses ToHexFromGrid with the bare {x, y} table shape (not
-- Vector2) so we don't depend on FLuaVector being pulled in, matching
-- CameraTracker.

MapHighlight = {}

-- Cyan cursor, orange scanner: both are gaps in the game's hex-highlight
-- palette (green/yellow = movement, red = attack, magenta = trade), and the
-- warm/cool split keeps the two rings distinct from each other even under
-- red-green colorblindness. Full alpha so the rings read as crisp markers,
-- not the translucent zone-fills the game uses for gameplay overlays.
local CURSOR_STYLE = "TempBorder"
local SCANNER_STYLE = "EditorHexStyle1"
local CURSOR_COLOR = Vector4(0, 1, 1, 1)
local SCANNER_COLOR = Vector4(1, 0.5, 0, 1)

-- Seed the toggle on the shared table the first time we boot. Default on:
-- the rings are invisible to speech output, so there's no cost to the blind
-- player and every reason to leave them available for a sighted partner.
-- Settings.lua's defineBoolPref is a no-op once this has run; the front-end
-- Settings Context (where MapHighlight isn't loaded) seeds it there instead.
if civvaccess_shared.mapHighlightEnabled == nil then
    civvaccess_shared.mapHighlightEnabled = Prefs.getBool("MapHighlight", true)
end

local function enabled()
    return civvaccess_shared.mapHighlightEnabled == true
end

local function hexOf(x, y)
    return ToHexFromGrid({ x = x, y = y })
end

-- Move the cursor ring to (x, y). Clear-then-set on our private style: the
-- two fires composite within one Lua tick before the next frame, so there's
-- no flicker, and clearing the whole style first means we never leave a
-- ring behind on the previous tile.
function MapHighlight.setCursor(x, y)
    if not enabled() then
        return
    end
    Events.ClearHexHighlightStyle(CURSOR_STYLE)
    Events.SerialEventHexHighlight(hexOf(x, y), true, CURSOR_COLOR, CURSOR_STYLE)
end

-- Move the scanner ring to (x, y). No UI.LookAt: the scanner deliberately
-- never pans, so an off-screen target just isn't visible until the camera
-- happens to cover it.
function MapHighlight.setScanner(x, y)
    if not enabled() then
        return
    end
    Events.ClearHexHighlightStyle(SCANNER_STYLE)
    Events.SerialEventHexHighlight(hexOf(x, y), true, SCANNER_COLOR, SCANNER_STYLE)
end

-- Unconditional clears (no enabled() gate): used by applyEnabled to tear the
-- rings down when the user turns the feature off, where gating on the
-- now-false flag would skip the very clear we need.
function MapHighlight.clearCursor()
    Events.ClearHexHighlightStyle(CURSOR_STYLE)
end

function MapHighlight.clearScanner()
    Events.ClearHexHighlightStyle(SCANNER_STYLE)
end

function MapHighlight.clearAll()
    MapHighlight.clearCursor()
    MapHighlight.clearScanner()
end

-- React to a Settings toggle, reading the flag the toggle just wrote. Off:
-- tear both rings down now rather than waiting for them to stop being
-- re-set. On: redraw the cursor ring immediately so the user doesn't have
-- to move first to see it; the scanner ring reappears on the next scan.
function MapHighlight.applyEnabled()
    if not enabled() then
        MapHighlight.clearAll()
        return
    end
    local x, y = Cursor.position()
    if x ~= nil then
        MapHighlight.setCursor(x, y)
    end
end
