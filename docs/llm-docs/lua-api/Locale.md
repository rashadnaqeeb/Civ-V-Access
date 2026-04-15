# Locale

Localization / text-key resolution. Static table.

Extracted from 7545 call sites across 22 distinct methods in the shipped game Lua.

## Methods

### Compare
- `Locale.Compare(a.Name, b.Name)`
- `Locale.Compare(a[field], b[field])`
- `Locale.Compare(a[1], b[1])`
- `Locale.Compare(va, vb)`
- `Locale.Compare(a,b)`
- ...and 12 more distinct call shapes
- 73 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:80`

### ConvertTextKey
- `Locale.ConvertTextKey(pResource.Description)`
- `Locale.ConvertTextKey(info.Description)`
- `Locale.ConvertTextKey(row.Description)`
- `Locale.ConvertTextKey("TXT_KEY_MISC_UNKNOWN")`
- `Locale.ConvertTextKey(building.Description)`
- ...and 1782 more distinct call shapes
- 6174 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:58`

### EndsWith
- `Locale.EndsWith(strInfo, "_NEWLINE_")`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:947`

### GetCurrentLanguage
- `Locale.GetCurrentLanguage()`
- 2 callsites. Example: `UI/Options/OptionsMenu.lua:531`

### GetCurrentSpokenLanguage
- `Locale.GetCurrentSpokenLanguage()`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:689`

### GetHotKeyDescription
- `Locale.GetHotKeyDescription(hotKey, controlInfo.CtrlDown, controlInfo.AltDown, controlInfo.ShiftDown)`
- 2 callsites. Example: `UI/InGame/WorldView/MiniMapPanel.lua:438`

### GetSupportedLanguages
- `Locale.GetSupportedLanguages()`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:35`

### GetSupportedSpokenLanguages
- `Locale.GetSupportedSpokenLanguages()`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:36`

### HasTextKey
- `Locale.HasTextKey(tag)`
- `Locale.HasTextKey(name)`
- `Locale.HasTextKey("TXT_KEY_DIPLO_MY_SCORE_SCENARIO1")`
- `Locale.HasTextKey("TXT_KEY_DIPLO_MY_SCORE_SCENARIO2")`
- `Locale.HasTextKey("TXT_KEY_DIPLO_MY_SCORE_SCENARIO3")`
- ...and 3 more distinct call shapes
- 27 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:1828`

### IsNilOrEmpty
- `Locale.IsNilOrEmpty(name)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:639`

### IsNilOrWhitespace
- `Locale.IsNilOrWhitespace(mapData.Name)`
- `Locale.IsNilOrWhitespace(map.Name)`
- `Locale.IsNilOrWhitespace(map.Description)`
- `Locale.IsNilOrWhitespace(mapInfo.Name)`
- `Locale.IsNilOrWhitespace(data.CivilizationName)`
- ...and 3 more distinct call shapes
- 20 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:824`

### Length
- `Locale.Length(strInfo)`
- `Locale.Length(Locale.Lookup("TXT_KEY_TURNS"))`
- `Locale.Length(name)`
- `Locale.Length(newString)`
- `Locale.Length(v.DisplayName)`
- 12 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:948`

### Lookup
- `Locale.Lookup(belief.ShortDescription)`
- `Locale.Lookup(belief.Description)`
- `Locale.Lookup(Game.GetReligionName(eReligion))`
- `Locale.Lookup("TXT_KEY_MISC_UNKNOWN")`
- `Locale.Lookup(row.Description)`
- ...and 414 more distinct call shapes
- 818 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChoosePantheonPopup.lua:96`

### LookupLanguage
- `Locale.LookupLanguage(g_Languages[g_chosenLanguage].Type, "TXT_KEY_OPSCREEN_LANGUAGE_TIMER")`
- `Locale.LookupLanguage(g_Languages[g_chosenLanguage].Type, "TXT_KEY_YES_BUTTON")`
- `Locale.LookupLanguage(g_Languages[g_chosenLanguage].Type, "TXT_KEY_NO_BUTTON")`
- 3 callsites. Example: `UI/Options/OptionsMenu.lua:246`

### SetCurrentLanguage
- `Locale.SetCurrentLanguage(g_Languages[g_chosenLanguage].Type)`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:515`

### SetCurrentSpokenLanguage
- `Locale.SetCurrentSpokenLanguage(g_SpokenLanguages[level].Type)`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:1005`

### Substring
- `Locale.Substring(strInfo, 1, iNewLength)`
- `Locale.Substring(newString, 1, Locale.Length(newString) - 1)`
- 4 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:949`

### ToLower
- `Locale.ToLower(name)`
- `Locale.ToLower(searchString)`
- `Locale.ToLower(v.entryName)`
- `Locale.ToLower(partialMatch[1])`
- `Locale.ToLower(PreGame.GetMapScript())`
- ...and 5 more distinct call shapes
- 150 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:223`

### ToNumber
- `Locale.ToNumber(pPlayer:GetUnhappinessFromUnits() / 100, "_.__")`
- `Locale.ToNumber(pPlayer:GetUnhappinessFromCityCount() / 100, "_.__")`
- `Locale.ToNumber(pPlayer:GetUnhappinessFromCapturedCityCount() / 100, "_.__")`
- `Locale.ToNumber(pPlayer:GetUnhappinessFromOccupiedCities() / 100, "_.__")`
- `Locale.ToNumber(best[1], "_____________")`
- ...and 55 more distinct call shapes
- 157 callsites. Example: `UI/InGame/TopPanel.lua:629`

### ToPercent
- `Locale.ToPercent(GetVolumeKnobValue(iMusicVolumeKnobID))`
- `Locale.ToPercent(GetVolumeKnobValue(iSFXVolumeKnobID))`
- `Locale.ToPercent(GetVolumeKnobValue(iSpeechVolumeKnobID))`
- `Locale.ToPercent(GetVolumeKnobValue(iAmbienceVolumeKnobID))`
- `Locale.ToPercent(fNewVolume)`
- ...and 1 more distinct call shapes
- 10 callsites. Example: `UI/Options/OptionsMenu.lua:470`

### ToUpper
- `Locale.ToUpper(convertedKey)`
- `Locale.ToUpper(name)`
- `Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_INTERFACEMODE_RANGE_ATTACK"))`
- `Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_RETURN"))`
- `Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_MENU"))`
- ...and 16 more distinct call shapes
- 75 callsites. Example: `UI/InGame/CityView/CityView.lua:736`

### TruncateString
- `Locale.TruncateString(techName, 20, true)`
- `Locale.TruncateString(techName, maxTechNameLength, true)`
- `Locale.TruncateString(title, 30, true)`
- 7 callsites. Example: `UI/InGame/TechPopup.lua:137`
