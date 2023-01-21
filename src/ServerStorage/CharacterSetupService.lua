local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local CharacterSetupService = Knit.CreateService {
    Name = "CharacterSetupService",
    Client = {
        FadeTransition = Knit.CreateSignal(), -- Create the signal
    },
}

local ToolService
local DragonService
local LeaderboardService
local PortalService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function CharacterSetupService:NextLevel()
    local player = game.Players:FindFirstChildOfClass("Player")
    
    local currentLevel = LeaderboardService:GetData(player, "Level")
    currentLevel += 1

    LeaderboardService:SetData(player, "Level", currentLevel)
    
    PortalService:OpenClosestPortal(player)
end


function CharacterSetupService.Client:StartPlayer(player : Player?)
    self.Server:TeleportPlayer(player, "Level_1", false)
    self.Server:LoadToolAndEnemies(player)
end

function CharacterSetupService:LoadToolAndEnemies(player : Player?)
    ToolService:AddToolToPlayer("Wood Stick", player)
    DragonService:SpawnDragons("Level_1")
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



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


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


return CharacterSetupService