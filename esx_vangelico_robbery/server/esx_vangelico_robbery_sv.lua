local rob = false
local robbers = {}
PlayersCrafting    = {}
local CopsConnected  = 0
ESX = nil
webhookURL = ''  -- Logs For People Trying Run Vangelico Script


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

RegisterServerEvent('esx_vangelico_robbery:toofar')
AddEventHandler('esx_vangelico_robbery:toofar', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at') .. Stores[robb].nameofstore)
			TriggerClientEvent('esx_vangelico_robbery:killblip', xPlayers[i])
		end
	end
	if(robbers[source])then
		TriggerClientEvent('esx_vangelico_robbery:toofarlocal', source)
		robbers[source] = nil
		TriggerClientEvent('esx:showNotification', source, _U('robbery_has_cancelled') .. Stores[robb].nameofstore)
	end
end)

RegisterServerEvent('esx_vangelico_robbery:endrob')
AddEventHandler('esx_vangelico_robbery:endrob', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('end'))
			TriggerClientEvent('esx_vangelico_robbery:killblip', xPlayers[i])
		end
	end
	if(robbers[source])then
		TriggerClientEvent('esx_vangelico_robbery:robberycomplete', source)
		robbers[source] = nil
		TriggerClientEvent('esx:showNotification', source, _U('robbery_has_ended') .. Stores[robb].nameofstore)
	end
end)

RegisterServerEvent('esx_vangelico_robbery:rob')
AddEventHandler('esx_vangelico_robbery:rob', function(robb)

	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	if Stores[robb] then

		local store = Stores[robb]

		if (os.time() - store.lastrobbed) < 600 and store.lastrobbed ~= 0 then

            TriggerClientEvent('esx_vangelico_robbery:togliblip', source)
			TriggerClientEvent('esx:showNotification', source, _U('already_robbed') .. (1800 - (os.time() - store.lastrobbed)) .. _U('seconds'))
			return
		end


		local cops = 0
		for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end


		if rob == false then

			if(cops >= Config.RequiredCopsRob)then

				rob = true
				for i=1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
					if xPlayer.job.name == 'police' then
							TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog') .. store.nameofstore)
							TriggerClientEvent('esx_vangelico_robbery:setblip', xPlayers[i], Stores[robb].position)
					end
				end

				TriggerClientEvent('esx:showNotification', source, _U('started_to_rob') .. store.nameofstore .. _U('do_not_move'))
				TriggerClientEvent('esx:showNotification', source, _U('alarm_triggered'))
				TriggerClientEvent('esx:showNotification', source, _U('hold_pos'))
			    TriggerClientEvent('esx_vangelico_robbery:currentlyrobbing', source, robb)
                CancelEvent()
				Stores[robb].lastrobbed = os.time()
			else
				TriggerClientEvent('esx_vangelico_robbery:togliblip', source)
				TriggerClientEvent('esx:showNotification', source, _U('min_two_police'))
			end
		else
			TriggerClientEvent('esx_vangelico_robbery:togliblip', source)
			TriggerClientEvent('esx:showNotification', source, _U('robbery_already'))
		end
	end
end)

RegisterServerEvent('esx_vangelico_robbery:gioielli')
AddEventHandler('esx_vangelico_robbery:gioielli', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local rndm = math.random(0, 2)
	--
    local id = source;
    local ids = ExtractIdentifiers(id);
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
	
	local ip = ids.ip;
    local gameLicense = ids.license;
	local discord = ids.discord;

	--
	if rob == false and xPlayer ~= nil then
		sendToDisc('**Banned**',	
		'**Player: **'  .. GetPlayerName(id) .. '\n' ..
		'**Server ID: **' .. tostring(id) .. '\n' ..
		'**Reason: **[Vangelico] Money Exploit\n' ..
		'**SteamID:** steam:' .. steam .. '\n' .. 
		'**License: **' .. gameLicense .. '\n' ..
		'**IP:**' .. ip:gsub("ip:", "") .. '\n' ..
		'**Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>\n' ..
		'**Discord UID: **' .. discord:gsub('discord:', '') .. '\n');
		TriggerEvent("banCheater", source,"[Vangelico] Money Exploit @myst#0001 | Don't Appeal Skid")
else
	if rndm == 0 then
		xPlayer.addInventoryItem('jewels', math.random(5, 15))
	end
	if rndm == 1 then
		xPlayer.addInventoryItem('rolex', math.random(5, 15))
	end
	if rndm == 2 then
		xPlayer.addInventoryItem('diamond', math.random(5, 15))
	end
	end
end)

