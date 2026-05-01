-- PremiumContentMenu accessibility wiring. Reached from MainMenu's "DLC"
-- button (ExpansionRulesSwitch). The base screen lists every installed
-- package (the two named expansions plus any individual DLC) and lets
-- the user toggle each row's enabled state; OK commits the diff via
-- ContentManager.SetActive, Back cancels.
--
-- Toggle shape: each row's "checked" state lives in g_DLCState[i].Active
-- as a Lua flag, pending until OK -- it isn't bound to any Controls
-- widget, so the existing BaseMenuItems.Checkbox (which reads
-- IsChecked() / writes SetCheck()) can't model it. The toggleItem helper
-- below builds items in the shape BaseMenu duck-types on. Local to this
-- screen on purpose; promote to a shared factory only when a second
-- screen needs the same shape. We don't mirror the base's SetHide on
-- the Enable/Disable buttons -- visuals are irrelevant to the user, and
-- OnOK reads g_DLCState rather than the controls.
--
-- Dynamic rows: non-expansion DLC rows are rebuilt via InstanceManager
-- on every RefreshDLC. The base ShowHide calls RefreshDLC on each open,
-- so we wrap RefreshDLC to follow the base body with a setItems against
-- the fresh g_DLCState. ShowHideHandler resolves RefreshDLC at call
-- time, so reassigning the global takes effect on subsequent invocations.

include("CivVAccess_FrontendCommon")
include("CivVAccess_PickerReader")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

local function toggleItem(spec)
    local item = { kind = "toggle" }
    function item:isNavigable()
        return true
    end
    function item:isActivatable()
        return true
    end
    function item:announce(menu)
        local state = Text.key(spec.getFn() and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
        return spec.labelFn() .. ", " .. state
    end
    function item:activate(menu)
        spec.toggleFn()
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Each iteration's `entry` is a per-closure capture; after a RefreshDLC
-- rebuilds g_DLCState into fresh tables, the next buildItems call closes
-- over the new entries. OnOK reads g_DLCState directly, so toggling
-- entry.Active in place is what the commit path observes.
local function buildItems()
    local items = {}
    for _, entry in ipairs(g_DLCState) do
        items[#items + 1] = toggleItem({
            labelFn = function()
                return entry.Description
            end,
            getFn = function()
                return entry.Active
            end,
            toggleFn = function()
                entry.Active = not entry.Active
            end,
        })
    end
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "LargeButton",
        textKey = "TXT_KEY_OK_BUTTON",
        activate = function()
            OnOK()
        end,
    })
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "BackButton",
        textKey = "TXT_KEY_MODDING_BACK",
        activate = function()
            OnCancel()
        end,
    })
    return items
end

local mainHandler
local function getHandler()
    return mainHandler
end

RefreshDLC = PickerReader.wrapRebuild(RefreshDLC, getHandler, buildItems)

mainHandler = BaseMenu.install(ContextPtr, {
    name = "PremiumContentMenu",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_PREMIUM_CONTENT"),
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    items = buildItems(),
})
