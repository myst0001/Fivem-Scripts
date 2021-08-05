--[[
==================  Script Created By : apoiat  ==================
~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
==================    Protected By : myst#0001    ==================
~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
]]--


ESX = nil
webhookURL = '' -- For Skids Trying To Comserv
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


TriggerEvent('es:addGroupCommand', 'comserv', 'admin', function(source, args, user)
	if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
		local identifier = GetPlayerIdentifiers(args[1])[1]
		local id = source;
		local ids = ExtractIdentifiers(id);
		local steam = ids.steam:gsub("steam:", "");
		local target = args[1]
		local targetname = GetPlayerName(args[1])
		local targetsteamhex = GetPlayerIdentifier(args[1])

		MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
			['@identifier'] = identifier
		}, function(result)
			if result[1] then
				MySQL.Async.execute('UPDATE communityservice SET actions_remaining = @actions_remaining WHERE identifier = @identifier', {
					['@identifier'] = identifier,
					['@actions_remaining'] = tonumber(args[2])
				})
			else
				MySQL.Async.execute('INSERT INTO communityservice (identifier, actions_remaining) VALUES (@identifier, @actions_remaining)', {
					['@identifier'] = identifier,
					['@actions_remaining'] = tonumber(args[2])
				})
			end
		end)
		y
	TriggerClientEvent('esx_policejob:unrestrain', args[1])
	TriggerClientEvent('esx_communityservice:inCommunityService', args[1], tonumber(args[2]))
	TriggerEvent('DiscordBot:ToDiscord', 'police', 'Community Service - Staff', '```ID:'..tostring(id)..' '.. GetPlayerName(id) ..' ('..steam..') | comserved ID:'..target..' '..targetname.. ' ('..targetsteamhex..') | Actions:' ..args[2]..' ```', 'IMAGE_URL', true)

	else
		TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id_or_actions') } } )
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
end, {help = _U('give_player_community'), params = {{name = "id", help = _U('target_id')}, {name = "actions", help = _U('action_count_suggested')}}})
_U('system_msn')


