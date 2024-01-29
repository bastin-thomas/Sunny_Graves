local gravestones = { "p_grave06x", "p_gravedugcover01x", "p_gravefresh01x", "p_gravemarker01x", "p_gravemarker02x", "p_gravestone_srd08x", "p_gravestone01ax", "p_gravestone01x", "p_gravestone03ax", "p_gravestone03x", "p_gravestone04x",                                               -- generic | p_graveyard.rpf
"p_gravestone05x", "p_gravestone06x", "p_gravestone07ax",  "p_gravestone07x",  "p_gravestone08ax", "p_gravestone08x", "p_gravestone09x", "p_gravestone14ax", "p_gravestone14x", "p_gravestone16ax", "p_gravestone16x",                                               -- generic | p_graveyard.rpf
"p_gravestonebroken01x", "p_gravestonebroken02x", "p_gravestonebroken05x", "p_gravestoneclean02ax", "p_gravestoneclean02x", "p_gravestoneclean03x", "p_gravestoneclean04ax",
"p_gravestoneclean04x", "p_gravestoneclean05ax", "p_gravestoneclean05x", "p_gravestoneclean06ax", "p_gravestoneclean06x", "p_gravestonejanedoe02x" }

local cooldown = 0
local hour = GetClockHours()
local Ped = PlayerPedId()
local Coords = GetEntityCoords(Ped)

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end

    return players
end



RegisterNetEvent('GraveRobbing:TriggerRobbery')
AddEventHandler('GraveRobbing:TriggerRobbery', function(Name, realhourCheck)

	if(realhourCheck == false) then
		if(Config.Debug == true) then
			print("Real Hour Check: " .. tostring(realhourCheck));
		end
		TriggerEvent('vorp:TipBottom', 'Le pillage de tombe est actif uniquement entre ' .. Config.RealHourStart .. 'h ' .. 'et ' .. Config.RealHourStop ..'h.', 5000);
		return;
	end



	if cooldown == 0 then
		hour = GetClockHours()
		if (hour > Config.gameHourStart or hour < Config.gameHourStop) then
			
			local Coords = GetEntityCoords(PlayerPedId())
			local x, y, z = table.unpack(Coords)
			local gravefound = false;

			for key, value in pairs(gravestones) do
				local gravestone = DoesObjectOfTypeExistAtCoords(x, y, z, 2.0, GetHashKey(value), true)
		
				if gravestone then
					local chance = math.random(1,100)
					gravefound = true;

					if(chance <= 33) then
						TriggerServerEvent("policenotify2", Name);
					end

					if chance <= Config.chancehrob then

						TriggerEvent("progressbar:hb")

						Wait(15000)

						TriggerServerEvent("sdrp:graverobbingreward", GetPlayerPed())
						TriggerEvent('vorp:TipBottom', 'Vous récupérez quelques choses', 5000)
					else
						TriggerEvent("progressbar:hb")

						Wait(15000)
			
						TriggerEvent('vorp:TipBottom', 'La tombe est vide', 5000)		
					end
					RunCooldown()
					break
				end
			end
			
			if(gravefound == false)then
				if(Config.Debug == true) then
					print("Dans le cimetière, mais pas de tombe proche");
				end
				TriggerEvent('vorp:TipBottom', 'Approchez vous d \'une tombe', 5000);
			end
		else
			
			local Water = Citizen.InvokeNative(0x5BA7A68A346A5A91, GetEntityCoords(PlayerPedId()))
			if Config.Debug == true then
				print("Trop tôt pour les morts " .. tostring(Water) );
			end
			if Water == false then
				TriggerEvent("vorp:TipBottom", "Il est trop tôt pour réveiller les morts !", 6000)
			end
		end		
	else
	TriggerEvent("vorp:TipBottom", "Attendez quelques minutes, quelqu'un pourrait regarder", 6000)
	end
end)

RegisterNetEvent('progressbar:hb')
AddEventHandler('progressbar:hb', function()
    FreezeEntityPosition(PlayerPedId(), true)
    local playerPed = PlayerPedId()
	TriggerEvent("animation:hb")
	exports.gum_progressbars:DisplayProgressBar(15000)
	ClearPedTasksImmediately(GetPlayerPed())
    FreezeEntityPosition(PlayerPedId(), false)
end)

function playCustomAnim(dict,name, time, flag)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
	TaskPlayAnim(PlayerPedId(), dict, name, 1.0, 1.0, time, flag, 0, true, 0, false, 0, false)  
end

