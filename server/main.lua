local Core = exports.vorp_core:GetCore()

RegisterCommand(Billing.Command, function(source, args, rawCommand)
    local user <const> = Core.getUser(source)
    if not user then return end

    local character <const> = user.getUsedCharacter
    local job <const> = character.job
    local grade <const> = character.jobGrade

    if not Billing.Jobs[job] and Billing.Jobs[job] < grade then
        return Core.NotifyObjective(source, "You are not allowed to use this command", 5000)
    end

    if not Billing.GetIsOnduty(source) then
        return Core.NotifyObjective(source, "You are not on duty", 5000)
    end

    TriggerClientEvent("vorp_billing:client:openMenu", source)
end, false)


AddEventHandler("vorp:SelectedCharacter", function(source, char)
    local job <const> = char.job
    local grade <const> = char.jobGrade

    if Billing.Jobs[job] and Billing.Jobs[job] >= grade then
        TriggerClientEvent("chat:addSuggestion", source, Billing.Command, "Bill a player", {})
    end
end)

-- we need an event to register the bill
RegisterNetEvent("vorp_billing:server:SendBill", function(data)
    local _source <const> = source

    local user <const> = Core.getUser(_source)
    if not user then return end

    local character <const> = user.getUsedCharacter
    local job <const> = character.job
    local jobGrade <const> = character.jobGrade

    if not Billing.Jobs[job] and Billing.Jobs[job] < jobGrade then
        return Core.NotifyObjective(_source, "You are not allowed to bill", 5000)
    end

    if data.playerId == _source then
        return Core.NotifyObjective(_source, "You can not bill yourself", 5000)
    end

    local target <const> = Core.getUser(data.playerId)
    if not target then
        return Core.NotifyObjective(_source, "Target not found you cant bill players that are not online", 5000)
    end

    local distance <const> = #(GetEntityCoords(GetPlayerPed(_source)) - GetEntityCoords(GetPlayerPed(data.playerId)))
    if distance > 5.0 then
        return Core.NotifyObjective(_source, "Target is too far away from you", 5000)
    end

    if data.amount > Billing.MaxBillAmount then
        return Core.NotifyObjective(_source, "You can not bill more than " .. Billing.MaxBillAmount, 5000)
    end

    if Billing.GiveMoneyToJob then
        character.addCurrency(0, data.amount)
    end

    if Billing.AllowBillingNegative then
        target.getUsedCharacter.addCurrency(0, data.amount)
        Core.NotifyObjective(_source, "You have successfully billed " .. target.getUsedCharacter.firstname .. " " .. target.getUsedCharacter.lastname .. " for " .. data.amount, 5000)
        Core.NotifyObjective(data.playerId, "You have been billed for " .. data.amount .. " by " .. character.firstname .. " " .. character.lastname .. " for " .. data.reason, 5000)
    else
        if character.money < data.amount then
            return Core.NotifyObjective(_source, "Player don't have enough money to pay the bill", 5000)
        end
        target.getUsedCharacter.addCurrency(0, data.amount)
    end

    if Billing.GiveReceipt then
        local day <const> = os.date("%d")
        local month <const> = os.date("%m")
        local year <const> = Billing.ServerYear
        local metadata <const> = {
            description = "This is a bill you received<br>Amount: " .. data.amount ..
                "<br>Billed By: " .. character.firstname .. " " .. character.lastname ..
                "<br>Date: " .. day .. "/" .. month .. "/" .. year ..
                "<br>Reason: " .. data.reason
        }
        exports.vorp_inventory:addItem(data.playerId, Billing.ReceiptItem, 1, metadata)
    end
    --! add webhook here
end)