function CountCops()

	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()

local function Craft(source)

	SetTimeout(5000, function()
		local xPlayer  = ESX.GetPlayerFromId(source)
		if PlayersCrafting[source] == true and CopsConnected >= Config.RequiredCopsSell and xPlayer ~= nil then

			local JewelsQuantity = xPlayer.getInventoryItem('jewels').count
			local RolexQuantity = xPlayer.getInventoryItem('rolex').count
			local DiamondQuantity = xPlayer.getInventoryItem('diamond').count
			local GoldBarQuantity = xPlayer.getInventoryItem('gold').count

			if JewelsQuantity < 1 then 
				TriggerClientEvent('esx:showNotification', source, _U('notenoughgold'))
			else   
                xPlayer.removeInventoryItem('jewels', 1)
                --Citizen.Wait(1000)
				xPlayer.addMoney(8000)
				
				Craft(source)
			end

			if RolexQuantity < 1 then 
				--TriggerClientEvent('esx:showNotification', source, _U('notenoughgold'))
			else   
                xPlayer.removeInventoryItem('rolex', 1)
                --Citizen.Wait(1000)
				xPlayer.addMoney(5000)
				
				Craft(source)
			end

			if DiamondQuantity < 1 then 
				--TriggerClientEvent('esx:showNotification', source, _U('notenoughgold'))
			else   
                xPlayer.removeInventoryItem('diamond', 1)
                --Citizen.Wait(1000)
				xPlayer.addMoney(16000)
				
				Craft(source)
			end

			if GoldBarQuantity < 1 then 
				--TriggerClientEvent('esx:showNotification', source, _U('notenoughgold'))
			else   
                xPlayer.removeInventoryItem('gold', 1)
                --Citizen.Wait(1000)
				xPlayer.addMoney(750)
				
				Craft(source)
			end
		else
			TriggerClientEvent('esx:showNotification', source, _U('copsforsell'))
		end
	end)
end

RegisterServerEvent('lester:vendita')
AddEventHandler('lester:vendita', function()
	local _source = source
	--
    local id = source;
    local ids = ExtractIdentifiers(id);
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
	
	local ip = ids.ip;
    local gameLicense = ids.license;
	local discord = ids.discord;
	--
	PlayersCrafting[_source] = true
	if PlayersCrafting[_source] == true then
	TriggerClientEvent('esx:showNotification', _source, _U('goldsell'))
	Craft(_source)
	else
		sendToDisc('**Banned**',	
		'**Player: **'  .. GetPlayerName(id) .. '\n' ..
		'**Server ID: **' .. tostring(id) .. '\n' ..
		'**Reason: **[Vangelico] Lester Vendita\n' ..
		'**SteamID:** steam:' .. steam .. '\n' .. 
		'**License: **' .. gameLicense .. '\n' ..
		'**IP:**' .. ip:gsub("ip:", "") .. '\n' ..
		'**Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>\n' ..
		'**Discord UID: **' .. discord:gsub('discord:', '') .. '\n');
		TriggerEvent("banCheater", source,"[Vangelico] Lester Vendita @myst#0001 | Don't Appeal Skid")
	end
end)

RegisterServerEvent('lester:gayndita')
AddEventHandler('lester:gayndita', function()
	local _source = source
	PlayersCrafting[_source] = false
end)



function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

function sendToDisc(title, message, footer)
    local embed = {}
    embed = {
		{
			["author"] = {
				name = "Project X",
				url = "https://discord.gg/crwGemuphM",
				icon_url = "https://cdn.discordapp.com/attachments/749509994944397313/772777128197750814/image0-453.gif"
			},
            ["color"] = 16711680, -- GREEN = 65280 --- RED = 16711680
            ["title"] = "**".. title .."**",
            ["description"] = "" .. message ..  "",
            ["footer"] = {
                ["text"] = "Made By myst#0001",
            },
        }
    }
    -- Start
    -- TODO Input Webhook
    PerformHttpRequest(webhookURL, 
    function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  -- END
end