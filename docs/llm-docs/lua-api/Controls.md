# Controls

Methods on Control userdata (the engine UI widgets exposed to Lua via the `Controls` table or `instance.<X>` from InstanceManager). Receivers vary widely (`Controls.Foo`, `button`, `iconControl`, `instance.SubButton`, etc.) but call the same underlying engine API. Method set was learned from every `Controls.<X>:<Method>` call in the shipped game; calls on other receiver names with the same method names were folded in.

Extracted from 16283 call sites across 83 distinct methods in the shipped game Lua.

## Methods

### BranchResetAnimation
- `root:BranchResetAnimation()`
- `Controls.Anim:BranchResetAnimation()`
- 5 callsites. Example: `UI/InGame/WorldView/NotificationPanel.lua:202`

### BuildEntry
- `pullDown:BuildEntry("InstanceOne", controlTable)`
- `Controls.ChatPull:BuildEntry("InstanceOne", controlTable)`
- `pullDown:BuildEntry("InstanceOne", instance)`
- `Controls.PartialMatchPullDown:BuildEntry("InstanceOne", controlTable)`
- `Controls.MultiPull:BuildEntry("InstanceOne", controlTable)`
- ...and 19 more distinct call shapes
- 74 callsites. Example: `UI/InGame/WorldView/MiniMapPanel.lua:214`

### CalculateInternals
- `pullDown:CalculateInternals()`
- `Controls.PartialMatchPullDown:CalculateInternals()`
- `Controls.MultiPull:CalculateInternals()`
- `Controls.ChatPull:CalculateInternals()`
- `sortByPulldown:CalculateInternals()`
- ...and 16 more distinct call shapes
- 53 callsites. Example: `UI/InGame/WorldView/MiniMapPanel.lua:222`

### CalculateInternalSize
- `Controls.ScrollPanel:CalculateInternalSize()`
- `Controls.ItemScrollPanel:CalculateInternalSize()`
- `Controls.LeftScrollPanel:CalculateInternalSize()`
- `Controls.GoldScroll:CalculateInternalSize()`
- `Controls.HappinessScroll:CalculateInternalSize()`
- ...and 62 more distinct call shapes
- 385 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:126`

### CalculateSize
- `Controls.MainStack:CalculateSize()`
- `Controls.ItemStack:CalculateSize()`
- `Controls.ButtonStack:CalculateSize()`
- `Controls.ListOfArticles:CalculateSize()`
- `Controls.HappinessStack:CalculateSize()`
- ...and 182 more distinct call shapes
- 663 callsites. Example: `UI/InGame/CityList.lua:212`

### CallShowHideHandler
- `Controls.WonderStatus:CallShowHideHandler(true)`
- 1 callsite. Example: `DLC/DLC_06/Scenarios/WonderScenario/TurnsRemaining.lua:9`

### ClearCallback
- `buttonControl:ClearCallback(Mouse.eLClick)`
- `filledGreatWorkSlot:ClearCallback(Mouse.eLClick)`
- `Controls.UnitGiftButton:ClearCallback(Mouse.eLClick)`
- `Controls.RenameButton:ClearCallback(Mouse.eLClick)`
- `Controls.ResetButton:ClearCallback(Mouse.eLClick)`
- ...and 2 more distinct call shapes
- 13 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/SocialPolicyPopup.lua:558`

### ClearEntries
- `pullDown:ClearEntries()`
- `Controls.PartialMatchPullDown:ClearEntries()`
- `Controls.ChatPull:ClearEntries()`
- `Controls.MultiPull:ClearEntries()`
- `sortByPulldown:ClearEntries()`
- ...and 9 more distinct call shapes
- 41 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:423`

### ClearString
- `Controls.NameBox:ClearString()`
- `Controls.ChatEntry:ClearString()`
- 12 callsites. Example: `UI/InGame/Menus/SaveMapMenu.lua:28`

### DestroyAllChildren
- `Controls.SelectCivStack:DestroyAllChildren()`
- `stackControl:DestroyAllChildren()`
- `Controls.MainStack:DestroyAllChildren()`
- `Controls.CityStack:DestroyAllChildren()`
- `Controls.TradeStack:DestroyAllChildren()`
- ...and 19 more distinct call shapes
- 72 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/CivilWarScenarioLoadScreen.lua:140`

