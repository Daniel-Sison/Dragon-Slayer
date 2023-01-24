local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)

-- Create the service:
local ShopGuiController = Knit.CreateController {
    Name = "ShopGuiController",
}

local player = game.Players.LocalPlayer

local ShopService
local LeaderboardService

local CameraController

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function ShopGuiController:OpenShop()
    self.Gui.Enabled = true
    self.Container.Position = self.Container:GetAttribute("HiddenPosition")

    CameraController:ToggleBlur(true)
    StarterGui:SetCore("ResetButtonCallback", false)

    GeneralUI:SimpleTween(
        self.Container,
        {Position = self.Container:GetAttribute("OriginPosition")},
        0.35,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
end


function ShopGuiController:HideShop()
    CameraController:ToggleBlur(false)
    StarterGui:SetCore("ResetButtonCallback", true)

    GeneralUI:SimpleTween(
        self.Container,
        {Position = self.Container:GetAttribute("HiddenPosition")},
        0.35,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
    )
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function ShopGuiController:_updateShopItems(shopData : table?)
    for frameName, data in pairs(shopData) do
        local frame = self.Container:FindFirstChild(frameName)
        if not frame then
            warn("Frame of that name doesn't exist")
            continue
        end

        frame.Title.Text = data.Title
        frame.Description.Text = data.Description
        frame.Cost.Text = "Cost: $" .. tostring(data.Cost)

        frame.BuyButton:SetAttribute("OriginCost", tostring(data.Cost))
        frame.BuyButton.Visible = true
    end
end


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function ShopGuiController:KnitInit()
    ShopService = Knit.GetService("ShopService")
    LeaderboardService = Knit.GetService("LeaderboardService")

    CameraController = Knit.GetController("CameraController")
end

function ShopGuiController:KnitStart()
    local targetName = string.gsub(script.Name, "Controller", "")
    self.Gui = player.PlayerGui:WaitForChild(targetName)

    self.Container = self.Gui:WaitForChild("Container")
    GeneralUI:Configure(self.Container, self.Container.Position + UDim2.new(1, 0, 0, 0))

    self.Container.DoneButton.Activated:Connect(function()
        self:HideShop()
        task.delay(1, function()
            ShopService:FinishedBuying()
        end)
    end)

    ShopService.OpenShopUISignal:Connect(function(shopData : table?)
        self:_updateShopItems(shopData)
        self:OpenShop()
    end)

    for index, button in ipairs(self.Container:GetDescendants()) do
        if button.Name ~= "BuyButton" then
            continue
        end

        local debounce = true
        button.Activated:Connect(function()
            if not debounce then
                return
            end

            debounce = false

            LeaderboardService:GetData("Coins"):andThen(function(coinAmount)
                ShopService:BuyItem(button.Parent.Name)

                if coinAmount >= tonumber(button:GetAttribute("OriginCost")) then
                    button.Visible = false
                end

                debounce = true
            end):catch(warn)
        end)
    end
end


return ShopGuiController
