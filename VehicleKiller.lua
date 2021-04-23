--[[ Meticulously Crafted by JayMontana36 | This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA. ]]





--[[ Config Area ]]
-- See VehicleKiller.ini file





--[[ Script/Code Area ]]
local IsTriggerTrue
local GetHashKey, NetworkIsPlayerActive, GetVehiclePedIsUsing, GetPlayerPed, GetPedNearbyVehicles, GetEntityModel, NetworkHasControlOfEntity, NetworkRequestControlOfEntity, SetEntityAsMissionEntity, DeleteEntity, SetVehicleEngineHealth
	= GetHashKey, NetworkIsPlayerActive, GetVehiclePedIsUsing, GetPlayerPed, GetPedNearbyVehicles, GetEntityModel, NetworkHasControlOfEntity, NetworkRequestControlOfEntity, SetEntityAsMissionEntity, DeleteEntity, SetVehicleEngineHealth



local _VehicleBlacklist, ActivePlayers, CheckedVehicles, Vehicle = {}, {}, nil, nil
local CheckNearby, AlwaysActive, RunWhileHeld, DeleteVehicle, MaxNearbyVehs, TriggerKey
return {
	init	=	function()
					local Config = configFileRead("VehicleKiller.ini")
					
					local tonumber = tonumber
					CheckNearby = Config.CheckNearby == "true"
					AlwaysActive = Config.AlwaysActive == "true"
					RunWhileHeld = Config.RunWhileHeld == "true"
					if RunWhileHeld then IsTriggerTrue = IsControlPressed else IsTriggerTrue = IsControlJustPressed end
					DeleteVehicle = Config.DeleteVehicle == "true"
					MaxNearbyVehs = tonumber(Config.MaxNearbyVehs)
					TriggerKey = tonumber(Config.TriggerKey)
					
					local tostring = tostring
					local i = "1"
					while Config[i] do
						_VehicleBlacklist[GetHashKey(Config[i])] = true
						i = tostring(i+1)
					end
				end,
	loop	=	function(Info)
					if AlwaysActive or IsTriggerTrue(0, TriggerKey) then
						local PlayersVehicle = Info.Player.Vehicle.Id
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
										if Vehicle ~= PlayersVehicle and not CheckedVehicles[Vehicle] then
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
									if Vehicle ~= PlayersVehicle and _VehicleBlacklist[GetEntityModel(Vehicle)] then
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