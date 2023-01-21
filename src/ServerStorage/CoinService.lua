local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)

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


-- Spawn a collection of coins with a specified amount
function CoinService:SpawnCoinsAt(position : Vector3?, amount : number?)
    -- Table to hold all the coins
    local allCoins = {}

    -- Spawn the coins
    for i = 1, amount do
        local coin = ReplicatedStorage.Assets.Misc.Coin:Clone()
        coin.Position = position
        coin.Parent = workspace.EffectStorage

        table.insert(allCoins, coin)

        -- Fling the coins in a certain vector
        coin:ApplyImpulse(Vector3.new(0, coin:GetMass() * 90, 0))
    end

    task.delay(2, function()
        self:_setupCoinsForCollection(allCoins)
    end)
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

-- Watch the coins to be collected
function CoinService:_setupCoinsForCollection(allCoins : table?)
    local heartBeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        self:_checkIfCoinCollected(allCoins)
    end)

    -- After 30 seconds, the coins expire and clean up
    task.delay(30, function()
        for _, coin in ipairs(allCoins) do
            if not coin:IsDescendantOf(workspace) then
                continue
            end

            coin:Destroy()
        end

        allCoins = nil
        heartBeatConnection:Disconnect()
        heartBeatConnection = nil
    end)
end


-- Run through each coin and check if it has been collected yet
function CoinService:_checkIfCoinCollected(allCoins : table?)
    for _, coin in ipairs(allCoins) do
        if coin:GetAttribute("Collected") then
            continue
        end

        local closestPlayerRoot : BasePart? = self:_findClosestPlayerRoot(coin)
        if not closestPlayerRoot then
            continue
        end

        coin:SetAttribute("Collected", true)

        --coin.Anchored = true
        --coin.CanCollide = false

        local collectTween = GeneralTween:SimpleTween(
            coin,
            {Size = Vector3.new(0.01, 0.01, 0.01)},
            0.35,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.In
        )

        collectTween.Completed:Connect(function()
            local player = game.Players:GetPlayerFromCharacter(closestPlayerRoot.Parent)
            if not player then 
                return 
            end

            self:CoinCollected(player)

            coin:Destroy()
        end)
    end
end

-- Find the closest player root part
function CoinService:_findClosestPlayerRoot(coin : BasePart?)
    for index, player in ipairs(game.Players:GetChildren()) do
        if not player:IsA("Player") then
            continue
        end

        local humanoid : Humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid then
            return
        end

        if humanoid.Health <= 0 then
            return
        end

        local root : BasePart? = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then
            continue
        end

        if (root.Position - coin.Position).Magnitude <= 10 then
            return root
        end
    end

    return
end

-- All coins follow this coin's cframe
function CoinService:_spinCoinIdeal()
    self.CoinIdeal.CFrame = self.CoinIdeal.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)

    task.delay(0.5, function()
        self:_spinCoinIdeal()
    end)
end
----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function CoinService:KnitInit()
    LeaderboardService = Knit.GetService("LeaderboardService")
end

function CoinService:KnitStart()

    self.CoinIdeal = workspace.Props:WaitForChild("CoinIdeal")
    self:_spinCoinIdeal()

end


return CoinService