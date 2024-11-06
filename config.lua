Billing = {}

Billing.GiveMoneyToJob = true       -- if false the money wont be given to anyone if true the money will be given to the person who is billing

Billing.AllowBillingNegative = true -- if true it will alow to bill player to negative money, if true you cant bill players that dont have money

Billing.GiveReceipt = true          -- if true the player who got billed will receive a receipt as item

Billing.ReceiptItem = "receipt"     -- the item that will be given to the player who paid the bill

Billing.ServerYear = 1899           -- the year that will be used in the receipt

-- jobs allowed to use billing and ranks
Billing.Jobs = {
    police = 0,
    ambulance = 0,
    mechanic = 0,
    taxi = 0,
}

Billing.Command = "bill"