### DoAutoSize
- `Controls.Grid:DoAutoSize()`
- `Controls.DetailsGrid:DoAutoSize()`
- `Controls.MainGrid:DoAutoSize()`
- `Controls.TaskListGrid:DoAutoSize()`
- `Controls.OptionsPanel:DoAutoSize()`
- ...and 4 more distinct call shapes
- 35 callsites. Example: `UI/InGame/Popups/TextPopup.lua:39`

### GetAlpha
- `Controls.Anim:GetAlpha()`
- 1 callsite. Example: `UI/InGame/TurnProcessing.lua:123`

### GetButton
- `pullDown:GetButton()`
- `Controls.ChatPull:GetButton()`
- `automaticPurchasePullDown:GetButton()`
- `Controls.MapSizePullDown:GetButton()`
- `Controls.OverlayDropDown:GetButton()`
- ...and 30 more distinct call shapes
- 158 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:496`

### GetOffsetVal
- `Controls.OuterStack:GetOffsetVal()`
- `Controls.MainFrame:GetOffsetVal()`
- 4 callsites. Example: `UI/InGame/WorldView/NotificationPanel.lua:16`

### GetOffsetX
- `Controls.LeaderName:GetOffsetX()`
- `Controls.CivName:GetOffsetX()`
- `Controls.NextCityButton:GetOffsetX()`
- `Controls.ThemTablePanel:GetOffsetX()`
- `Controls.GraphsPanel:GetOffsetX()`
- ...and 2 more distinct call shapes
- 17 callsites. Example: `UI/InGame/DiploList.lua:228`

### GetOffsetY
- `Controls.OuterGrid:GetOffsetY()`
- `Controls.ScrollPanel:GetOffsetY()`
- `Controls.GraphsPanel:GetOffsetY()`
- `Controls.GraphDisplay:GetOffsetY()`
- 10 callsites. Example: `UI/InGame/DiploList.lua:38`

### GetRatio
- `Controls.SmallScrollPanel:GetRatio()`
- `Controls.MPListScroll:GetRatio()`
- 5 callsites. Example: `UI/InGame/WorldView/NotificationPanel.lua:392`

### GetScrollValue
- `Controls.ScoreScrollPanel:GetScrollValue()`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:290`

### GetSize
- `label:GetSize()`
- `Controls.ScrollPanel:GetSize()`
- `Controls.LeaderSpeech:GetSize()`
- `Controls.UnitPortrait:GetSize()`
- `Controls.ScrollBar:GetSize()`
- ...and 16 more distinct call shapes
- 79 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:1755`

### GetSizeVal
- `Controls.UnitName:GetSizeVal()`
- `Controls.ItemScrollPanel:GetSizeVal()`
- `Controls.BottomPanel:GetSizeVal()`
- `Controls.ConfirmContent:GetSizeVal()`
- `Controls.UnitNameButton:GetSizeVal()`
- ...and 15 more distinct call shapes
- 64 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:408`

### GetSizeX
- `Controls.ChatPull:GetSizeX()`
- `Controls.DetailsGrid:GetSizeX()`
- `Controls.NameBox:GetSizeX()`
- `control:GetSizeX()`
- `Controls.PrevCityButton:GetSizeX()`
- ...and 11 more distinct call shapes
- 56 callsites. Example: `UI/InGame/WorldView/DiploCorner.lua:297`

### GetSizeY
- `Controls.DetailsGrid:GetSizeY()`
- `Controls.RightStack:GetSizeY()`
- `Controls.OuterStack:GetSizeY()`
- `Controls.BigStack:GetSizeY()`
- `textControl:GetSizeY()`
- ...and 10 more distinct call shapes
- 38 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:582`

### GetText
- `Controls.NameBox:GetText()`
- `Controls.LengthTest:GetText()`
- `Controls.TurnNotifySmtpPassEdit:GetText()`
- `Controls.UNInfo:GetText()`
- `Controls.CultureLabel:GetText()`
- ...and 20 more distinct call shapes
- 85 callsites. Example: `UI/InGame/Menus/SaveMapMenu.lua:15`

### GetTextControl
- `Controls.UsPocketCities:GetTextControl()`
- `Controls.ThemPocketCities:GetTextControl()`
- `Controls.UsPocketGold:GetTextControl()`
- `Controls.ThemPocketGold:GetTextControl()`
- `Controls.UsPocketGoldPerTurn:GetTextControl()`
- ...and 21 more distinct call shapes
- 146 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1284`

