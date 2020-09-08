ESX = nil

TriggerEvent(Config.ESX, function(obj) ESX = obj end)

local activity = 0
local activitySource = 0
local cooldown = 0

RegisterServerEvent('hotong:pay')
AddEventHandler('hotong:pay', function(payment)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.addAccountMoney('black_money',tonumber(payment))
	
	--Add cooldown
	cooldown = Config.CooldownMinutes * 60000
end)

ESX.RegisterServerCallback('hotong:anycops',function(source, cb)
  local anycops = 0
  local playerList = ESX.GetPlayers()
  for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerjob = xPlayer.job.name
    if playerjob == Config.job then
      anycops = anycops + 1
    end
  end
  cb(anycops)
end)

ESX.RegisterServerCallback('hotong:isActive',function(source, cb)
  cb(activity, cooldown)
end)

RegisterServerEvent('hotong:registerActivity')
AddEventHandler('hotong:registerActivity', function(value)
	activity = value
	if value == 1 then
		activitySource = source
		--Send notification to cops
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if Config.private then
				if xPlayer.job.name == Config.job1 or 
					xPlayer.job.name == Config.job2 or
					xPlayer.job.name == Config.job3 or
					xPlayer.job.name == Config.job4 or
					xPlayer.job.name == Config.job5 then
						TriggerClientEvent('hotong:setcopnotification', xPlayers[i])
				end
			else
				TriggerClientEvent('hotong:setcopnotification', xPlayers[i])
			end
		end
	else
		activitySource = 0
	end
end)

RegisterServerEvent('hotong:alertcops')
AddEventHandler('hotong:alertcops', function(cx,cy,cz)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if Config.private then
			if xPlayer.job.name == Config.job1 or 
				xPlayer.job.name == Config.job2 or
				xPlayer.job.name == Config.job3 or
				xPlayer.job.name == Config.job4 or
				xPlayer.job.name == Config.job5 then
				TriggerClientEvent('hotong:setcopblip', xPlayers[i], cx,cy,cz)
			end
		else
			TriggerClientEvent('hotong:setcopblip', xPlayers[i], cx,cy,cz)
		end
	end
end)

RegisterServerEvent('hotong:stopalertcops')
AddEventHandler('hotong:stopalertcops', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if Config.private then
			if xPlayer.job.name == Config.job1 or 
				xPlayer.job.name == Config.job2 or
				xPlayer.job.name == Config.job3 or
				xPlayer.job.name == Config.job4 or
				xPlayer.job.name == Config.job5 then
					TriggerClientEvent('hotong:removecopblip', xPlayers[i])
			end
		else
			TriggerClientEvent('hotong:removecopblip', xPlayers[i])
		end
	end
end)

AddEventHandler('playerDropped', function ()
	local _source = source
	if _source == activitySource then
		--Remove blip for all cops
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if Config.private then
				if xPlayer.job.name == Config.job1 or 
					xPlayer.job.name == Config.job2 or
					xPlayer.job.name == Config.job3 or
					xPlayer.job.name == Config.job4 or
					xPlayer.job.name == Config.job5 then
						TriggerClientEvent('hotong:removecopblip', xPlayers[i])
				end
			else
				TriggerClientEvent('hotong:removecopblip', xPlayers[i])
			end
		end
		--Set activity to 0
		activity = 0
		activitySource = 0
	end
end)

--Cooldown manager
AddEventHandler('onResourceStart', function(resource)
	while true do
		Wait(5000)
		if cooldown > 0 then
			cooldown = cooldown - 5000
		end
	end
end)

-------------------------------------------------------------------------------------------------------
------------------------------------           HÒM THÍNH           ------------------------------------
-------------------------------------------------------------------------------------------------------

RegisterNetEvent('homthinh:dbhg')
AddEventHandler('homthinh:dbhg', function(crate)
  	TriggerClientEvent('homthinh:dbhgg',-1,crate)
end)

RegisterNetEvent('homthinh:db')
AddEventHandler('homthinh:db', function(crate)
  	TriggerClientEvent('homthinh:dbb',-1,crate)
end)

RegisterNetEvent('homthinh:xoa')
AddEventHandler('homthinh:xoa', function(crate)
  	TriggerClientEvent('homthinh:xoa',-1,crate)
end)

RegisterNetEvent('homthinh:givesung')
AddEventHandler('homthinh:givesung', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local randomChance = math.random(1, 100)

	-- SỐ HÒM THÍNH 

	local homthinh1 = Config.homthinh1
	local homthinh2 = Config.homthinh2
	local homthinh3 = Config.homthinh3
	local homthinh4 = Config.homthinh4

	-- SỐ LƯỢNG ĐẠN HOẶC ITEM 

	local soluong1 = Config.soluong1
	local soluong2 = Config.soluong2
	local soluong3 = Config.soluong3
	local soluong4 = Config.soluong4

	-- BẬT HÒM THÍNH NHẬN SÚNG

	if Config.homsung then
		if randomChance < 7 then
			xPlayer.addWeapon(homthinh1, soluong1)
		elseif randomChance > 6 and randomChance < 25 then
			xPlayer.addWeapon(homthinh2, soluong2)
		elseif randomChance > 24 and randomChance < 60 then
			xPlayer.addWeapon(homthinh3, soluong3)
		elseif randomChance > 59 then
			xPlayer.addWeapon(homthinh4, soluong4)
		end
	end

	-- BẬT HÒM THÍNH NHẬN ITEM

	if Config.homitem then
		if randomChance < 7 then
			xPlayer.addInventoryItem(homthinh1, soluong1)
		elseif randomChance > 6 and randomChance < 25 then
			xPlayer.addInventoryItem(homthinh2, soluong2)
		elseif randomChance > 24 and randomChance < 60 then
			xPlayer.addInventoryItem(homthinh3, soluong3)
		elseif randomChance > 59 then
			xPlayer.addInventoryItem(homthinh4, soluong4)
		end
	end
end)