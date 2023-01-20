local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)

-- Create the service:
local StatsGuiController = Knit.CreateController {
    Name = "StatsGuiController",
}

local player = game.Players.LocalPlayer

local CoinService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function StatsGuiController:UpdateCoins(newCoinAmount : number?)
    self.CoinTextHolder.Text = tostring(newCoinAmount)
end

-- Reveal all frames that are children of the GUI
function StatsGuiController:ShowAllUI()
    for index, frame in ipairs(self.Gui:GetChildren()) do

        -- Skip over items that are not frames
        if not frame:IsA("Frame") then
            continue
        end

        -- A simple tweening to set the frame to its original position
        GeneralUI:SimpleTween(
            frame,
            {Position = frame:GetAttribute("OriginPosition")},
            0.35
        )
    end
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function StatsGuiController:KnitInit()
    CoinService = Knit.GetService("CoinService")
end

function StatsGuiController:KnitStart()
    local targetName = string.gsub(script.Name, "Controller", "")
    self.Gui = player.PlayerGui:WaitForChild(targetName)

    self.CoinContainer = self.Gui:WaitForChild("CoinContainer")
    self.CoinTextHolder = self.CoinContainer:WaitForChild("TextHolder")
    
    -- This function sets the second argument as the element's attribute as "HiddenPosition"
    GeneralUI:Configure(self.CoinContainer, self.CoinContainer.Position + UDim2.new(-1, 0, 0, 0))
    -- Move the coin container to the hidden position
    self.CoinContainer.Position = self.CoinContainer:GetAttribute("HiddenPosition")


    -- Whenever the CoinService updates a player's UI
    CoinService.UpdateCoinUI:Connect(function(newCoinAmount : number?)
        self:UpdateCoins(newCoinAmount)
    end)

end


return StatsGuiController
