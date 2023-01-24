local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create the service:
local ShopService = Knit.CreateService {
    Name = "ShopService",
    Client = {
        OpenShopUISignal = Knit.CreateSignal(), -- Create the signal
    },
}

local CharacterSetupService
local LeaderboardService
local CoinService

local SHOP_ITEMS = {
    ["Heal"] = {
        Description = "Heal back the amount provided.",
        BaseCost = 3,
        BaseAmount = 20,
    },
    ["Strength"] = {
        Description = "Increase damage per hit.",
        BaseCost = 5,
        BaseAmount = 2,
    },
    ["Speed"] = {
        Description = "Increase movement speed.",
        BaseCost = 5,
        BaseAmount = 3,
    },
    ["Max Health"] = {
        Description = "Increase maximum health.",
        BaseCost = 5,
        BaseAmount = 10,
    },
}

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function ShopService.Client:FinishedBuying(player : Player?)    
    self.Server:FinishedBuying(player)
end


function ShopService.Client:BuyItem(player : Player?, itemName : string?)    
    self.Server:BuyItem(player, itemName)
end

function ShopService:FinishedBuying(player : Player?)
    -- ShopOpen prevents client from calling FinishedBuying if the shop hasn't been
    -- opened by the server
    if not self.ShopOpen then
        return
    end

    self.ShopOpen = false
    CharacterSetupService:LoadNextLevel(player)
end

function ShopService:OpenShop(player : Player?)
    local shopItems = self:_generateAllShopItems()

    self.CurrentShopItems = shopItems
    self.ShopOpen = true
    self.Client.OpenShopUISignal:Fire(player, shopItems)
end

function ShopService:BuyItem(player : Player?, itemName : string?)

    if not self.CurrentShopItems[itemName] then
        return
    end

    if self.CurrentShopItems[itemName].Bought == true then
        warn("This item has already been bought.")
        return
    end


    local coinAmount : number? = LeaderboardService:GetData(player, "Coins")

    -- If the player doesn't have enough money, then return
    if self.CurrentShopItems[itemName].Cost > coinAmount then
        return
    end

    self.CurrentShopItems[itemName].Bought = true

    local dataName : string? = self.CurrentShopItems[itemName].OriginName

    -- Decrease the player's coins by the cost
    LeaderboardService:SetData(player, "Coins", coinAmount - self.CurrentShopItems[itemName].Cost)
    CoinService:ShowChangesInCoinUI(player)

    if dataName == "Heal" then
        if not player.Character then
            return
        end
        
        local humanoid : Humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid then
            return
        end

        if humanoid.Health + self.CurrentShopItems[itemName].Amount > humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        else
            humanoid.Health += self.CurrentShopItems[itemName].Amount
        end
    else
        local currentData = LeaderboardService:GetData(player, dataName)
        local newData = currentData + self.CurrentShopItems[itemName].Amount

        LeaderboardService:SetData(player, dataName, newData)
        CharacterSetupService:UpdateStatsOnPlayer(player, dataName)
    end

    print(LeaderboardService.PlayerStats[player.UserId])
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function ShopService:_getShopNames()
    local allNames = {}
    for key, value in pairs(SHOP_ITEMS) do
        table.insert(allNames, key)
    end

    return allNames
end

function ShopService:_getRandomShopItem()
    local randomNumber : number? = math.random(1, 5)
    local shopNamesTable : table? = self:_getShopNames()
    
    local shopItemName : string? = shopNamesTable[math.random(1, #shopNamesTable)]

    return {
        Title = "+" .. tostring(randomNumber * SHOP_ITEMS[shopItemName].BaseAmount) .. " "  .. shopItemName,
        Description = SHOP_ITEMS[shopItemName].Description,
        Cost = SHOP_ITEMS[shopItemName].BaseCost * randomNumber,
        Amount = SHOP_ITEMS[shopItemName].BaseAmount * randomNumber,
        Bought = false,
        OriginName = shopItemName,
    }
end

function ShopService:_generateAllShopItems()
    local newShop = {}

    newShop["ShopItem1"] = self:_getRandomShopItem()
    newShop["ShopItem2"] = self:_getRandomShopItem()
    newShop["ShopItem3"] = self:_getRandomShopItem()

    return newShop
end


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function ShopService:KnitInit()
    CharacterSetupService = Knit.GetService("CharacterSetupService")
    LeaderboardService = Knit.GetService("LeaderboardService")
    CoinService = Knit.GetService("CoinService")
end

function ShopService:KnitStart()
    self.CurrentShopItems = {}

    -- Is only true if the shop is open
    self.ShopOpen = false
end


return ShopService