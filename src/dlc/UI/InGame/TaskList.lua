-- Civ V Access: base-game override.
-- Target: Assets/UI/InGame/TaskList.{lua,xml} (base game; not overridden by
-- Expansion/Expansion2). Contents above the bootstrap marker are a verbatim
-- copy of the base-game file. Re-diff against the base file after any Civ V
-- patch. Rationale for this target: small (~50 lines), leaf file with no
-- gameplay coupling, always instantiated in-game (Events.TaskListUpdate is
-- fired by the engine), and unmodified by G&K / BNW.
include( "InstanceManager" );

-- the instance managers
local g_TaskItemManager = InstanceManager:new( "TaskEntryInstance", "TaskLabel", Controls.TaskStack );

local g_aTaskStatus = {};
local g_aTaskString = {};
local g_iMaxIndex = -1;

----------------------------------------------------------------
function OnUpdate( TaskListInfo )
	local iIndex = TaskListInfo.Index;
	if (iIndex > g_iMaxIndex) then
		if (g_iMaxIndex < 0) then
			ContextPtr:SetHide(false);
		end

		g_iMaxIndex = iIndex;
	end

	g_aTaskStatus[iIndex] = TaskListInfo.TaskStatus;
	g_aTaskString[iIndex] = TaskListInfo.Text;

	g_TaskItemManager:ResetInstances();
	for i = 0, g_iMaxIndex do
		if (g_aTaskStatus[i] ~= nil) then
			-- build strings for entry
			local iStatusType = g_aTaskStatus[i];
			local iOffset = 0;
			if (iStatusType == 0) then
				iOffset = 96;
			elseif (iStatusType == 1) then
				iOffset = 32;
			elseif (iStatusType == 2) then
				iOffset = 0;
			end

			local controlTable = g_TaskItemManager:GetInstance();
			controlTable.TaskEntryImage:SetTextureOffsetVal(0, iOffset);
			controlTable.TaskLabel:SetText(g_aTaskString[i]);
		end
	end
	Controls.TaskStack:CalculateSize();
	Controls.TaskListGrid:DoAutoSize();

end
Events.TaskListUpdate.Add( OnUpdate );

Controls.TaskStack:CalculateSize();
Controls.TaskListGrid:DoAutoSize();

-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_Boot")