### GetValue
- `Controls.BigSlider:GetValue()`
- `Controls.SmallSlider:GetValue()`
- 2 callsites. Example: `UI/FrontEnd/UITestMenu.lua:89`

### GetVoid1
- `control:GetVoid1()`
- `Controls.MusicVolumeSlider:GetVoid1()`
- `Controls.EffectsVolumeSlider:GetVoid1()`
- `Controls.SpeechVolumeSlider:GetVoid1()`
- `Controls.AmbienceVolumeSlider:GetVoid1()`
- 24 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:6504`

### HasMouseOver
- `Controls.TheBox:HasMouseOver()`
- 3 callsites. Example: `UI/InGame/PlotHelpManager.lua:60`

### IsChecked
- `Controls.MaxTurnsCheck:IsChecked()`
- `Controls.DontShowAgainCheckbox:IsChecked()`
- `Controls.UsePasswordCheck:IsChecked()`
- `Controls.CreateRoad_Checkbox:IsChecked()`
- `Controls.VerboseLoggingToggle:IsChecked()`
- ...and 4 more distinct call shapes
- 13 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1056`

### IsHidden
- `Controls.SelectCivScrollPanel:IsHidden()`
- `Controls.ChooseConfirm:IsHidden()`
- `Controls.WarConfirm:IsHidden()`
- `Controls.DiploList:IsHidden()`
- `Controls.PolicyConfirm:IsHidden()`
- ...and 76 more distinct call shapes
- 236 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/CivilWarScenarioLoadScreen.lua:27`

### IsStopped
- `Controls.Anim:IsStopped()`
- `activeTurnAnim:IsStopped()`
- 2 callsites. Example: `UI/InGame/TurnProcessing.lua:123`

### IsTrackingLeftMouseButton
- `Controls.MinorCivsSlider:IsTrackingLeftMouseButton()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/GameSetup/MPGameOptions.lua:831`

### LocalizeAndSetText
- `Controls.Quote:LocalizeAndSetText(civ.DawnOfManQuote or "")`
- `Controls.BonusDescription:LocalizeAndSetText(GameInfo.Traits[trait].Description)`
- `Controls.Title:LocalizeAndSetText("TXT_KEY_RANDOM_LEADER")`
- `Controls.TurnsRemainingLabel:LocalizeAndSetText(turnsRemainingText)`
- `labelControl:LocalizeAndSetText(tenet.Description)`
- ...and 241 more distinct call shapes
- 499 callsites. Example: `UI/FrontEnd/LoadScreen.lua:86`

### LocalizeAndSetToolTip
- `Controls.ConnectedIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_CONNECTED")`
- `Controls.BlockadedIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_BLOCKADED")`
- `Controls.RazingIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_BURNING", pCity:GetRazingTurns())`
- `Controls.ResistanceIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_RESISTANCE", pCity:GetResistanceTurns())`
- `Controls.PuppetIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_PUPPET")`
- ...and 37 more distinct call shapes
- 74 callsites. Example: `UI/InGame/CityView/CityView.lua:673`

### Play
- `Controls.SlideAnim:Play()`
- `Controls.AlphaAnim:Play()`
- `Controls.Anim:Play()`
- `activeTurnAnim:Play()`
- 6 callsites. Example: `UI/FrontEnd/Credits.lua:40`

### RegisterAnimCallback
- `Controls.Anim:RegisterAnimCallback(OnAlphaAnim)`
- 1 callsite. Example: `UI/InGame/TurnProcessing.lua:129`

### RegisterCallback
- `Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)`
- `Controls.BackButton:RegisterCallback(Mouse.eLClick, OnBack)`
- `Controls.Yes:RegisterCallback(Mouse.eLClick, OnYes)`
- `Controls.No:RegisterCallback(Mouse.eLClick, OnNo)`
- `Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnCloseButtonClicked)`
- ...and 732 more distinct call shapes
- 1650 callsites. Example: `UI/TouchControlsMenu.lua:21`

