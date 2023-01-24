local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)


--[[

Usage:

Public Methods:
    - EnemyHealthBarController:UpdateFill(targetFrame : frame?, newData : number?, maxData : number?)
        - Update the fill of the health bar

]]



local EnemyHealthBarController = Knit.CreateController {
    Name = "EnemyHealthBarController",
}

local player = game.Players.LocalPlayer

local DragonService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

-- Updates the green fill of the healthbar displayed
-- whenever you get close to a dragon
function EnemyHealthBarController:UpdateFill(targetFrame : frame?, newData : number?, maxData : number?)
    local fill = targetFrame.HealthBar.Fill
    local fraction = newData / maxData

    return GeneralUI:SimpleTween(
        fill,
        {Position = UDim2.new(fraction, 0, 0.5, 0), Size = UDim2.new(fraction, 0, 1, 0)},
        0.25,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

-- Find an open slot for the GUI
-- to connect a dragon to
function EnemyHealthBarController:_findOpenSlot()
    if self.Dragon1:GetAttribute("Occupied") then
        return self.Dragon2
    else
        return self.Dragon1
    end

    return
end


-- Links a dragon to an open spot
function EnemyHealthBarController:_linkDragonToOpenSlot(humanoid : Humanoid?, root : BasePart?, level : number?)

    -- Search for an open slot
    local slot : Frame? = self:_findOpenSlot()
    if not slot then
        warn("No slots open")
        return
    end

    -- Set slot attribute to "Occupied" as a debounce
    slot:SetAttribute("Occupied", true)

    -- Update the fill of the bar
    self:UpdateFill(slot, humanoid.Health, humanoid.MaxHealth)

    -- Return if no root part in the player character.
    local playerRoot : BasePart = player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then
        return
    end

    slot.DragonTitle.Text = humanoid.Parent.Name .. " (Level " .. tostring(level) .. ")"
    slot.Visible = true

    local connection1
    local connection2
    local connection3
    local connection4

    local function resetConnections()
        connection1:Disconnect()
        connection2:Disconnect()
        connection3:Disconnect()
        connection4:Disconnect()

        slot:SetAttribute("Occupied", false)
        slot.Visible = false
    end

    -- Whenever health is updated, then update the health bar
    connection1 = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        self:UpdateFill(slot, humanoid.Health, humanoid.MaxHealth)
    end)

    -- Whenever the player is out of range, hide the health bar
    connection2 = game:GetService("RunService").Heartbeat:Connect(function()
        if humanoid.Health <= 0 then
            return
        end

        if (playerRoot.Position - root.Position).Magnitude <= 100 then
            slot.Visible = true
        else
            slot.Visible = false
        end
    end)

    -- When the dragon is destroyed, reset the connections
    connection3 = humanoid.Parent.AncestryChanged:Connect(function()
        if humanoid:IsDescendantOf(workspace) then
            return
        end
        
        resetConnections()
    end)

    -- When the dragon dies, reset the connections
    connection4 = humanoid.Died:Connect(function()
        resetConnections()
    end)
end

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function EnemyHealthBarController:KnitInit()
    DragonService = Knit.GetService("DragonService")
end

function EnemyHealthBarController:KnitStart()
    local targetName = string.gsub(script.Name, "Controller", "")
    self.Gui = player.PlayerGui:WaitForChild(targetName)

    self.Container = self.Gui:WaitForChild("Container")
    self.Dragon1 = self.Container:WaitForChild("Dragon1")
    self.Dragon2 = self.Container:WaitForChild("Dragon2")

    -- Lnks a dragon from the dragonservice to an open slot
    DragonService.LinkDragonToUI:Connect(function(humanoid : Humanoid?, root : BasePart?, level : number?)
        self:_linkDragonToOpenSlot(humanoid, root, level)
    end)
end


return EnemyHealthBarController
