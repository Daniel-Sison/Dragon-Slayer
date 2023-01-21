local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local CharacterSetupService = Knit.CreateService {
    Name = "CharacterSetupService",
    Client = {
        FadeTransition = Knit.CreateSignal(), -- Create the signal
    },
}

local ToolService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function CharacterSetupService.Client:StartPlayer(player : Player?)
    self.Server:TeleportPlayer(player, "Level_1", false)
    self.Server:GivePlayerStarterTool(player)
end

function CharacterSetupService:GivePlayerStarterTool(player : Player?)
    ToolService:AddToolToPlayer("Wood Stick", player)
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
end

function CharacterSetupService:KnitStart()
    self.StartLocations = workspace:WaitForChild("StartLocations")

    for _, part in ipairs(self.StartLocations:GetChildren()) do
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Transparency = 1
    end
end


return CharacterSetupService