RegisterNetEvent('animation:hb')
AddEventHandler('animation:hb', function()
    local Get_Coords = GetEntityCoords(PlayerPedId())
	local ped = PlayerPedId()
    playCustomAnim("amb_work@world_human_gravedig@working@female_b@idle_a","idle_a", 15000, 1)
    shovel_hand = CreateObject("p_shovel02x", Get_Coords.x, Get_Coords.y, Get_Coords.z, true, true, false)
    AttachEntityToEntity(shovel_hand, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.15, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
    Citizen.Wait(15000)
    DeleteEntity(shovel_hand)
end)

function RunCooldown()
	cooldown = Config.cooldown
	while cooldown > 0 do
		Wait(1000)
		cooldown = cooldown - 1
	end
end

-- string, int, string, bool, bool, bool, int
function StartAnimation(animDict,flags,playbackListName,p3,p4,groundZ,time)
	Citizen.CreateThread(function()
		local player = PlayerPedId()
		local aCoord = GetEntityCoords(player)
		local pCoord = GetOffsetFromEntityInWorldCoords(PlayerPedId(), -10.0, 0.0, 0.0)

		local pRot = GetEntityRotation(player)

		if groundZ then
			local a, groundZ = GetGroundZAndNormalFor_3dCoord( aCoord.x, aCoord.y, aCoord.z + 10 )
			aCoord = {x=aCoord.x, y=aCoord.y, z=groundZ}
		end

		local animScene = Citizen.InvokeNative(0x1FCA98E33C1437B3, animDict, flags, playbackListName, 0, 1)
		-- SET_ANIM_SCENE_ORIGIN
		Citizen.InvokeNative(0x020894BF17A02EF2, animScene, aCoord.x, aCoord.y, aCoord.z, pRot.x, pRot.y, pRot.z, 2) 
		-- SET_ANIM_SCENE_ENTITY
		Citizen.InvokeNative(0x8B720AD451CA2AB3, animScene, "player", player, 0)
	    
	    	-- DIG UP A CHEST
	    	--local chest = CreateObjectNoOffset(GetHashKey('p_strongbox_muddy_01x'), pCoord, true, true, false, true)
	    	--Citizen.InvokeNative(0x8B720AD451CA2AB3, animScene, "CHEST", chest, 0)

	    	-- LOAD_ANIM_SCENE
	    	Citizen.InvokeNative(0xAF068580194D9DC7, animScene) 
	    	Citizen.Wait(1000)
	    	-- START_ANIM_SCENE
	    	Citizen.InvokeNative(0xF4D94AF761768700, animScene) 
	    	if time then
	    		Citizen.Wait(tonumber(time))	
	    	else
	   		Citizen.Wait(10000) 
	    	end
			
	    	-- SET CHEST AS OPENED AFTER DUG UP
	    	-- Citizen.InvokeNative(0x188F8071F244B9B8, chest, 1) -- found native sets CHEST as OPENED		
	    	
		-- _DELETE_ANIM_SCENE
	    	Citizen.InvokeNative(0x84EEDB2C6E650000, animScene) 
   	end) 
end

--- DIG UP AND FIND NOTHING
--StartAnimation('script@mech@treasure_hunting@nothing',0,'PBL_NOTHING_01',0,1,true,10000)

--- DIG UP AND GRAB SOMETHING
-- StartAnimation('script@mech@treasure_hunting@grab',0,'PBL_GRAB_01',0,1,true,10000)

--- DIG UP CHEST ( NOTE: UNCOMMENT LINES to spawn chest )
-- StartAnimation('script@mech@treasure_hunting@chest',0,'PBL_CHEST_01',0,1,true,10000)


------Police notify-------
RegisterNetEvent("hrobar:NotificatePlayer")
AddEventHandler("hrobar:NotificatePlayer", function(Name)
TriggerEvent('vorp:NotifyLeft', "Temoin", "Quelqu\'un pille des tombes au cimetière de " .. Name .. ".", "multiwheel_emotes", "emote_action_listen_1", 10000, "COLOR_WHITE")
end)

RegisterNetEvent("hrobar:ToggleNotification2")
AddEventHandler("hrobar:ToggleNotification2", function(Name)
	if Config.Debug == true then
		print("Notify To Checkjob");
	end

	TriggerServerEvent("policenotify:CheckJob", Name);
end)

RegisterNetEvent('GraveRobbing:posralsito')
AddEventHandler('GraveRobbing:posralsito', function(source)
	StartAnimation('script@mech@treasure_hunting@grab',0,'PBL_GRAB_01',0,1,true,20000)
	Wait(9000)
	TriggerEvent('vorp:TipBottom', 'tu as cassé ta pelle', 5000)	
	RunCooldown()
end)