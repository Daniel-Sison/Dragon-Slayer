local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local PortalService = Knit.CreateService {
    Name = "PortalService",
}

local Effects = ReplicatedStorage.Assets.Effects

local CharacterSetupService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function PortalService:FindClosestPortal(givenPosition : Vector3?)
    local targetPortal = nil
    local closestDistance = math.huge

    for index, model in ipairs(self.Portals:GetChildren()) do
        if not model:IsA("Model") then
            continue
        end

        if model.Center.Transparency < 1 then
            continue
        end

        local currentDistance = (model.Center.Position - givenPosition).Magnitude
        if currentDistance < closestDistance then
            closestDistance = currentDistance
            targetPortal = model
        end
    end

    return targetPortal
end

function PortalService:OpenClosestPortal(player)
    if not player then
        return
    end

    local root : BasePart? = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        warn("No root in player character.")
        return
    end

    local closestPortal : Model? = self:FindClosestPortal(root.Position)
    if not closestPortal then
        warn("No portal can be found.")
        return
    end

    closestPortal.Center.Transparency = 0

    self.BeamOrigin.Parent = root
    self.BeamDestination.Parent = closestPortal.Center

    self.Prompt.Parent = closestPortal.Center
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function PortalService:KnitInit()
    CharacterSetupService = Knit.GetService("CharacterSetupService")
end

function PortalService:KnitStart()
    self.Portals = workspace:WaitForChild("Portals")

    self.BeamOrigin = Effects.NextStageBeam.Part2.OriginAttachment
    self.BeamDestination = Effects.NextStageBeam.Part1.DestinationAttachment

    self.Prompt = Instance.new("ProximityPrompt")
    self.Prompt.ActionText = "Enter"
    self.Prompt.ObjectText = "Next Stage"
    self.Prompt.HoldDuration = 0.25
    self.Prompt.MaxActivationDistance = 10

    self.Prompt.Triggered:Connect(function(player : Player?)
        self.BeamOrigin.Parent = nil
        self.BeamDestination.Parent = nil
        self.Prompt.Parent = nil

        CharacterSetupService:LoadNextLevel(player)
    end)
end


return PortalService