### RegisterCheckHandler
- `Controls.PolicyInfo:RegisterCheckHandler(OnPolicyInfo)`
- `Controls.HideQueueButton:RegisterCheckHandler(OnHideQueue)`
- `Controls.ShowFeatures:RegisterCheckHandler(OnShowFeaturesChecked)`
- `Controls.ShowFogOfWar:RegisterCheckHandler(OnShowFOWChecked)`
- `Controls.ShowGrid:RegisterCheckHandler(OnShowGridChecked)`
- ...and 42 more distinct call shapes
- 60 callsites. Example: `UI/Options/OptionsMenu.lua:1015`

### RegisterDownEndCallback
- `Controls.ScoreScrollPanel:RegisterDownEndCallback(OnLeaderboardDownEnd)`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:76`

### RegisterSelectionCallback
- `Controls.ChatPull:RegisterSelectionCallback(OnChatTarget)`
- `Controls.MultiPull:RegisterSelectionCallback(function(id) local entry = additionalEntries[id]; if(entry and entry.call ~= nil) then entry.call(); end end)`
- `pullDown:RegisterSelectionCallback(OnOverlaySelected)`
- `pullDown:RegisterSelectionCallback(OnIconModeSelected)`
- `automaticPurchasePullDown:RegisterSelectionCallback(function(v1, v2) local player = Players[Game.GetActivePlayer()]; Network.SendFaithPurchase(Game.GetActivePlayer(), v1, v2); SetCurrentSelection(v1, v2); end)`
- ...and 42 more distinct call shapes
- 55 callsites. Example: `UI/InGame/WorldView/DiploCorner.lua:308`

### RegisterSliderCallback
- `Controls.MinorCivsSlider:RegisterSliderCallback(OnMinorCivsSlider)`
- `Controls.BigSlider:RegisterSliderCallback(SliderUpdate)`
- `Controls.SmallSlider:RegisterSliderCallback(SliderUpdate)`
- `Controls.MusicVolumeSlider:RegisterSliderCallback(OnUIVolumeSliderValueChanged)`
- `Controls.EffectsVolumeSlider:RegisterSliderCallback(OnUIVolumeSliderValueChanged)`
- ...and 6 more distinct call shapes
- 12 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1093`

### RegisterUpEndCallback
- `Controls.ScoreScrollPanel:RegisterUpEndCallback(OnLeaderboardUpEnd)`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:66`

### ReleaseChild
- `Controls.ChatStack:ReleaseChild(g_ChatInstances[ 1 ].Box)`
- `Controls.NaturalWonderStore:ReleaseChild(instance.Anchor)`
- `Controls.SettlerReccomendationStore:ReleaseChild(instance.Anchor)`
- `Controls.WorkerReccomendationStore:ReleaseChild(instance.Anchor)`
- `Controls.SmallStack:ReleaseChild(instance[ name .. "Container" ])`
- 17 callsites. Example: `UI/InGame/WorldView/DiploCorner.lua:141`

### ReprocessAnchoring
- `Controls.MainStack:ReprocessAnchoring()`
- `Controls.ScrollPanel:ReprocessAnchoring()`
- `Controls.ItemStack:ReprocessAnchoring()`
- `Controls.ButtonStack:ReprocessAnchoring()`
- `Controls.HappinessStack:ReprocessAnchoring()`
- ...and 165 more distinct call shapes
- 566 callsites. Example: `UI/InGame/GPList.lua:188`

### Reverse
- `Controls.Anim:Reverse()`
- `activeTurnAnim:Reverse()`
- 2 callsites. Example: `UI/InGame/TurnProcessing.lua:112`

### SetAlpha
- `Controls.SmallUIAssetsCheck:SetAlpha(0.5)`
- `Controls.CityToggle:SetAlpha(1.0)`
- `Controls.CityToggle:SetAlpha(0.5)`
- `Controls.TradeToggle:SetAlpha(1.0)`
- `Controls.TradeToggle:SetAlpha(0.5)`
- ...and 37 more distinct call shapes
- 89 callsites. Example: `UI/Options/OptionsMenu.lua:348`

### SetAnchor
- `Controls.ReligionStack:SetAnchor("L_T")`
- `Controls.ReligionStack:SetAnchor("C_T")`
- `Controls.WonderSplash:SetAnchor(thisBuilding.WonderSplashAnchor)`
- `Controls.WonderSplash:SetAnchor("T_R")`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:346`

