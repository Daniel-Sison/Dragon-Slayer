local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)

-- Create the service:
local EnemyHealthBarController = Knit.CreateController {
    Name = "EnemyHealthBarController",
}

local player = game.Players.LocalPlayer

local DragonService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

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

function EnemyHealthBarController:_findOpenSlot()
    if self.Dragon1:GetAttribute("Occupied") then
        return self.Dragon2
    else
        return self.Dragon1
    end

    return
end

function EnemyHealthBarController:_linkDragonToOpenSlot(humanoid : Humanoid?, root : BasePart?, level : number?)
    local slot : Frame? = self:_findOpenSlot()
    if not slot then
        warn("No slots open")
        return
    end

    slot:SetAttribute("Occupied", true)
    self:UpdateFill(slot, humanoid.Health, humanoid.MaxHealth)

    local playerRoot : BasePart = player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then
        return
    end

    slot.DragonTitle.Text = humanoid.Parent.Name .. " (Level " .. tostring(level) .. ")"
    slot.Visible = true

    local connection1
    local connection2
    local connection3

    connection1 = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        self:UpdateFill(slot, humanoid.Health, humanoid.MaxHealth)
    end)

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

    connection3 = humanoid.Died:Connect(function()
        connection1:Disconnect()
        connection2:Disconnect()
        connection3:Disconnect()

        slot:SetAttribute("Occupied", false)
        slot.Visible = false
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

    DragonService.LinkDragonToUI:Connect(function(humanoid : Humanoid?, root : BasePart?, level : number?)
        self:_linkDragonToOpenSlot(humanoid, root, level)
    end)
end


return EnemyHealthBarController
