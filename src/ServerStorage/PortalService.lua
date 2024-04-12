local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

--[[

Usage:

Public Methods:
    - PortalService:FindClosestPortal(givenPosition : Vector3)
        - Find the closest portal with the given position
        - Returns that portal


    - PortalService:OpenClosestPortal(player)
        - Searches for the closest portal
        - Opens that portal

    - PortalService:ResetPortals()
        - When the game resets, this method resets the portals as well

]]

local PortalService = Knit.CreateService {
    Name = "PortalService",
}

local Effects = ReplicatedStorage.Assets.Effects

local ShopService
local CharacterSetupService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

-- Search for closest portal
function PortalService:FindClosestPortal(givenPosition : Vector3) : Model?

    -- Initiate targetportal variable
    local targetPortal = nil

    -- Any portal closer than closest distance will replace this value
    local closestDistance = math.huge

    for _, model in ipairs(self.Portals:GetChildren()) do
        -- Filter through all non-models of the Portals folder
        if not model:IsA("Model") then
            continue
        end

        -- If the portal has already been activated
        -- then ignore
        if model.Center.Transparency < 1 then
            continue
        end

        -- If the current distance is closer than the old distance
        -- then update
        local currentDistance = (model.Center.Position - givenPosition).Magnitude
        if currentDistance < closestDistance then
            closestDistance = currentDistance
            targetPortal = model
        end
    end

    return targetPortal
end

function PortalService:OpenClosestPortal(player: Player)
    if not player then
        return
    end

    local root : BasePart? = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        warn("No root in player character.")
        return
    end

    -- Search for the closest portal
    -- Will warn if no portal can be found
    local closestPortal : Model? = self:FindClosestPortal(root.Position)
    if not closestPortal then
        warn("No portal can be found.")
        return
    end

    -- Make the glowing center visible
    closestPortal.Center.Transparency = 0

    -- Create a beam on the player
    self.BeamOrigin.Parent = root
    self.BeamDestination.Parent = closestPortal.Center

    -- Set the prompt on the portal's center
    self.Prompt.Parent = closestPortal.Center
end

-- Reset all the protals in the game
function PortalService:ResetPortals()
    for index, model in ipairs(self.Portals:GetChildren()) do
        if not model:IsA("Model") then
            continue
        end

        model.Center.Transparency = 1
    end

    self.BeamOrigin.Parent = nil
    self.BeamDestination.Parent = nil
    self.Prompt.Parent = nil                             
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function PortalService:KnitInit()
    CharacterSetupService = Knit.GetService("CharacterSetupService")
    ShopService = Knit.GetService("ShopService")
end

function PortalService:KnitStart()
    self.Portals = workspace:WaitForChild("Portals")

    -- Initiate the beam
    self.BeamOrigin = Effects.NextStageBeam.Part2.OriginAttachment
    self.BeamDestination = Effects.NextStageBeam.Part1.DestinationAttachment

    -- Initiate portal prompt
    self.Prompt = Instance.new("ProximityPrompt")
    self.Prompt.ActionText = "Enter"
    self.Prompt.ObjectText = "Next Stage"
    self.Prompt.HoldDuration = 0.25
    self.Prompt.MaxActivationDistance = 10

    -- Whenever prompt is activated, load into the next level
    self.Prompt.Triggered:Connect(function(player : Player?)

        local nextPortal = self:FindClosestPortal(self.Prompt.Parent.Position)

        -- If there is a next portal, then open the shop
        -- if not, then the player has reached the last portal, to trigger a win
        if nextPortal then
            ShopService:OpenShop(player)
        else
            CharacterSetupService:PlayerWin(player)
        end

        -- After usage reset the beam and prompt
        self.BeamOrigin.Parent = nil
        self.BeamDestination.Parent = nil
        self.Prompt.Parent = nil
    end)
end


return PortalService