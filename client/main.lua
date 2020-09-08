ESX = nil
local PlayerData              	= {}
local currentZone               = ''
local LastZone                  = ''
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local alldeliveries             = {}
local randomdelivery            = 1
local isTaken                   = 0
local isDelivered               = 0
local car						= 0
local copblip
local deliveryblip


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent(Config.ESX, function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

--Add all deliveries to the table
Citizen.CreateThread(function()
	local deliveryids = 1
	for k,v in pairs(Config.GiaoXe) do
		table.insert(alldeliveries, {
				id = deliveryids,
				posx = v.Pos.x,
				posy = v.Pos.y,
				posz = v.Pos.z,
				payment = v.Payment,
				car = v.Cars,
		})
		deliveryids = deliveryids + 1  
	end
end)

function SpawnCar()
	ESX.TriggerServerCallback('hotong:isActive', function(isActive, cooldown)
		if cooldown <= 0 then
			if isActive == 0 then
				ESX.TriggerServerCallback('hotong:anycops', function(anycops)
					if anycops >= Config.CopsRequired then

						--Get a random delivery point
						randomdelivery = math.random(1,#alldeliveries)
						
						--Delete vehicles around the area (not sure if it works)
						ClearAreaOfVehicles(Config.XeXuatHien.Pos.x, Config.XeXuatHien.Pos.y, Config.XeXuatHien.Pos.z, 10.0, false, false, false, false, false)
						
						--Delete old vehicle and remove the old blip (or nothing if there's no old delivery)
						SetEntityAsNoLongerNeeded(car)
						DeleteVehicle(car)
						RemoveBlip(deliveryblip)
						

						--Get random car
						randomcar = math.random(1,#alldeliveries[randomdelivery].car)

						--Spawn Car
						local vehiclehash = GetHashKey(alldeliveries[randomdelivery].car[randomcar])
						RequestModel(vehiclehash)
						while not HasModelLoaded(vehiclehash) do
							RequestModel(vehiclehash)
							Citizen.Wait(1)
						end
						car = CreateVehicle(vehiclehash, Config.XeXuatHien.Pos.x, Config.XeXuatHien.Pos.y, Config.XeXuatHien.Pos.z, Config.XeXuatHien.Pos.alpha, true, false)
						SetEntityAsMissionEntity(car, true, true)
						
						--Teleport player in car
						TaskWarpPedIntoVehicle(GetPlayerPed(-1), car, -1)
						
						--Set delivery blip
						deliveryblip = AddBlipForCoord(alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz)
						SetBlipSprite(deliveryblip, 1)
						SetBlipDisplay(deliveryblip, 4)
						SetBlipScale(deliveryblip, 1.0)
						SetBlipColour(deliveryblip, 5)
						SetBlipAsShortRange(deliveryblip, true)
						BeginTextCommandSetBlipName("CUSTOM_TEXT")
						AddTextComponentString("Delivery point")
						EndTextCommandSetBlipName(deliveryblip)
						
						SetBlipRoute(deliveryblip, true)

						--Register acitivity for server
						TriggerServerEvent('hotong:registerActivity', 1)
						
						--For delivery blip
						isTaken = 1
						
						--For delivery blip
						isDelivered = 0
					else
						ESX.ShowNotification(_U('not_enough_cops'))
					end
				end)
			else
				ESX.ShowNotification(_U('already_robbery'))
			end
		else
			ESX.ShowNotification(_U('cooldown', math.ceil(cooldown/1000)))
		end
	end)
end

function FinishDelivery()
  	if(GetVehiclePedIsIn(GetPlayerPed(-1), false) == car) and GetEntitySpeed(car) < 3 then
		
		--Delete Car
		SetEntityAsNoLongerNeeded(car)
		DeleteEntity(car)
		
    	--Remove delivery zone
    	RemoveBlip(deliveryblip)
	
		TriggerEvent('homthinh:NewOnPlayer',GetPlayerPed(-1))

    	--Pay the poor fella
		local finalpayment = alldeliveries[randomdelivery].payment
		TriggerServerEvent('hotong:pay', finalpayment)

		--Register Activity
		TriggerServerEvent('hotong:registerActivity', 0)

    	--For delivery blip
    	isTaken = 0

    	--For delivery blip
    	isDelivered = 1
		
		--Remove Last Cop Blips
    	TriggerServerEvent('hotong:stopalertcops')
		
  	else
		TriggerEvent('esx:showNotification', _U('car_provided_rule'))
  	end
end

function AbortDelivery()
	--Xóa Xe
	SetEntityAsNoLongerNeeded(car)
	DeleteEntity(car)
	TriggerEvent('homthinh:NewOnPlayer',GetPlayerPed(-1))

	--Xóa khu vực giao hàng
	RemoveBlip(deliveryblip)

	--Đăng ký hoạt động
	TriggerServerEvent('hotong:registerActivity', 0)

	--For delivery blip
	isTaken = 0

	--For delivery blip
	isDelivered = 1

	--Remove Last Cop Blips
	TriggerServerEvent('hotong:stopalertcops')
end

--Check if player left car
Citizen.CreateThread(function()
  while true do
    Wait(1000)
		if isTaken == 1 and isDelivered == 0 and GetEntityHealth(car) < 100 then
		AbortDelivery()			
		end
	end
end)

-- Send location
Citizen.CreateThread(function()
  	while true do
		Citizen.Wait(Config.BlipUpdateTime)
		if isTaken == 1 and IsPedInAnyVehicle(GetPlayerPed(-1)) then
			local coords = GetEntityCoords(GetPlayerPed(-1))
			TriggerServerEvent('hotong:alertcops', coords.x, coords.y, coords.z)
		elseif isTaken == 1 and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
			TriggerServerEvent('hotong:stopalertcops')
		end
  	end
end)

RegisterNetEvent('hotong:removecopblip')
AddEventHandler('hotong:removecopblip', function()
		RemoveBlip(copblip)
end)

RegisterNetEvent('hotong:setcopblip')
AddEventHandler('hotong:setcopblip', function(cx,cy,cz)
	RemoveBlip(copblip)
    copblip = AddBlipForCoord(cx,cy,cz)
    SetBlipSprite(copblip , 161)
    SetBlipScale(copblipy , 2.0)
	SetBlipColour(copblip, 8)
	PulseBlip(copblip)
end)

RegisterNetEvent('hotong:setcopnotification')
AddEventHandler('hotong:setcopnotification', function()
	ESX.ShowNotification(_U('car_stealing_in_progress'))
end)

AddEventHandler('hotong:hasEnteredMarker', function(zone)
  	if LastZone == 'menucarthief' then
		CurrentAction     = 'carthief_menu'
		CurrentActionMsg  = _U('steal_a_car')
		CurrentActionData = {zone = zone}
  	elseif LastZone == 'cardelivered' then
		CurrentAction     = 'cardelivered_menu'
		CurrentActionMsg  = _U('drop_car_off')
		CurrentActionData = {zone = zone}
  	end
end)

AddEventHandler('hotong:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
  	while true do
		Wait(0)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil         
		if(GetDistanceBetweenCoords(coords, Config.layxe.diemxe.Pos.x, Config.layxe.diemxe.Pos.y, Config.layxe.diemxe.Pos.z, true) < 1.5) then
			isInMarker  = true
			currentZone = 'menucarthief'
			LastZone    = 'menucarthief'
		end     
		if isTaken == 1 and (GetDistanceBetweenCoords(coords, alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz, true) < 1.5) then
			isInMarker  = true
			currentZone = 'cardelivered'
			LastZone    = 'cardelivered'
		end       
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('hotong:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('hotong:hasExitedMarker', LastZone)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
  	while true do
    Citizen.Wait(0)
		if CurrentAction ~= nil then
			SetTextComponentFormat('CUSTOM_TEXT')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'carthief_menu' then
				SpawnCar()
				elseif CurrentAction == 'cardelivered_menu' then
				FinishDelivery()
				end
				CurrentAction = nil
			end
		end
  	end
end)

-- Display markers
Citizen.CreateThread(function()
  	while true do
		Wait(0)
		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.layxe) do
			if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end  
  	end
end)

-- Display markers for delivery place
Citizen.CreateThread(function()
 	while true do
    	Wait(0)
		if isTaken == 1 and isDelivered == 0 then
			local coords = GetEntityCoords(GetPlayerPed(-1))
			v = alldeliveries[randomdelivery]
			if (GetDistanceBetweenCoords(coords, v.posx, v.posy, v.posz, true) < Config.DrawDistance) then
				DrawMarker(27, v.posx, v.posy, v.posz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 128, 255, 100, false, false, 2, false, false, false, false)
			end
		end
  	end
end)

-- Create Blips for Car Spawner
Citizen.CreateThread(function()
    info = Config.layxe.diemxe
    info.blip = AddBlipForCoord(info.Pos.x, info.Pos.y, info.Pos.z)
    SetBlipSprite(info.blip, info.Id)
    SetBlipDisplay(info.blip, 4)
    SetBlipScale(info.blip, 1.0)
    SetBlipColour(info.blip, info.Colour)
    SetBlipAsShortRange(info.blip, true)
    BeginTextCommandSetBlipName("CUSTOM_TEXT")
	AddTextComponentString(_U('vehicle_robbery'))
    EndTextCommandSetBlipName(info.blip)
end)


-------------------------------------------------------------------------------------------------------
------------------------------------           HÒM THÍNH           ------------------------------------
-------------------------------------------------------------------------------------------------------

local modelHash = {}
local chuteModel = 'p_cargo_chute_s'
local crates = {}
local baseTime = 5000
local timeStep = 1000
local boxModels  = {
	[1] = 'hei_prop_carrier_cargo_03a',
	[2] = 'hei_prop_carrier_cargo_04a',
	[3] = 'hei_prop_carrier_cargo_05a',
}

dbhgg = function(crate)
	crate.blip = MakeBlip(crate.pos)
	table.insert(crates,crate)
end

MakeBlip = function(pos)
	print("Making blip")
	local blip = AddBlipForCoord(pos.x,pos.y,pos.z)
	SetBlipSprite(blip,568)
	SetBlipDisplay(blip,2)
	SetBlipScale(blip,1.0)
	SetBlipColour(blip,5)
	SetBlipDisplay(blip,4)
	SetBlipAsShortRange(blip,true)
	SetBlipHighDetail(blip,true)
	BeginTextCommandSetBlipName("CUSTOM_TEXT")
	AddTextComponentString('Loot Crate')
	EndTextCommandSetBlipName(blip)
	return blip
end

dbb = function(crate)
	for k,v in pairs(crates) do
	  	if v.crateObj == crate.crateObj then
			local blip = v.blip
			crates[k] = crate
			crates[k].blip = blip
			return
	  	end
	end
	table.insert(crates,crate)
end

modelHash[chuteModel] = GetHashKey(chuteModel)
for k,v in pairs(boxModels) do
  	modelHash[v] = GetHashKey(v)
end

MissionEntities = function(entities)
	for k,v in pairs(entities) do
	 	SetEntityAsMissionEntity(v,true,true)
	end
end

LoadModels = function(models)
	for k,v in pairs(models) do
	 	RequestModel(v)
	  	while not HasModelLoaded(v) do 
			RequestModel(v); 
			Wait(0); 
		end
	end
end

NetworkObjects = function(objects)
	for k,v in pairs(objects) do
	  	while not NetworkGetEntityIsNetworked(v) do
			NetworkRegisterEntityAsNetworked(v)
			Wait(0)
	  	end
	end
end

UnloadModels = function(models)
	for k,v in pairs(models) do
	  	SetModelAsNoLongerNeeded(v)
	end
end

NetworkId = function(entity)
	return NetworkGetNetworkIdFromEntity(entity)
end

SpawnCrate = function(crate)
	LoadModels({modelHash[crate.model],modelHash[chuteModel]})
  
	local pos = crate.pos
	local chuteObj = CreateObject(modelHash[chuteModel], pos.x,pos.y,pos.z + 55.0, true,true,true)
	local crateObj = CreateObject(modelHash[crate.model],pos.x,pos.y,pos.z + 55.0, true,true,true)
  
	local min,max = GetModelDimensions(modelHash[crate.model])
	AttachEntityToEntity(chuteObj,crateObj, 0, 0.0,0.0,max.z, 0.0,0.0,0.0, false,true,true,false,0,false)
  
	MissionEntities({chuteObj,crateObj})
	NetworkObjects({chuteObj,crateObj})
	UnloadModels({modelHash[crate.model],modelHash[chuteModel]})
  
	crate.crateObj = NetworkId(crateObj)
	crate.chuteObj = NetworkId(chuteObj)
  
	TriggerServerEvent('homthinh:dbhg',crate)
  
	CrateFalling(crate)
end

CrateFalling = function(crate)
	Citizen.CreateThread(function() 
	  	local grounded = false
	  	while not grounded do
			local crateObj = NetworkGetEntityFromNetworkId(crate.crateObj)
			local pos = GetEntityCoords(NetworkGetEntityFromNetworkId(crate.crateObj))
  
			SetEntityCoords(crateObj, pos.x,pos.y,pos.z-0.02)
  
			grounded = (pos.z <= crate.pos.z)
			Wait(0)
	  	end
	  	local crateObj = NetworkGetEntityFromNetworkId(crate.crateObj)
	  	local chuteObj = NetworkGetEntityFromNetworkId(crate.chuteObj)
	  	PlaceObjectOnGroundProperly(crateObj)
	  	DeleteObject(chuteObj)
	  	crate.ground = true
	  	TriggerServerEvent('homthinh:db',crate)
	end)
end

NewOnPlayer = function() 
	local crate = NewCrate(GetEntityCoords(GetPlayerPed(-1)) - vector3(0.0,0.0,1.0))
	SpawnCrate(crate)
end

NewCrate = function(pos,tier)
	--[[ local crateTier = (tier or math.random(#weaponTiers))
	if crateTier <= 0 then 
		crateTier = 1 
	elseif crateTier > #weaponTiers then 
		crateTier = #weaponTiers; 
	end ]]
	local model = boxModels[math.random(#boxModels)]
	--local loot  = NewLoot(crateTier)
	local dimMin,dimMax = GetModelDimensions(model)
	return {
	  pos     = pos,
	  model   = model,
	  dimsMin = dimMin,
	  dimsMax = dimMax,
	  loot    = loot,
	  tier    = crateTier,
	  ground  = false,
	}
end

Event = function(e,h,n)
	if n then 
		RegisterNetEvent(e); 
	end
	AddEventHandler(e,h)
end

GetClosestCrate = function()
	local closest,closestDist
	local plyPos = GetEntityCoords(GetPlayerPed(-1))
	for k,v in pairs(crates) do
	  	if v.ground then
			local dist = Vdist(plyPos,v.pos)
			if not closestDist or dist < closestDist then
		  		closest = k
		  		closestDist = dist
			end
	  	end
	end
	return (closest or false),(closestDist or 9999)
end

Update = function()
	local keyPressed = false
	while true do
	  	local closest,dist = GetClosestCrate()
	  	local plyPed = GetPlayerPed(-1)
	  	if closest then
			local maxDist = crates[closest].dimsMax.x
			if crates[closest].dimsMax.y > maxDist then 
				maxDist = crates[closest].dimsMax.y; 
			end
			if crates[closest].dimsMax.z > maxDist then 
				maxDist = crates[closest].dimsMax.z; 
			end
  
			if dist < maxDist + 1.0 then
--[[ 				if IsControlJustPressed(0, 38) then
					keyPressed = GetGameTimer()
					--exports["progbars"]:StartProg(baseTime+(crates[closest].tier*timeStep)-300,"Opening Crate")
					TaskStartScenarioInPlace(plyPed, "PROP_HUMAN_BUM_BIN", 0, true) ]]
				if IsControlPressed(0, 38) then
					--if keyPressed then
						ShowHelp("<FONT FACE='arial font'><b>Giữ [~g~E~s~] để mở hòm thính.</b></FONT>")
						if not dead then
							--[[ TaskStartScenarioInPlace(plyPed, "PROP_HUMAN_BUM_BIN", 0, false)
							Wait(math.random(1000,2000))
							ClearPedTasksImmediately(plyPed) ]]
	
							if closest and crates and crates[closest] and crates[closest].crateObj and NetworkDoesEntityExistWithNetworkId(crates[closest].crateObj) and DoesEntityExist(NetworkGetEntityFromNetworkId(crates[closest].crateObj)) then
								
								TriggerEvent('mythic_progbar:client:progress', {
									name = 'Loot Thính',
									duration = 5000,
									label = 'Đang loot thính',
									useWhileDead = false,
									canCancel = true,
									controlDisables = {
										disableMovement = true,
										disableCarMovement = false,
										disableMouse = false,
										disableCombat = false,
									},
									animation = {
										animDict = nil,
										anim = nil,
										flags = 0,
										task = nil,
									},
									prop = {
										model = nil,
									},
								}, function(status)
									if not status then
										TriggerServerEvent('homthinh:xoa',crates[closest])
										DeleteObject(NetworkGetEntityFromNetworkId(crates[closest].crateObj))    
										TriggerServerEvent('homthinh:givesung')                      
										RemoveBlip(crates[closest].blip)
										crates[closest] = nil 
										ClearPedTasksImmediately(plyPed)
										exports['mythic_notify']:DoHudText('inform', 'Đã loot thính xong')
									end
								end)          
							end
	
							keyPressed = false
						end
					--end
--[[ 				elseif IsControlJustReleased(0, 38) then
					if keyPressed then
						keyPressed = false
						--exports["progbars"]:CloseProg()
						TaskStartScenarioInPlace(plyPed, "PROP_HUMAN_BUM_BIN", 0, false)
						Wait(1500)
						ClearPedTasksImmediately(plyPed)
					end ]]  
				else
					ShowHelp("<FONT FACE='arial font'><b>Giữ [~g~E~s~] để mở hòm thính.</b></FONT>")    
				end
			else
				if keyPressed then
					keyPressed = false
					--exports["progbars"]:CloseProg()
					TaskStartScenarioInPlace(plyPed, "PROP_HUMAN_BUM_BIN", 0, false)
					Wait(1500)
					ClearPedTasksImmediately(plyPed)
				end
			end
		else
			if keyPressed then
				keyPressed = false
				--exports["progbars"]:CloseProg()
				TaskStartScenarioInPlace(plyPed, "PROP_HUMAN_BUM_BIN", 0, false)
				Wait(1500)
				ClearPedTasksImmediately(plyPed)
			end      
	  	end
	  	Wait(0)
	end
end

ShowHelp = function(msg)
	AddTextEntry('homthinh:ShowHelp', msg)
	BeginTextCommandDisplayHelp('homthinh:ShowHelp')
	EndTextCommandDisplayHelp(0, false, true, -1)
end

xoa = function(crate)
	for k,v in pairs(crates) do
	  	if v.crateObj == crate.crateObj then
			if NetworkDoesEntityExistWithNetworkId(crate.crateObj) and DoesEntityExist(NetworkGetEntityFromNetworkId(crate.crateObj)) then
		  		local ent = NetworkGetEntityFromNetworkId(crate.crateObj)
		  		NetworkRequestControlOfEntity(ent)
				  	while not NetworkHasControlOfEntity(ent) do 
						NetworkRequestControlOfEntity(ent); Wait(0); 
					end
		  		SetEntityAsMissionEntity(ent,true,true)
		  		DeleteEntity(ent)
			end              
			RemoveBlip(crates[k].blip)
			for key,val in pairs(crates[k]) do 
				crates[k][key] = nil; 
			end
			crates[k] = nil
	  	end
	end
end

Event('homthinh:dbb',dbb,1)
Event('homthinh:dbhgg',dbhgg,1)
Event('homthinh:NewOnPlayer',NewOnPlayer,1)
Event('homthinh:xoa',xoa,1)

Citizen.CreateThread(Update)