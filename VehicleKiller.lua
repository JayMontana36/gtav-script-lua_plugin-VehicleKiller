--[[ Meticulously Crafted by JayMontana36 | This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA. ]]





--[[ Config Area ]]
local CheckNearby	= false	--[[ Set this to true if you want this script to check vehicles near players (including vehicles in use by players); Set this to false if you want this script to only check vehicles that players are currently using. ]]
local AlwaysActive	= false	--[[ Set this to true if you want this script to always run regardless of the TriggerKey being pressed or not. ]]
local RunWhileHeld	= false	--[[ Set this to true if you want this script to loop-run while the TriggerKey is being held down; Set this to false if you want this script to only run once for every one press of the TriggerKey. ]]
local DeleteVehicle	= false --[[ Set this to true if you want this script to delete the vehicle; Set this to false if you want this script to kill the engine. ]]
local MaxNearbyVehs	= 4		--[[ Can be any integer number above 0. This number is per player; the closest (4 by default) vehicles (that your game knows about) near players will be checked, if CheckNearby is set to true. ]]
local TriggerKey	= 223	--[[ 223	INPUT_SCRIPT_RDOWN	LEFT MOUSE BUTTON	A | Default TriggerKey; https://docs.fivem.net/docs/game-references/controls/ for alternate keys. ]]



local VehicleBlacklist	= { -- Format: '"VehicleSpawnByNameCode",'
	"oppressor2",	--Oppressor MK2
}





--[[ Script/Code Area ]]
local PAD = CONTROLS--Added/Used due to FiveM differences, for people who are more familiar with FiveM Lua scripting than GTA V Lua Plugin Scripting, same with a lot of the natives below.

local GetHashKey					= GAMEPLAY.GET_HASH_KEY
local IsControlPressed if RunWhileHeld then IsControlPressed = PAD.IS_CONTROL_PRESSED else IsControlPressed = PAD.IS_CONTROL_JUST_PRESSED end
local NetworkIsPlayerActive			= NETWORK.NETWORK_IS_PLAYER_ACTIVE
local GetVehiclePedIsUsing			= PED.GET_VEHICLE_PED_IS_USING
local GetPlayerPed					= PLAYER.GET_PLAYER_PED
local GetPedNearbyVehicles			= PED.GET_PED_NEARBY_VEHICLES
local GetEntityModel				= ENTITY.GET_ENTITY_MODEL
local NetworkHasControlOfEntity		= NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY
local NetworkRequestControlOfEntity	= NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY
local SetEntityAsMissionEntity		= ENTITY.SET_ENTITY_AS_MISSION_ENTITY
local DeleteEntity					= ENTITY.DELETE_ENTITY
local SetVehicleEngineHealth		= VEHICLE.SET_VEHICLE_ENGINE_HEALTH



local _VehicleBlacklist, ActivePlayers, CheckedVehicles, Vehicle = {}, {}, nil, nil

local VehicleKiller =
{
	init	=	function()
					for i=1, #VehicleBlacklist do
						_VehicleBlacklist[GetHashKey(VehicleBlacklist[i])] = true
					end
					VehicleBlacklist = nil
				end,
	tick	=	function()
					if AlwaysActive or IsControlPressed(0, TriggerKey) then
						if CheckNearby then
							CheckedVehicles = {}
							
							for i=0,31 do
								ActivePlayers[i] = NetworkIsPlayerActive(i)
								if ActivePlayers[i] then
									ActivePlayers[i] = GetPlayerPed(i)
								end
							end
							
							for i=0,31 do
								if ActivePlayers[i] then
									NearbyVehs, NearbyVehsNum = GetPedNearbyVehicles(ActivePlayers[i], MaxNearbyVehs)
									for j=1,NearbyVehsNum do
										Vehicle = NearbyVehs[j]
										if not CheckedVehicles[Vehicle] then
											if _VehicleBlacklist[GetEntityModel(Vehicle)] then
												if NetworkHasControlOfEntity(NearbyVehs[j]) or NetworkRequestControlOfEntity(NearbyVehs[j]) then
													if DeleteVehicle then
														SetEntityAsMissionEntity(Vehicle, true, true)
														DeleteEntity(Vehicle)
													else
														SetVehicleEngineHealth(Vehicle, -4000.0)
													end
													CheckedVehicles[Vehicle] = true
												end
											else
												CheckedVehicles[Vehicle] = true
											end
										end
									end
								end
							end
						else
							for i=0,31 do
								if NetworkIsPlayerActive(i) then
									Vehicle = GetVehiclePedIsUsing(GetPlayerPed(i))
									if _VehicleBlacklist[GetEntityModel(Vehicle)] then
										if NetworkHasControlOfEntity(Vehicle) or NetworkRequestControlOfEntity(Vehicle) then
											if DeleteVehicle then
												SetEntityAsMissionEntity(Vehicle, true, true)
												DeleteEntity(Vehicle)
											else
												SetVehicleEngineHealth(Vehicle, -4000.0)
											end
										end
									end
								end
							end
						end
					end
				end
}
return VehicleKiller