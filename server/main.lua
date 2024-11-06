local Core = exports.vorp_core:GetCore()

RegisterCommand(Billing.Command, function(source, args, rawCommand)
    local user <const> = Core.getUser(source)
    if not user then return end

    local character <const> = user.getUsedCharacter
    local job <const> = character.job
    local grade <const> = character.jobGrade

    if not Billing.Jobs[job] or Billing.Jobs[job] < grade then
        return Core.Notify(source, "You are not allowed to use this command", "error")
    end

    TriggerClientEvent("vorp_billing:client:openMenu", source)
end, false)


AddEventHandler("vorp:characterSelected", function(source, char)
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

    if not Billing.Jobs[job] or Billing.Jobs[job] < jobGrade then
        return Core.NotifyObjective(source, "You are not allowed to bill", 5000)
    end

    local target <const> = Core.getUser(data.target)
    if not target then
        return Core.NotifyObjective(source, "Target not found you cant bill players that are not online", 5000)
    end

    if data.amount > Billing.MaxBillAmount then
        return Core.NotifyObjective(source, "You can not bill more than " .. Billing.MaxBillAmount, 5000)
    end

    if Billing.GiveMoneyToJob then
        character.addCurrency(0, data.amount)
    end

    if Billing.AllowBillingNegative then
        target.getUsedCharacter.addCurrency(0, data.amount)
    else
        if character.money < data.amount then
            return Core.NotifyObjective(source, "Player don't have enough money to pay the bill", 5000)
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
        exports.vorp_inventory:addItem(_source, Billing.ReceiptItem, 1, metadata)
    end
    --! add webhook here
end)
