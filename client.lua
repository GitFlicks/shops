local ESX = nil
local QBCore = nil

-- Initialize framework
if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local currentShop = nil
local shopBlips = {}
local shopNPCs = {}
local isNearShop = false
local nearestShop = nil

-- Create blips and NPCs
CreateThread(function()
    for i, shop in pairs(Config.Shops) do
        -- Create blip
        local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
        SetBlipSprite(blip, shop.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, shop.blip.scale)
        SetBlipColour(blip, shop.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.name)
        EndTextCommandSetBlipName(blip)
        shopBlips[i] = blip

        -- Create NPC
        RequestModel(GetHashKey(shop.npc.model))
        while not HasModelLoaded(GetHashKey(shop.npc.model)) do
            Wait(1)
        end

        local npc = CreatePed(4, GetHashKey(shop.npc.model), shop.coords.x, shop.coords.y, shop.coords.z - 1.0, shop.npc.heading, false, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)
        shopNPCs[i] = npc
    end
end)

-- Main thread for shop interaction
CreateThread(function()
    while true do
        Wait(500)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local wasNearShop = isNearShop
        
        isNearShop = false
        nearestShop = nil

        for i, shop in pairs(Config.Shops) do
            local distance = #(playerCoords - shop.coords)
            if distance <= Config.MaxDistance then
                isNearShop = true
                nearestShop = i
                break
            end
        end

        if isNearShop and not wasNearShop then
            -- Player entered shop area
        elseif not isNearShop and wasNearShop then
            -- Player left shop area
            nearestShop = nil
        end
    end
end)

-- Key control thread
CreateThread(function()
    while true do
        Wait(0)
        if isNearShop and nearestShop then
            if Config.DrawText then
                local coords = Config.Shops[nearestShop].coords
                DrawText3D(coords.x, coords.y, coords.z + 2.0, '[E] - Open ' .. Config.Shops[nearestShop].name)
            end

            if IsControlJustReleased(0, 38) then -- E key
                OpenShop(nearestShop)
            end
        else
            Wait(500)
        end
    end
end)

-- Open shop UI
function OpenShop(shopIndex)
    if not shopIndex or not Config.Shops[shopIndex] then return end
    
    currentShop = shopIndex
    local shop = Config.Shops[shopIndex]
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openShop',
        shop = {
            name = shop.name,
            items = shop.items
        }
    })
end

-- Close shop UI
RegisterNUICallback('closeShop', function(data, cb)
    SetNuiFocus(false, false)
    currentShop = nil
    cb('ok')
end)

-- Purchase items
RegisterNUICallback('purchaseItems', function(data, cb)
    if not currentShop then 
        cb('error')
        return 
    end

    local cart = data.cart
    local paymentMethod = data.paymentMethod
    local totalPrice = data.totalPrice

    TriggerServerEvent('shop:purchaseItems', {
        cart = cart,
        paymentMethod = paymentMethod,
        totalPrice = totalPrice,
        shopIndex = currentShop
    })
    
    cb('ok')
end)

-- Handle purchase result
RegisterNetEvent('shop:purchaseResult')
AddEventHandler('shop:purchaseResult', function(success, message)
    SendNUIMessage({
        type = 'purchaseResult',
        success = success,
        message = message
    })
    
    if success then
        SetNuiFocus(false, false)
        currentShop = nil
    end
end)

-- Draw 3D text function
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        -- Remove blips
        for _, blip in pairs(shopBlips) do
            RemoveBlip(blip)
        end
        
        -- Remove NPCs
        for _, npc in pairs(shopNPCs) do
            DeleteEntity(npc)
        end
        
        -- Close UI
        SetNuiFocus(false, false)
    end
end)