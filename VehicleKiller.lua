--[[ Meticulously Crafted by JayMontana36 | This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA. ]]





--[[ Config Area ]]
local CheckNearby	= false	--[[ Set this to true if you want this script to check vehicles near players (including vehicles in use by players); Set this to false if you want this script to only check vehicles that players are currently using. ]]
local AlwaysActive	= false	--[[ Set this to true if you want this script to always run regardless of the TriggerKey being pressed or not. ]]
local RunWhileHeld	= false	--[[ Set this to true if you want this script to loop-run while the TriggerKey is being held down; Set this to false if you want this script to only run once for every one press of the TriggerKey. ]]
local MaxNearbyVehs	= 4		--[[ Can be any integer number above 0. This number is per player; the closest (4 by default) vehicles (that your game knows about) near players will be checked, if CheckNearby is set to true. ]]
local TriggerKey	= 223	--[[ 223	INPUT_SCRIPT_RDOWN	LEFT MOUSE BUTTON	A | Default TriggerKey; https://docs.fivem.net/docs/game-references/controls/ for alternate keys. ]]



local VehicleBlacklist	= { -- Format: '["VehicleHash"] = true,'
	["2069146067"] = true,	--oppressor2 aka Oppressor MK2
}





--[[ Script/Code Area ]]
local PAD = CONTROLS--Added/Used due to FiveM differences, for people who are more familiar with FiveM Lua scripting than GTA V Lua Plugin Scripting, same with a lot of the natives below.

local IsControlPressed if RunWhileHeld then IsControlPressed = PAD.IS_CONTROL_PRESSED else IsControlPressed = PAD.IS_CONTROL_JUST_PRESSED end
local NetworkIsPlayerActive			= NETWORK.NETWORK_IS_PLAYER_ACTIVE
local GetVehiclePedIsUsing			= PED.GET_VEHICLE_PED_IS_USING
local GetPlayerPed					= PLAYER.GET_PLAYER_PED
local tostring						= tostring
local GetEntityModel				= ENTITY.GET_ENTITY_MODEL
local NetworkHasControlOfEntity		= NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY
local NetworkRequestControlOfEntity	= NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY
local SetVehicleEngineHealth		= VEHICLE.SET_VEHICLE_ENGINE_HEALTH



local Vehicle

local VehicleKiller =
{
	tick	=	function()
					if AlwaysActive or IsControlPressed(0, TriggerKey) then
						--if CheckNearby then
							
						--else
							for i=0,31 do
								if NetworkIsPlayerActive(i) then
									Vehicle = GetVehiclePedIsUsing(GetPlayerPed(i))
									if VehicleBlacklist[tostring(GetEntityModel(Vehicle))] then
										if NetworkHasControlOfEntity(Vehicle) or NetworkRequestControlOfEntity(Vehicle) then
											SetVehicleEngineHealth(Vehicle, -4000.0)
										end
									end
								end
							end
						--end
					end
				end
}
return VehicleKiller