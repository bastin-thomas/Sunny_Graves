local VorpCore = {}

local checkPD = 0

TriggerEvent("getCore",function(core)
    VorpCore = core
end)
local VorpInv = exports.vorp_inventory:vorp_inventoryApi()


function SendWebhook(webhook, source, text)
	local time = os.date("%d/%m/%Y %X")
	local name = GetPlayerName(source)
	local identifier = GetPlayerIdentifiers(source)
    local User = VorpCore.getUser(source)
    local Character = User.getUsedCharacter
    local playerName = Character.firstname
	local playerLame = Character.lastname
	local data = "Pillage de tombe ➝ ".. time .. ' : ' .. playerName ..' '..playerLame..' ➝ ' .. text
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = data}), { ['Content-Type'] = 'application/json' })
end


RegisterServerEvent('vajco:coords')
AddEventHandler('vajco:coords', function(source)
    local _source = source;
    local playercoords = GetEntityCoords(GetPlayerPed(_source));
    local Coords = {};
    Coords.x, Coords.y, Coords.z = table.unpack(playercoords);

    local hasbeenfound = false;

    if Config.Debug == true then
        print("Vérification Coordonnée")
    end

    for i, cimetiere in ipairs(Config.Graveryard) do
        local dist = getDistance(Coords, cimetiere)

        if Config.Debug == true then
            print("Distance Cimetiere ".. cimetiere.ZoneName .." : " .. cimetiere.distance.. " | " .. dist);
        end

        if dist < cimetiere.distance then
            if Config.Debug == true then
                print("Cimetière Trouvé, Trigger:  [GraveRobbing:TriggerRobbery]")
            end
            local check = checkHour(Config.RealHourStart, Config.RealHourStop);
            if(Config.Debug == true) then
                print("CheckHour: " .. tostring(check));
            end
            TriggerClientEvent("GraveRobbing:TriggerRobbery",  _source, cimetiere.ZoneName, check);
            hasbeenfound = true;
            break;            
        end
    end

    if(hasbeenfound == false) then
        if Config.Debug == true then
            print("Cimetière Non Trouvé")
        end
        TriggerClientEvent('vorp:TipBottom', _source, 'Tu ne trouvera rien ici', 5000);
    end
end)


RegisterServerEvent('vajco:canI')
AddEventHandler('vajco:canI', function(source)

    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local Coords = json.decode(Character.coords)

    --checkPD = checkPDreq()
    --if checkPD == 0 then
    --TriggerClientEvent('vorp:TipBottom', _source, 'Il n\'y a pas assez de shérifs', 5000)   
    --elseif checkPD == 1 then
	--SendWebhook(Config.webhook, _source, "Pouvez-vous creuser ?? (1 oui 0 non) -" .. checkPD) -- for webhook
    
    --end
end)

-----police notify-----------
RegisterNetEvent("policenotify:CheckJob")
AddEventHandler("policenotify:CheckJob", function(Name)
    local user = VorpCore.getUser(source).getUsedCharacter
    if user ~= nil then
        for i, jobcall in ipairs(Config.jobcall) do
            if user.job == jobcall then
                if Config.Debug == true then
                    print("JobFound");
                end
                TriggerClientEvent("hrobar:NotificatePlayer", source, Name);
            end
        end
    end
end)

RegisterNetEvent("policenotify2")
AddEventHandler("policenotify2", function(Name)
    TriggerClientEvent("hrobar:ToggleNotification2", -1, Name);
end)

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

RegisterNetEvent('sdrp:graverobbingreward')
AddEventHandler('sdrp:graverobbingreward', function(player)
   local _source = source
   local number = math.random(1,getTableSize(Config.items))
   local randomitem = (Config.items[number])
   local number2 = math.random(1,getTableSize(Config.items))
   local randomitem2 = (Config.items[number2])
   
   VorpInv.addItem(_source, randomitem, 1)
   VorpInv.addItem(_source, randomitem2, 1)

   SendWebhook(Config.webhook, _source, "Il a trouvé - " .. randomitem .. " " .. 1 .. " pièces") --webhook thing
   SendWebhook(Config.webhook, _source, "Il a trouvé - " .. randomitem2 .. " " .. 1 .. " pièces") --webhook thing
end)


--Check if actually between 2 hour
function checkHour(hBeg, hEnd)
    local time = os.date("*t");
    local currentHour = time.hour;
    
    if(Config.Debug == true) then
        print("Actual Time: " .. time.hour);
        print("hBeg: " .. hBeg);
        print("hEnd: " .. hEnd);
    end

    if((time.hour >= hBeg and time.hour < hEnd)) then
       return true; 
    end

    return false;
end


function getDistance(A, B)
    local x = B.x - A.x
    local y = B.y - A.y
    local z = B.z - A.z
    return math.sqrt((x ^ 2) + (y ^ 2) + (z ^ 2))
end
