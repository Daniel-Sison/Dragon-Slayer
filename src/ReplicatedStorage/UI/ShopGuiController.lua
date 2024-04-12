local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)

--[[

Usage:

Public Methods:
    - ShopGuiController:OpenShop()
        - Open the shop

    - ShopGuiController:HideShop()
        - Hide the shop

]]

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
    -- Enable the UI, move the container to the hidden position
    self.Gui.Enabled = true
    self.Container.Position = self.Container:GetAttribute("HiddenPosition")

    -- Allow the background blur
    -- Player cannot reset while in the shop
    CameraController:ToggleBlur(true)
    StarterGui:SetCore("ResetButtonCallback", false)

    -- Slide shop in
    GeneralUI:SimpleTween(
        self.Container,
        {Position = self.Container:GetAttribute("OriginPosition")},
        0.35,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
end


function ShopGuiController:HideShop()
    -- Disable the background blur
    -- Allow resetting
    CameraController:ToggleBlur(false)
    StarterGui:SetCore("ResetButtonCallback", true)

    -- Slide shop out to its hidden position
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

-- Update the shop items based on given data
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

    -- Sets the second argument as the element's attribute as "HiddenPosition"
    GeneralUI:Configure(
        self.Container,
        self.Container.Position + UDim2.new(1, 0, 0, 0)
    )

    -- When the player is done shopping
    self.Container.DoneButton.Activated:Connect(function()
        -- Hide the shop
        self:HideShop()

        -- Let the Server know that the client is finished buying
        task.delay(1, function()
            ShopService:FinishedBuying()
        end)
    end)

    -- The shop is opened when entering a portal
    ShopService.OpenShopUISignal:Connect(function(shopData : table?)
        self:_updateShopItems(shopData)
        self:OpenShop()
    end)

    -- For each "Buy" button in the shop
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

            LeaderboardService:GetData("Coins"):andThen(function(coinAmount: number)
                -- Will attempt to buy on the server
                -- If the server confirms the buy, then it will be bought
                ShopService:BuyItem(button.Parent.Name)

                -- If the player has more money than the cost
                -- make the button disappear
                if coinAmount >= tonumber(button:GetAttribute("OriginCost")) then
                    button.Visible = false
                end

                -- Set the debounce to true after promise has been recieved
                debounce = true
            end):catch(warn)
        end)
    end
end


return ShopGuiController