### SetCheck
- `Controls.BalancedFocusButton:SetCheck(true)`
- `Controls.NoAutoSpecialistCheckbox:SetCheck(true)`
- `Controls.PolicyInfo:SetCheck(OptionsManager.GetPolicyInfo())`
- `Controls.UnitMemberFSMDebug_Checkbox:SetCheck(g_bUnitMemberFSMDebugCheck)`
- `Controls.FoodFocusButton:SetCheck(true)`
- ...and 87 more distinct call shapes
- 147 callsites. Example: `UI/InGame/CityView/CityView.lua:950`

### SetColor
- `Controls.UnitIcon:SetColor(iconColor)`
- `thisBack:SetColor(fadeColor)`
- `Controls.ApolloIcon:SetColor(white)`
- `controlTable[ control ]:SetColor(white)`
- `controlTable:SetColor(darken)`
- ...and 19 more distinct call shapes
- 84 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:78`

### SetColorByName
- `Controls.StmpPasswordMatchLabel:SetColorByName("Green_Chat")`
- `Controls.StmpPasswordMatchLabel:SetColorByName("Magenta_Chat")`
- 4 callsites. Example: `UI/Options/OptionsMenu.lua:1310`

### SetDisabled
- `Controls.WarButton:SetDisabled(true)`
- `Controls.ConfirmButton:SetDisabled(g_NumberOfFreeItems ~= #SelectedItems)`
- `Controls.ConfirmButton:SetDisabled(true)`
- `Controls.Delete:SetDisabled(true)`
- `Controls.Button4:SetDisabled(false)`
- ...and 211 more distinct call shapes
- 630 callsites. Example: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:178`

### SetEndVal
- `Controls.SlideAnim:SetEndVal(0, -(Controls.CreditsList:GetSizeY() - 2651))`
- `horizontalMouseCrosshair:SetEndVal(graphDisplayWidth, y)`
- `verticalMouseCrosshair:SetEndVal(x, graphDisplayHeight)`
- `horizontalMouseGuide:SetEndVal(horizontalMouseGuideEnd, y)`
- `verticalMouseGuide:SetEndVal(x, verticalMouseGuideEnd)`
- 5 callsites. Example: `UI/FrontEnd/Credits.lua:92`

### SetFontByName
- `Controls.UnitName:SetFontByName("TwCenMT24")`
- `Controls.UnitName:SetFontByName("TwCenMT20")`
- `Controls.UnitName:SetFontByName("TwCenMT14")`
- 18 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:406`

### SetHide
- `Controls.PortraitFrame:SetHide(false)`
- `Controls.PortraitFrame:SetHide(true)`
- `thisButton:SetHide(false)`
- `Controls.BBTextStack:SetHide(false)`
- `Controls.RelatedImagesFrame:SetHide(true)`
- ...and 1524 more distinct call shapes
- 5507 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:1318`

### SetMapSize
- `Controls.ReplayMap:SetMapSize(mapWidth, mapHeight, 0, -1)`
- 1 callsite. Example: `UI/InGame/Popups/ReplayViewer.lua:1000`

### SetOffsetVal
- `Controls.ScrollBar:SetOffsetVal(0, 18)`
- `Controls.LeftScrollBar:SetOffsetVal(0, 18)`
- `Controls.DownButton:SetOffsetVal(0, screenSizeY - 126 - 18)`
- `Controls.LeftDownButton:SetOffsetVal(0, screenSizeY - 126 - 18)`
- `Controls.LeftUpButton:SetOffsetVal(0, 0)`
- ...and 23 more distinct call shapes
- 78 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:116`

### SetOffsetX
- `barMarkerCtrl:SetOffsetX(xOffset)`
- `Controls.MPListScroll:SetOffsetX(15)`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:113`

### SetOffsetY
- `Controls.MPListScroll:SetOffsetY(TOP_COMPENSATION + CHAT_COMPENSATION)`
- `Controls.MPListScroll:SetOffsetY(TOP_COMPENSATION)`
- 2 callsites. Example: `UI/InGame/WorldView/MPList.lua:523`

### SetPercent
- `Controls.TechProgress:SetPercent(g_PreReqsAcquired / totalPreReqs)`
- `Controls.GAMeter:SetPercent(fProgress / fThreshold)`
- `Controls.GGMeter:SetPercent(fProgress / fThreshold)`
- `Controls.PeopleMeter:SetPercent(pCity:GetFood() / pCity:GrowthThreshold())`
- `Controls.CultureMeter:SetPercent(percentComplete)`
- ...and 15 more distinct call shapes
- 48 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:322`

### SetPercents
- `Controls.ProductionMeter:SetPercents(fProductionProgressPercent, fProductionProgressPlusThisTurnPercent)`
- `potentialMeter:SetPercents(pct,pct)`
- `Controls.ResearchMeter:SetPercents(fResearchProgressPercent, fResearchProgressPlusThisTurnPercent)`
- `Controls.ResearchMeter:SetPercents(1, 0)`
- `Controls.AgentActivityProgress:SetPercents(progresspct, nextprogresspct)`
- ...and 6 more distinct call shapes
- 24 callsites. Example: `UI/InGame/CityView/CityView.lua:1569`

### SetScrollValue
- `Controls.ScrollPanel:SetScrollValue(0)`
- `Controls.UsPocketPanel:SetScrollValue(0)`
- `Controls.ThemPocketPanel:SetScrollValue(0)`
- `Controls.ChatScroll:SetScrollValue(1)`
- `Controls.UsTablePanel:SetScrollValue(0)`
- ...and 9 more distinct call shapes
- 51 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:6143`

### SetShadowPercent
- `Controls.Meter:SetShadowPercent(pct * 2)`
- 1 callsite. Example: `UI/FrontEnd/UITestMenu.lua:23`

### SetSize
- `innerFrame:SetSize(frameSize)`
- `outerFrame:SetSize(frameSize)`
- `Controls.ScrollBar:SetSize(scrollBarSize)`
- `Controls.ScrollPanel:SetSize(scrollPanelSize)`
- `Controls.LeftScrollBar:SetSize(scrollBarSize)`
- ...and 32 more distinct call shapes
- 124 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:1758`

### SetSizeVal
- `Controls.ItemScrollPanel:SetSizeVal(spWidth, spHeight)`
- `Controls.BottomPanel:SetSizeVal(bpWidth, bpHeight)`
- `Controls.ConfirmFrame:SetSizeVal(width + 60, height + 120)`
- `Controls.ActiveStyle:SetSizeVal(numButtonsAdded*56 + 130, 126)`
- `imageControl:SetSizeVal(imageW, imageH)`
- ...and 20 more distinct call shapes
- 71 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseAdmiralNewPort.lua:27`

### SetSizeX
- `Controls.DetailsGrid:SetSizeX(sizeX)`
- `Controls.ResourceDemandedBox:SetSizeX(Controls.ResourceDemandedString:GetSizeX() + 10)`
- `Controls.TechTreeScrollBar:SetSizeX(Controls.TechTreeScrollPanel:GetSize().x - 150)`
- `Controls.MPListScroll:SetSizeX(Controls.MPListStack:GetSizeX())`
- `Controls.TurnQueueGrid:SetSizeX(turnQueueSizeX)`
- ...and 4 more distinct call shapes
- 22 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:581`

### SetSizeY
- `Controls.DetailsSeperator:SetSizeY(Controls.DetailsGrid:GetSizeY())`
- `Controls.LeaderSpeechBorderFrame:SetSizeY(contentSize)`
- `Controls.LeaderSpeechFrame:SetSizeY(contentSize - offsetsBetweenFrames)`
- `Controls.MainGrid:SetSizeY(screenY - TOP_COMPENSATION)`
- `Controls.OuterGrid:SetSizeY(MAX_SIZE)`
- ...and 29 more distinct call shapes
- 89 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:582`

### SetText
- `Controls.ArticleID:SetText(name)`
- `Controls.YieldLabel:SetText(Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ))`
- `Controls.YieldLabel:SetText(Locale.ConvertTextKey( yieldString ))`
- `Controls.LeaderSpeech:SetText(g_strLeaveScreenText)`
- `Controls.UnitStatStrength:SetText(strength)`
- ...and 753 more distinct call shapes
- 2042 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:1941`

