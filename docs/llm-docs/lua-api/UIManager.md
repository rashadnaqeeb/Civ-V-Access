# UIManager

Screen stack and input routing. Static table.

Extracted from 702 call sites across 18 distinct methods in the shipped game Lua.

## Methods

### DequeuePopup
- `UIManager:DequeuePopup(ContextPtr)`
- `UIManager:DequeuePopup(Controls.EmptyPopup)`
- 199 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:6227`

### GetAlt
- `UIManager:GetAlt()`
- 21 callsites. Example: `UI/InGame/InGame.lua:123`

### GetControl
- `UIManager:GetControl()`
- 9 callsites. Example: `UI/InGame/InGame.lua:83`

### GetMouseDelta
- `UIManager:GetMouseDelta()`
- 3 callsites. Example: `UI/InGame/PlotHelpManager.lua:25`

### GetNamedContextByIndex
- `UIManager:GetNamedContextByIndex("Advisors", i - 1)`
- 1 callsite. Example: `UI/InGame/Popups/AdvisorInfoPopup.lua:158`

### GetNamedContextCount
- `UIManager:GetNamedContextCount("Advisors")`
- 1 callsite. Example: `UI/InGame/Popups/AdvisorInfoPopup.lua:156`

### GetNumPointers
- `UIManager:GetNumPointers()`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:781`

### GetResCount
- `UIManager:GetResCount()`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:1520`

### GetResInfo
- `UIManager:GetResInfo(i)`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:1522`

### GetScreenSizeVal
- `UIManager:GetScreenSizeVal()`
- 37 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:110`

### GetShift
- `UIManager:GetShift()`
- 29 callsites. Example: `UI/InGame/InGame.lua:122`

### GetVisibleNamedContext
- `UIManager:GetVisibleNamedContext("StagingRoom")`
- 1 callsite. Example: `UI/FrontEnd/MainMenu.lua:270`

### IsModal
- `UIManager:IsModal(ContextPtr)`
- `UIManager:IsModal(g_AdvisorModal)`
- `UIManager:IsModal(Controls.ConsultPopup)`
- 4 callsites. Example: `UI/InGame/Menus/SaveMenu.lua:173`

### IsTopModal
- `UIManager:IsTopModal(advisorModal)`
- 1 callsite. Example: `UI/InGame/Popups/AdvisorInfoPopup.lua:160`

### PopModal
- `UIManager:PopModal(ContextPtr)`
- `UIManager:PopModal(Controls.DeleteConfirm)`
- `UIManager:PopModal(Controls.ConsultPopup)`
- `UIManager:PopModal(Controls.OptionsPopup)`
- 25 callsites. Example: `UI/FrontEnd/ExitConfirm.lua:18`

### PushModal
- `UIManager:PushModal(Controls.SetCivNames)`
- `UIManager:PushModal(Controls.DeleteConfirm)`
- `UIManager:PushModal(ContextPtr)`
- `UIManager:PushModal(Controls.ConfirmKick, true)`
- `UIManager:PushModal(Controls.ChangePassword, true)`
- ...and 5 more distinct call shapes
- 17 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1276`

### QueuePopup
- `UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)`
- `UIManager:QueuePopup(ContextPtr, PopupPriority.InGameUtmost)`
- `UIManager:QueuePopup(ContextPtr, PopupPriority.eUtmost)`
- `UIManager:QueuePopup(ContextPtr, PopupPriority.VictoryProgress)`
- `UIManager:QueuePopup(Controls.EmptyPopup, PopupPriority.GenericPopup+1)`
- ...and 77 more distinct call shapes
- 216 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:208`

### SetUICursor
- `UIManager:SetUICursor(1)`
- `UIManager:SetUICursor(0)`
- `UIManager:SetUICursor(oldCursor)`
- `UIManager:SetUICursor(cursorIndex)`
- `UIManager:SetUICursor(defaultCursor)`
- ...and 2 more distinct call shapes
- 133 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:6266`
