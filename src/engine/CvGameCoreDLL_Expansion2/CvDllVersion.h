/*	-------------------------------------------------------------------------------------------------------
	Civ V Access overlay. Forks the BNW engine DLL with fresh Lua bindings (Unit:GetPath,
	Game.GetCycleUnits, Game.GetBuildRoutePath, Unit:GetMissionQueue). The engine matches a
	loaded DLL to its registered .Civ5Pkg by GUID, so this MUST be unique to this fork.
	NEVER ROTATE: changing the GUID after release would split multiplayer compatibility
	across mod versions. New bindings are additive, no gameplay changes.
	------------------------------------------------------------------------------------------------------- */
#pragma once

// {DB5E082B-19A5-4F3D-A544-0206C7C08D6B}
static const GUID CIV5_XP2_DLL_GUID =
{ 0xdb5e082b, 0x19a5, 0x4f3d, { 0xa5, 0x44, 0x02, 0x06, 0xc7, 0xc0, 0x8d, 0x6b } };

static const char* CIV5_XP2_DLL_VERSION = "1.0.0-civvaccess";
