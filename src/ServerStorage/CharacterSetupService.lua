local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)


local CharacterSetupService = Knit.CreateService {
    Name = "CharacterSetupService",
    Client = {
        FadeTransition = Knit.CreateSignal(), -- Create the signal
        GameEndedForPlayer = Knit.CreateSignal(),
    },
}

local ToolService
local DragonService
local LeaderboardService
local PortalService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function CharacterSetupService:UpdateStatsOnPlayer(player, dataName)
    if not player.Character then
        return
    end

    local humanoid : Humanoid? = player.Character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local currentData = LeaderboardService:GetData(player, dataName)

    if dataName == "Speed" then
        humanoid.WalkSpeed = currentData
    elseif dataName == "Max Health" then
        humanoid.MaxHealth = currentData
    end
end

function CharacterSetupService:LevelComplete()
    local player = game.Players:FindFirstChildOfClass("Player")
    
    local currentLevel = LeaderboardService:GetData(player, "Level")
    currentLevel += 1

    LeaderboardService:SetData(player, "Level", currentLevel)

    PortalService:OpenClosestPortal(player)
end

function CharacterSetupService:LoadNextLevel(player : Player?)
    local currentLevel = LeaderboardService:GetData(player, "Level")

    self:TeleportPlayer(player, "Level_" .. currentLevel, true)
    DragonService:SpawnDragons("Level_" .. currentLevel, currentLevel)
end

function CharacterSetupService.Client:StartPlayer(player : Player?)
    self.Server:LoadToolAndEnemies(player)
end

function CharacterSetupService:LoadToolAndEnemies(player : Player?)
    ToolService:AddToolToPlayer("Wood Stick", player)

    task.delay(1, function()
        DragonService:SpawnDragons("Level_1", 1)
    end)
end

function CharacterSetupService:TeleportPlayer(player : Player?, targetLocationName : string?, transition : boolean?)
    if not player.Character then
        return
    end

    local root : BasePart? = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        warn("No root in character")
        return
    end

    local teleportLocation : BasePart? = self.StartLocations:FindFirstChild(targetLocationName)
    if not teleportLocation then
        warn("Couldn't find the specific teleport location")
        return
    end

    if transition then
        self.Client.FadeTransition:Fire(player)
        task.delay(0.5, function()
            root.CFrame = teleportLocation.CFrame
        end)
    else
        root.CFrame = teleportLocation.CFrame
    end
end


function CharacterSetupService:ResetPlayer(player : Player?)
    task.delay(2, function()
        self.Client.GameEndedForPlayer:Fire(player, false)

        LeaderboardService:ResetPlayerStats(player)
        DragonService:ResetDragons()
        PortalService:ResetPortals()
        workspace.EffectStorage:ClearAllChildren()
    end)
end


function CharacterSetupService:PlayerWin(player : Player?)
    self.Client.GameEndedForPlayer:Fire(player, true)
    self.PlayerWon = true

    task.delay(2, function()
        LeaderboardService:ResetPlayerStats(player)
        DragonService:ResetDragons()
        PortalService:ResetPortals()
        workspace.EffectStorage:ClearAllChildren()

        self.PlayerWon = false
    end)

    if not player.Character then
        return
    end

    local humanoid : Humanoid? = player.Character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    humanoid.Health = 0
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function CharacterSetupService:_setupStartLocations()
    for _, part in ipairs(self.StartLocations:GetDescendants()) do
        if not part:IsA("BasePart") then
            continue
        end

        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Transparency = 1
    end
end


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function CharacterSetupService:KnitInit()
    ToolService = Knit.GetService("ToolService")
    DragonService = Knit.GetService("DragonService")
    LeaderboardService = Knit.GetService("LeaderboardService")
    PortalService = Knit.GetService("PortalService")
end

function CharacterSetupService:KnitStart()
    self.StartLocations = workspace:WaitForChild("StartLocations")
    self:_setupStartLocations()

    -- Create a connections table that will delete connections to prevent memory leaks
    self.Connections = {}

    self.PlayerWon = false

    Players.PlayerAdded:Connect(function(player : Player?)
        local characterAddedConnection = player.CharacterAdded:Connect(function(character : Model?)
            local healthScript : Script? = character:WaitForChild("Health")
            healthScript.Disabled = true

            local humanoid : Humanoid? = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                if self.PlayerWon then
                    return
                end

                self:ResetPlayer(player)
            end)

            task.delay(0.1, function()
                self:TeleportPlayer(player, "Level_1", false)
            end)
        end)

        self.Connections[player] = characterAddedConnection
    end)

    Players.PlayerRemoving:Connect(function(player : Player?)
        -- Disconnect the connection if the dictionary key is the player
        if self.Connections[player] then
            self.Connections[player]:Disconnect()
            self.Connections[player] = nil
        end
    end)
end


return CharacterSetupService