local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

--[[

Usage:

Public Methods:
    - Just using a simple leaderstats framework for the scope of this project.

    - LeaderboardService:GetData(player, dataName)
        - Will return specified requested data

    - LeaderboardService:SetData(player, dataName, newData)
        - Doesn't return anything
        - Sets specified data to a specified value
]]


-- Create the service:
local LeaderboardService = Knit.CreateService {
    Name = "LeaderboardService",
}

local DataStoreService = game:GetService("DataStoreService")
local DataVersion = DataStoreService:GetDataStore("V_1.0")

local TableUtil = require(ReplicatedStorage.Util:FindFirstChild("table-util", true))

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

-- Client is able to get data
function LeaderboardService.Client:GetData(player : Player?, dataName : string?)
    return self.Server:GetData(player, dataName)
end


function LeaderboardService:GetData(player : Player?, dataName : string?)
    local entry : string? = self.PlayerStats[player.UserId]
    if not entry then
        warn("No player of that name has data")
        return nil
    end

    local targetData : string? = entry[dataName]
    if not targetData then
        warn("No data of that name")
        return nil
    end

    return targetData
end

-- Only a server function for setting data
function LeaderboardService:SetData(player : Player?, dataName : string?, newData : any?)
    local entry : string? = self.PlayerStats[player.UserId]
    if not entry then
        warn("No player of that name has data")
        return nil
    end

    local targetData : string? = entry[dataName]
    if not targetData then
        warn("No data of that name")
        return nil
    end

    self.PlayerStats[player.UserId][dataName] = newData
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function LeaderboardService:KnitInit()

end

function LeaderboardService:KnitStart()
    self.Template = {
        ["Coins"] = 0,
    }

    self.PlayerStats = {
    }

    game.Players.PlayerAdded:Connect(function(player)
        self.PlayerStats[player.UserId] = TableUtil.Copy(self.Template, true)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        -- If the playerstat doesn't exist, then return
        if not self.PlayerStats[player.UserId] then
           return
        end

        -- If it exists in the table, then clean up that player's data
        self.PlayerStats[player.UserId] = nil
    end)
end


return LeaderboardService