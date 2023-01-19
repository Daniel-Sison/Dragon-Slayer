local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local CoinService = Knit.CreateService {
    Name = "CoinService",
    Client = {
        UpdateCoinUI = Knit.CreateSignal(), -- Create the signal
    },
}

local LeaderboardService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function CoinService:CoinCollected(player : Player?)
    -- Get the current coin amount from the LeaderboardService
    local coinAmount : number? = LeaderboardService:GetData(player, "Coins")
    coinAmount += 1

    -- Update coin amount
    LeaderboardService:SetData(player, "Coins", coinAmount)

    -- Reflect that change in the UI
    self.Client.UpdateCoinUI:Fire(player, coinAmount)
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function CoinService:KnitInit()
    LeaderboardService = Knit.GetService("LeaderboardService")
end

function CoinService:KnitStart()
    
end


return CoinService