local ESX = nil
local QBCore = nil

-- Initialize framework
if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Purchase items event
RegisterNetEvent('shop:purchaseItems')
AddEventHandler('shop:purchaseItems', function(data)
    local src = source
    local xPlayer = nil
    
    -- Get player object based on framework
    if Config.Framework == 'esx' then
        xPlayer = ESX.GetPlayerFromId(src)
    elseif Config.Framework == 'qbcore' then
        xPlayer = QBCore.Functions.GetPlayer(src)
    end
    
    if not xPlayer then
        TriggerClientEvent('shop:purchaseResult', src, false, 'Player not found')
        return
    end
    
    local cart = data.cart
    local paymentMethod = data.paymentMethod
    local totalPrice = data.totalPrice
    local shopIndex = data.shopIndex
    
    -- Validate shop
    if not Config.Shops[shopIndex] then
        TriggerClientEvent('shop:purchaseResult', src, false, 'Invalid shop')
        return
    end
    
    -- Validate cart items
    local validatedTotal = 0
    local shop = Config.Shops[shopIndex]
    
    for _, cartItem in pairs(cart) do
        local foundItem = false
        for _, shopItem in pairs(shop.items) do
            if shopItem.name == cartItem.name then
                validatedTotal = validatedTotal + (shopItem.price * cartItem.quantity)
                foundItem = true
                break
            end
        end
        
        if not foundItem then
            TriggerClientEvent('shop:purchaseResult', src, false, 'Invalid item in cart')
            return
        end
    end
    
    -- Check if calculated total matches client total
    if math.abs(validatedTotal - totalPrice) > 0.01 then
        TriggerClientEvent('shop:purchaseResult', src, false, 'Price mismatch')
        return
    end
    
    -- Check player money
    local hasEnoughMoney = false
    
    if Config.Framework == 'esx' then
        if paymentMethod == 'cash' then
            hasEnoughMoney = xPlayer.getMoney() >= totalPrice
        elseif paymentMethod == 'bank' then
            hasEnoughMoney = xPlayer.getAccount('bank').money >= totalPrice
        end
    elseif Config.Framework == 'qbcore' then
        if paymentMethod == 'cash' then
            hasEnoughMoney = xPlayer.PlayerData.money['cash'] >= totalPrice
        elseif paymentMethod == 'bank' then
            hasEnoughMoney = xPlayer.PlayerData.money['bank'] >= totalPrice
        end
    end
    
    if not hasEnoughMoney then
        TriggerClientEvent('shop:purchaseResult', src, false, 'Not enough money')
        return
    end
    
    -- Process payment
    if Config.Framework == 'esx' then
        if paymentMethod == 'cash' then
            xPlayer.removeMoney(totalPrice)
        elseif paymentMethod == 'bank' then
            xPlayer.removeAccountMoney('bank', totalPrice)
        end
    elseif Config.Framework == 'qbcore' then
        xPlayer.Functions.RemoveMoney(paymentMethod, totalPrice)
    end
    
    -- Give items to player
    for _, cartItem in pairs(cart) do
        if Config.Framework == 'esx' then
            xPlayer.addInventoryItem(cartItem.name, cartItem.quantity)
        elseif Config.Framework == 'qbcore' then
            xPlayer.Functions.AddItem(cartItem.name, cartItem.quantity)
        end
    end
    
    -- Log transaction
    print(('[SHOP] Player %s purchased items worth $%d from %s using %s'):format(
        GetPlayerName(src), totalPrice, shop.name, paymentMethod
    ))
    
    TriggerClientEvent('shop:purchaseResult', src, true, 'Purchase successful!')
end)

-- Get player money (for UI updates if needed)
RegisterNetEvent('shop:getPlayerMoney')
AddEventHandler('shop:getPlayerMoney', function()
    local src = source
    local xPlayer = nil
    local money = {cash = 0, bank = 0}
    
    if Config.Framework == 'esx' then
        xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            money.cash = xPlayer.getMoney()
            money.bank = xPlayer.getAccount('bank').money
        end
    elseif Config.Framework == 'qbcore' then
        xPlayer = QBCore.Functions.GetPlayer(src)
        if xPlayer then
            money.cash = xPlayer.PlayerData.money['cash']
            money.bank = xPlayer.PlayerData.money['bank']
        end
    end
    
    TriggerClientEvent('shop:receiveMoney', src, money)
end)