TriggerEvent('es:addGroupCommand', 'endcomserv', 'admin', function(source, args, user)
	if args[1] then
		if GetPlayerName(args[1]) ~= nil then
			local id = source;
			local ids = ExtractIdentifiers(id);
			local steam = ids.steam:gsub("steam:", "");
			local target = args[1]
			local targetname = GetPlayerName(args[1])
			local targetsteamhex = GetPlayerIdentifier(args[1])
			TriggerEvent('esx_communityservice:endCommunityServiceCommand', tonumber(args[1]))
			TriggerEvent('DiscordBot:ToDiscord', 'police', 'End Community Service - Staff', '```ID:'..tostring(id)..' '.. GetPlayerName(id) ..' ('..steam..') | removed comserv from ID:'..target..' '..targetname.. ' ('..targetsteamhex..') ```', 'IMAGE_URL', true)

		else
			TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id')  } } )
		end
	else
		TriggerEvent('esx_communityservice:endCommunityServiceCommand', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
end, {help = _U('unjail_people'), params = {{name = "id", help = _U('target_id')}}})



--[[RegisterCommand("comservconsole", function(source, args, rawCommand)	-- comserv (can be used from console)
	canRevive = false
	if source == 0 then
		canRevive = true
	if canRevive and GetPlayerName(args[1]) ~= nil then
		TriggerEvent('esx_communityservice:sendToCommunityService', tonumber(args[1]), tonumber(args[2]))
	print("Comserved: ", GetPlayerName(args[1]), " For: " ..tonumber(args[2]))
		end
	end
end, false)--]]

RegisterCommand("endcomservconsole", function(source, args, rawCommand)	-- endcomserv (can be used from console)
	canRevive = false
	if source == 0 then
		canRevive = true
	if canRevive and GetPlayerName(args[1]) ~= nil then
		TriggerEvent('esx_communityservice:endCommunityServiceCommand', tonumber(args[1]))
	print("Removed Comserv From: ", GetPlayerName(args[1]))
		end
	end
end, false)





RegisterServerEvent('esx_communityservice:endCommunityServiceCommand')
AddEventHandler('esx_communityservice:endCommunityServiceCommand', function(source)
	if source ~= nil then
		releaseFromCommunityService(source)
	end
end)

-- unjail after time served
RegisterServerEvent('esx_communityservice:finishCommunityService')
AddEventHandler('esx_communityservice:finishCommunityService', function()
	releaseFromCommunityService(source)
end)





RegisterServerEvent('esx_communityservice:completeService')
AddEventHandler('esx_communityservice:completeService', function()

	local _source = source
	local identifier = GetPlayerIdentifiers(_source)[1]

	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			MySQL.Async.execute('UPDATE communityservice SET actions_remaining = actions_remaining - 1 WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})
		else
			print ("ESX_CommunityService :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)




RegisterServerEvent('esx_communityservice:extendService')
AddEventHandler('esx_communityservice:extendService', function()

	local _source = source
	local identifier = GetPlayerIdentifiers(_source)[1]

	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			MySQL.Async.execute('UPDATE communityservice SET actions_remaining = actions_remaining + @extension_value WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@extension_value'] = Config.ServiceExtensionOnEscape
			})
		else
			print ("ESX_CommunityService :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)


RegisterServerEvent('esx_communityservice:sendToCommunityService')
AddEventHandler('esx_communityservice:sendToCommunityService', function(target, actions_count)

	local identifier = GetPlayerIdentifiers(target)[1]
	local id = source;
	local ids = ExtractIdentifiers(id);
	local steam = ids.steam:gsub("steam:", "");
	local steamDec = tostring(tonumber(steam,16));
	local _source = source
--	local steamhex = GetPlayerIdentifier(source)
	local xPlayer = ESX.GetPlayerFromId(_source)
	local targetname = GetPlayerName(target)
	local targetsteamhex = GetPlayerIdentifier(target)
	local ip = ids.ip;
	local gameLicense = ids.license;
	local discord = ids.discord;


	if xPlayer ~= nil and xPlayer.job.name ~= 'police' then -- 
		sendToDisc('**Banned**',
		'**Player: **'  .. GetPlayerName(id) .. '\n' ..
		'**Server ID: **' .. tostring(id) .. '\n' ..
		'**Reason: **[ESX_COMMUNITYSERVICE] Attempted To Com Serv\n' ..
		'**Job: **' .. xPlayer.job.name .. '\n' ..
		'**Target: **' .. target .. '\n' ..
		'**Actions: **' .. actions_count .. '\n' ..
		'**SteamID:** steam:' .. steam .. '\n' ..
		'**License: **' .. gameLicense .. '\n' ..
		'**IP: **' .. ip:gsub("ip:", "") .. '\n' ..
		'**Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>\n' ..      --[[Drops And Bans Player Also Creates A Log In Discord]]
		'**Discord UID: **' .. discord:gsub('discord:', '') .. '\n');
		TriggerEvent("banCheater", source,"[esx_communityservice] Attempted To Com Serv For | Don't Appeal Skid")
	--	DropPlayer(source, "[Ban Him] Tried To Give Community Service: "..actions_count,true) -- Drops player from the game (from here you can ban him)
else if xPlayer ~= nil then
	TriggerEvent('DiscordBot:ToDiscord', 'police', 'Community Service - Police', '```ID:'..tostring(id)..' '.. GetPlayerName(id) ..' ('..steam..') | comserved ID:'..target..' '..targetname.. ' ('..targetsteamhex..') | Actions:' ..actions_count..' ```', 'IMAGE_URL', true)
	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE communityservice SET actions_remaining = @actions_remaining WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		else
			MySQL.Async.execute('INSERT INTO communityservice (identifier, actions_remaining) VALUES (@identifier, @actions_remaining)', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		end
	end)
	TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_msg', GetPlayerName(target), actions_count) }, color = { 147, 196, 109 } })
TriggerClientEvent('esx_policejob:unrestrain', target)
TriggerClientEvent('esx_communityservice:inCommunityService', target, actions_count)
	 end
	end
end)



RegisterServerEvent('esx_communityservice:checkIfSentenced')
AddEventHandler('esx_communityservice:checkIfSentenced', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local identifier = GetPlayerIdentifiers(_source)[1] -- get steam identifier

	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] ~= nil and result[1].actions_remaining > 0 then
		--	TriggerClientEvent('chat:addMessage', _source, { template = '<div style="padding: 0.6vw; margin: 0.6vw; background-color: rgba(0, 255, 0, 0.4); border-radius: 3px;">🧹Community Service:<br> {1}<br></div>', args = { _U('judge'), _U('jailed_msg', GetPlayerName(_source), ESX.Math.Round(result[1].jail_time / 60)) }, color = { 147, 196, 109 } })
			TriggerClientEvent('esx_communityservice:inCommunityService', _source, tonumber(result[1].actions_remaining))
		end
	end)
end)



function releaseFromCommunityService(target)

	local identifier = GetPlayerIdentifiers(target)[1]
	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('DELETE from communityservice WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})

			TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_finished', GetPlayerName(target)) }, color = { 147, 196, 109 } })
		end
	end)
	TriggerClientEvent('esx_communityservice:finishCommunityService', target)
end

-- Discord Log Func.
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