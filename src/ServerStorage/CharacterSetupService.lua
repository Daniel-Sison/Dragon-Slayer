local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

--[[

Usage:

Public Methods:
    - CharacterSetupService:UpdateStatsOnPlayer(player, dataName)
        - Update the stats on the player's character to reflect changes

    - CharacterSetupService:LevelComplete()
        - Increments the current level
        - Opens the closest portal
        - When a player has completed a level, this function is called
    
    - CharacterSetupService:LoadNextLevel(player : Player)
        - Calls TeleportPlayer to move them to the appropriate place
        - Calls SpawnDragons from the DragonService

    - CharacterSetupService:LoadToolAndEnemies(player : Player)
        - Gives player starter weapon
        - Loads enemy dragons

    - CharacterSetupService:TeleportPlayer(
        player : Player,
        targetLocationName : string,
        transition : boolean
    )
        - Teleport player to specified location

    - CharacterSetupService:ResetPlayer(player : Player)
        - When player dies, then reset their stats
        - Resets dragons, portals, and the rest of the game

    - CharacterSetupService:PlayerWin(player : Player)
        - When player wins, this is called
        - Resets dragons, portals, and the rest ofo the game

]]


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

-- Update specified stats on player's character to reflect changes
function CharacterSetupService:UpdateStatsOnPlayer(player: Player, dataName: string)
    if not player.Character then
        return
    end

    local humanoid : Humanoid? = player.Character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local currentData = LeaderboardService:GetData(player, dataName)

    -- If the dataName is speed or MaxHealth, then update it
    if dataName == "Speed" then
        humanoid.WalkSpeed = currentData
    elseif dataName == "Max Health" then
        humanoid.MaxHealth = currentData
    end
end

-- Called when all dragons have died
function CharacterSetupService:LevelComplete()
    local player = game.Players:FindFirstChildOfClass("Player")
    
    -- Increment current level
    local currentLevel = LeaderboardService:GetData(player, "Level")
    currentLevel += 1

    -- Set the player's data to updated current level
    LeaderboardService:SetData(player, "Level", currentLevel)

    -- Open the closest portal
    PortalService:OpenClosestPortal(player)
end


function CharacterSetupService:LoadNextLevel(player : Player)
    -- Get current level
    local currentLevel = LeaderboardService:GetData(player, "Level")

    -- Teleport player to location based on current level
    self:TeleportPlayer(player, "Level_" .. currentLevel, true)

    -- Spawn the dragons at specified level
    DragonService:SpawnDragons("Level_" .. currentLevel, currentLevel)
end


function CharacterSetupService.Client:StartPlayer(player : Player)
    self.Server:LoadToolAndEnemies(player)
end


function CharacterSetupService:LoadToolAndEnemies(player : Player)
    -- Give player starter weapon
    ToolService:AddToolToPlayer("Wood Stick", player)

    -- Spawn the dragons
    task.delay(1, function()
        DragonService:SpawnDragons("Level_1", 1)
    end)
end


function CharacterSetupService:TeleportPlayer(
    player : Player,
    targetLocationName : string,
    transition : boolean?
)

    if not player.Character then
        return
    end

    local root : BasePart? = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        warn("No root in character")
        return
    end

    -- If the teleportLocation cannot be found, then warn
    local teleportLocation : BasePart? = self.StartLocations:FindFirstChild(targetLocationName)
    if not teleportLocation then
        warn("Couldn't find the specific teleport location")
        return
    end

    -- If the teleport should have the fadeTransition or not
    if transition then
        self.Client.FadeTransition:Fire(player)
        task.delay(0.5, function()
            root.CFrame = teleportLocation.CFrame
        end)
    else
        root.CFrame = teleportLocation.CFrame
    end
end

-- When the player dies, this is called
function CharacterSetupService:ResetPlayer(player : Player)
    task.delay(2, function()
        -- Show the endgame UI
        self.Client.GameEndedForPlayer:Fire(player, false)

        -- Reset game
        LeaderboardService:ResetPlayerStats(player)
        DragonService:ResetDragons()
        PortalService:ResetPortals()
        workspace.EffectStorage:ClearAllChildren()
    end)
end

-- Called when the player wins
function CharacterSetupService:PlayerWin(player : Player)

    -- Show the endgame UI
    self.Client.GameEndedForPlayer:Fire(player, true)
    self.PlayerWon = true

    task.delay(2, function()

        -- Reset game
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

-- Make start locations invisible
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
    -- Make start locations invisible
    self:_setupStartLocations()

    -- Create a connections table that will delete connections to prevent memory leaks
    self.Connections = {}

    self.PlayerWon = false

    -- When a player is added
    Players.PlayerAdded:Connect(function(player : Player?)
        local characterAddedConnection = player.CharacterAdded:Connect(function(character : Model?)

            -- Disable health script to stop the regen function
            local healthScript : Script? = character:WaitForChild("Health")
            healthScript.Disabled = true

            local humanoid : Humanoid? = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                -- If the player has won, then return
                if self.PlayerWon then
                    return
                end

                -- Run the reset, player has lost
                self:ResetPlayer(player)
            end)

            -- After spawning, teleport player to approprate placee
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