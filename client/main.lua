local MenuData <const> = exports.vorp_menu:GetMenuData()
local Core <const> = exports.vorp_core:GetCore()

RegisterNetEvent("vorp_billing:client:openMenu", function()
    OpenBillingMenu()
end)

local function myInput(header, placeholder, type, pattern, title)
    local input <const> = {
        type = "enableinput",
        inputType = "input",
        button = "Confirm",
        placeholder = placeholder,
        style = "block",
        attributes = {
            inputHeader = header,
            type = type,
            pattern = pattern,
            title = title,
            style = "border-radius: 10px; background-color: ; border:none;",
        }
    }
    return input
end

function OpenBillingMenu()
    MenuData.CloseAll()
    local playerId = 0
    local reason = ""
    local amount = 0

    local elements <const> = {
        { label = "Player ID",   value = "playerId", desc = "The ID of the player you want to bill" },
        { label = "Bill Reason", value = "reason",   desc = "The reason for the bill" },
        { label = "Bill Amount", value = "amount",   desc = "The amount of money to bill" },
        { label = "Confirm",     value = "confirm",  desc = "Submit the bill" },
    }

    MenuData.Open("default", GetCurrentResourceName(), "OpenBillingMenu", {
        title = "Billing Menu",
        subtext = "SubMenu",
        align = "top-left",
        itemHeight = "4vh",
        elements = elements

    }, function(data, menu)
        if data.current.value == "confirm" then
            if playerId <= 0 or reason == "" or amount <= 0 then
                return Core.NotifyObjective("Please fill in all fields", 5000)
            end

            menu.close()

            local info = {
                playerId = playerId,
                reason = reason,
                amount = amount,
            }
            return TriggerServerEvent("vorp_billing:server:SendBill", info)
        end

        local type <const> = (data.current.value == "playerId" or data.current.value == "amount") and "number" or "text"
        local pattern <const> = (data.current.value == "playerId" or data.current.value == "amount") and "[0-9]" or "[a-zA-Z ]+"
        local title <const> = (data.current.value == "playerId" or data.current.value == "amount") and "Only Numbers Are Allowed" or "Only Letters Are Allowed"
        local input <const> = myInput("Billing Menu", "type here", type, pattern, title)

        local result <const> = exports.vorp_inputs:advancedInput(input)
        if not result then return end

        if data.current.value == "playerId" and tonumber(result) > 0 then
            menu.setElement(1, "label", "Player ID<br> <b> Added ID:" .. result)
            menu.setElement(1, "desc", "The ID of the player you want to bill")
            menu.refresh()
            playerId = tonumber(result)
        end

        if data.current.value == "reason" then
            menu.setElement(2, "label", "Bill Reason<br>bill reason added")
            menu.setElement(2, "desc", "Bill reason: " .. result)
            menu.refresh()
            reason = result
        end

        if data.current.value == "amount" and tonumber(result) > 0 then
            if tonumber(result) > Billing.MaxBillAmount then
                return Core.NotifyObjective("You can not bill more than " .. Billing.MaxBillAmount, 5000)
            end
            menu.setElement(3, "label", "Bill Amount <br>Amount added: $" .. result)
            menu.setElement(3, "desc", "The amount of money to bill")
            menu.refresh()
            amount = tonumber(result)
        end
    end, function(data, menu)
        menu.close()
    end)
end