### SetTexture
- `thisButton:SetTexture(textureSheet)`
- `Controls.BackgroundImage:SetTexture(lastBackgroundImage)`
- `Controls.IconShadow:SetTexture(questionTextureSheet)`
- `Controls[buttonName]:SetTexture(questionTextureSheet)`
- `controlTable[buttonName]:SetTexture(questionTextureSheet)`
- ...and 83 more distinct call shapes
- 296 callsites. Example: `UI/InGame/TechTree/TechButtonInclude.lua:354`

### SetTextureAndResize
- `Controls.WonderSplash:SetTextureAndResize(thisBuilding.WonderSplashImage)`
- `Controls.WonderSplash:SetTextureAndResize(lastBackgroundImage)`
- `Controls.GreatWorkSplash:SetTextureAndResize(greatWorkImage)`
- `Controls.BackgroundImage:SetTextureAndResize(tProject.ProjectSplashImage)`
- 4 callsites. Example: `UI/InGame/Popups/WonderPopup.lua:48`

### SetTextureHandle
- `Controls.Minimap:SetTextureHandle(uiHandle)`
- 2 callsites. Example: `UI/InGame/WorldView/MiniMapPanel.lua:12`

### SetTextureOffset
- `thisButton:SetTextureOffset(textureOffset)`
- `Controls.IconShadow:SetTextureOffset(questionOffset)`
- `Controls[buttonName]:SetTextureOffset(questionOffset)`
- `controlTable[buttonName]:SetTextureOffset(questionOffset)`
- `Controls.UnitIcon:SetTextureOffset(textureOffset)`
- ...and 13 more distinct call shapes
- 131 callsites. Example: `UI/InGame/TechTree/TechButtonInclude.lua:355`

