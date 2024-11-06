local MenuData = exports.vorp_menu:GetMenuData()
local Core = exports.vorp_core:GetCore()

RegisterNetEvent("vorp_billing:client:openMenu", function()
    OpenBillingMenu()
end)

function OpenBillingMenu()
    MenuData.CloseAll()
    local playerId = 0
    local reason = ""
    local amount = 0

    local elements = {
        { label = "Player ID", value = "playerId", desc = "The ID of the player you want to bill" },
        { label = "Reason",    value = "reason",   desc = "The reason for the bill" },
        { label = "Amount",    value = "amount",   desc = "The amount of money to bill" },
        { label = "Confirm",   value = "confirm",  desc = "Submit the bill" },
    }

    MenuData.Open("default", GetCurrentResourceName(), "OpenBillingMenu", {
        title = "Billing Menu",
        subtext = "SubMenu",
        align = "top-left",
        itemHeight = "4vw",
        elements = elements

    }, function(data, menu)
        local myinput = {
            type = "input",
            title = "Player ID",
            description = "The ID of the player you want to bill",
        }

        local result = exports.vorp_input:GetInput(myinput)
        if not result then return end

        if data.current.value == "playerId" and result > 0 then
            menu.setElement(1, "label", "Player ID<br> <b> Added ID:" .. result)
            menu.setElement(1, "desc", "The ID of the player you want to bill")
            playerId = result
        end

        if data.current.value == "reason" then
            menu.setElement(2, "label", "Bill Reason<br> <b>Bill reason added")
            menu.setElement(2, "desc", "Bill reason: " .. result)
            reason = result
        end

        if data.current.value == "amount" then
            menu.setElement(3, "label", "Amount added <br> <b>Amount:" .. result)
            menu.setElement(3, "desc", "The amount of money to bill")
            amount = result
        end

        if data.current.value == "confirm" then
            if playerId <= 0 or reason == "" or amount <= 0 then
                return Core.NotifyObjective("Please fill in all fields", 5000)
            end
            local info = {
                playerId = playerId,
                reason = reason,
                amount = amount,
            }
            TriggerServerEvent("vorp_billing:server:SendBill", info)
        end
    end)
end
