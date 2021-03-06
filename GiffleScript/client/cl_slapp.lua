local Langue = "fr"
local VolumeDeLaMusique = 0.2

local ESX = nil 

Citizen.CreateThread(function() 

    while ESX == nil do 
        Wait(0)
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
    end 

end)

if Langue == "fr" then
    Notif1 = "~r~Aucun citoyen face a vous~s~"
    Notif2 = "👋🏾 ~g~Vous venez de vous faire gifler~s~"
end

function getPlayers()
    local playerList = {}
    for i = 0, 1024 do
        local player = GetPlayerFromServerId(i)
        if NetworkIsPlayerActive(player) then
            table.insert(playerList, player)
        end
    end
    return playerList
end

function getNearPlayer()
    local players = getPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

RegisterNetEvent('JoJo:SyncSon_Client')
AddEventHandler('JoJo:SyncSon_Client', function(playerNetId)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs  = Vdist(lCoords.x, lCoords.y, lCoords.z, eCoords.x, eCoords.y, eCoords.z)
    if (distIs <= 2.0001) then
        SendNUIMessage({
            DemarrerLaMusique     = 'DemarrerLaMusique',
            VolumeDeLaMusique   = VolumeDeLaMusique
        })
    end
end)

RegisterNetEvent('JoJo:SyncAnimation')
AddEventHandler('JoJo:SyncAnimation', function(playerNetId)
    Wait(250)
    TriggerServerEvent("JoJo:SyncSon_Serveur")
    SetPedToRagdoll(GetPlayerPed(-1), 2000, 2000, 0, 0, 0, 0)
    TriggerEvent("JoJo:Notification", Notif2)
end)

RegisterNetEvent("JoJo:Notification")
AddEventHandler('JoJo:Notification', function(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(true, false)
end)

function ChargementAnimation(donnees)
    while (not HasAnimDictLoaded(donnees)) do 
        RequestAnimDict(donnees)
        Wait(5)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if IsControlPressed(1, 19) and IsControlJustPressed(1, 44) then  -- alt + A
            if IsPedArmed(GetPlayerPed(-1), 7) then
                SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey('WEAPON_UNARMED'), true)
            end
            if (DoesEntityExist(GetPlayerPed(-1)) and not IsEntityDead(GetPlayerPed(-1))) then
                ChargementAnimation("rcmnigel1c")
                TaskPlayAnim(GetPlayerPed(-1), "rcmnigel1c", "hailing_whistle_waive_a", 2.0, 2.0, 2000, 51, 0, false, false, false)
            end
        end
    end
end)

local cooldown = false

CreateThread(function()
    while true do
        Wait(0)
        if IsControlPressed(1, 19) and IsControlJustPressed(1, 58) then  -- alt + G
            local CitoyenCible, distance = getNearPlayer()
            if (distance ~= -1 and distance < 2.0001) then
            if cooldown == false then
                ESX.ShowColoredNotification("Vous ne pourrez plus claquer une personne avant d'attendre une minute.", 8)
                cooldown = true
                if IsPedArmed(GetPlayerPed(-1), 7) then
                    SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey('WEAPON_UNARMED'), true)
                end
                if (DoesEntityExist(GetPlayerPed(-1)) and not IsEntityDead(GetPlayerPed(-1))) then
                    ChargementAnimation("melee@unarmed@streamed_variations")
                    TaskPlayAnim(GetPlayerPed(-1), "melee@unarmed@streamed_variations", "plyr_takedown_front_slap", 8.0, 1.0, 1500, 1, 0, 0, 0, 0)
                    TriggerServerEvent("JoJo:SyncGiffle", GetPlayerServerId(CitoyenCible))
                end
                Wait(1 * 60000)
                cooldown = false
                ESX.ShowColoredNotification("Vous pouvez ré-utiliser la claque.", 25)
             end
            else
                TriggerEvent("JoJo:Notification", Notif1)
            end
        end
    end
end)