### SetTextureOffsetVal
- `Controls.Portrait:SetTextureOffsetVal(0,0)`
- `Controls.CivIcon:SetTextureOffsetVal(448 + 7, 128 + 7)`
- `Controls.TopIcon:SetTextureOffsetVal(textureOffset.u, textureOffset.v)`
- `imageControl:SetTextureOffsetVal((offset % numCols) * iconSize, math.floor(offset / numCols) * iconSize)`
- `teamColorControl:SetTextureOffsetVal(141, 0)`
- ...and 7 more distinct call shapes
- 16 callsites. Example: `DLC/Expansion2/UI/Civilopedia/CivilopediaScreen.lua:1886`

### SetToBeginning
- `Controls.SlideAnim:SetToBeginning()`
- `activeTurnAnim:SetToBeginning()`
- `Controls.AlphaAnim:SetToBeginning()`
- 5 callsites. Example: `UI/FrontEnd/Credits.lua:39`

### SetToolTipCallback
- `Controls.SciencePerTurn:SetToolTipCallback(ScienceTipHandler)`
- `Controls.GoldPerTurn:SetToolTipCallback(GoldTipHandler)`
- `Controls.HappinessString:SetToolTipCallback(HappinessTipHandler)`
- `Controls.GoldenAgeString:SetToolTipCallback(GoldenAgeTipHandler)`
- `Controls.CultureString:SetToolTipCallback(CultureTipHandler)`
- ...and 5 more distinct call shapes
- 41 callsites. Example: `UI/InGame/TopPanel.lua:290`

### SetToolTipString
- `Controls[buttonName]:SetToolTipString(unknownString)`
- `controlTable[buttonName]:SetToolTipString(unknownString)`
- `Controls.MapSize:SetToolTipString(unknownString)`
- `Controls.Handicap:SetToolTipString(unknownString)`
- `Controls.SpeedIcon:SetToolTipString(unknownString)`
- ...and 302 more distinct call shapes
- 872 callsites. Example: `UI/FrontEnd/GameSetup/GameSetupScreen.lua:530`

### SetToolTipType
- `Controls.TheBox:SetToolTipType()`
- `Controls.TheBox:SetToolTipType("HexDetails")`
- 28 callsites. Example: `UI/InGame/PlotHelpManager.lua:45`

### SetValue
- `Controls.MusicVolumeSlider:SetValue(GetVolumeKnobValue(iMusicVolumeKnobID))`
- `Controls.EffectsVolumeSlider:SetValue(GetVolumeKnobValue(iSFXVolumeKnobID))`
- `Controls.SpeechVolumeSlider:SetValue(GetVolumeKnobValue(iSpeechVolumeKnobID))`
- `Controls.AmbienceVolumeSlider:SetValue(GetVolumeKnobValue(iAmbienceVolumeKnobID))`
- `Controls.MinorCivsSlider:SetValue(PreGame.GetNumMinorCivs() / maxMinorCivs)`
- ...and 10 more distinct call shapes
- 20 callsites. Example: `UI/Options/OptionsMenu.lua:465`

### SetVoid1
- `Controls.SortStrength:SetVoid1(eStrength)`
- `Controls.SortName:SetVoid1(eName)`
- `Controls.SortStatus:SetVoid1(eStatus)`
- `Controls.SortMovement:SetVoid1(eMovement)`
- `thisButton:SetVoid1(i)`
- ...and 103 more distinct call shapes
- 286 callsites. Example: `UI/InGame/CityList.lua:286`

### SetVoid2
- `Controls.UsPocketCitiesClose:SetVoid2(1)`
- `Controls.ThemPocketCitiesClose:SetVoid2(0)`
- `Controls.UsPocketLeaderClose:SetVoid2(1)`
- `Controls.ThemPocketLeaderClose:SetVoid2(0)`
- `Controls.ProduceGoldButton:SetVoid2(processID)`
- ...and 1 more distinct call shapes
- 16 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2418`

### SetVoids
- `button:SetVoids(buttonId, addToList)`
- `thisTechButtonInstance[buttonName]:SetVoids(void1, void2)`
- `Controls.CityButton:SetVoids(city:GetX(), city:GetY())`
- `Controls.UsPocketOtherPlayerWar:SetVoids(1, WAR)`
- `Controls.ThemPocketOtherPlayerWar:SetVoids(0, WAR)`
- ...and 2 more distinct call shapes
- 23 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:1821`

### SetWrapWidth
- `Controls.DescriptionLabel:SetWrapWidth(popupInfo.Data1)`
- `Controls.DescriptionLabel:SetWrapWidth(400)`
- `Controls.TurnQueueStack:SetWrapWidth(screenX - UNITPANEL_GUESS - MINIMAP_GUESS - TURNQUEUE_MINMARGIN)`
- `Controls.LowerCaption:SetWrapWidth(lcMaxWidth)`
- 8 callsites. Example: `UI/InGame/Popups/TextPopup.lua:18`

### SortChildren
- `Controls.ListOfArticles:SortChildren(SortFunction)`
- `Controls.MilitaryStack:SortChildren(SortFunction)`
- `Controls.CivilianStack:SortChildren(SortFunction)`
- `Controls.ArtistStack:SortChildren(SortFunction)`
- `Controls.EngineerStack:SortChildren(SortFunction)`
- ...and 14 more distinct call shapes
- 173 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:4690`

### TakeFocus
- `Controls.ChatEntry:TakeFocus()`
- `Controls.NameBox:TakeFocus()`
- `Controls.EditBox:TakeFocus()`
- `Controls.OldPasswordEditBox:TakeFocus()`
- `Controls.NewPasswordEditBox:TakeFocus()`
- ...and 4 more distinct call shapes
- 14 callsites. Example: `UI/InGame/WorldView/DiploCorner.lua:242`

### UnloadTexture
- `Controls.Portrait:UnloadTexture()`
- `Controls.LargeMapImage:UnloadTexture()`
- `Controls.BackgroundImage:UnloadTexture()`
- `Controls.EraImage:UnloadTexture()`
- `Controls.DetailsBackgroundImage:UnloadTexture()`
- ...and 6 more distinct call shapes
- 56 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:6218`
