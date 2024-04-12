local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)
local StarterGui = game:GetService("StarterGui")


--[[

Usage:

Public Methods:
    - GameEndGuiController:GameEnded(playerWon : boolean)
        - Runs when the game has ended
        - Reveals the "Play Again" button

    - GameEndGuiController:Hide()
        - Hide the game ended UI
]]


local GameEndGuiController = Knit.CreateController {
    Name = "GameEndGuiController",
}

local player = game.Players.LocalPlayer

local CameraController
local StatsGuiController
local InitialLoadController

local CharacterSetupService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


function GameEndGuiController:GameEnded(playerWon : boolean)
    -- Disable resetting while this screen is active
    StarterGui:SetCore("ResetButtonCallback", false)

    -- Configure message based on wether player won or lost
    local delayTime = 0
    if playerWon then
        self.Description.Text = "YOU WIN! Great job. You defeated all the levels."
        delayTime = 2
    else
        self.Description.Text = "You died. Click the button if you want to try again."
    end

    -- Hide the play button while game is resetting
    self.PlayButton.Visible = false
    self.PlayButton.Position = self.PlayButton:GetAttribute("HiddenPosition")

    self.Container.Size = UDim2.new(0, 0, 0, 0)
    self.Gui.Enabled = true

    local reveal : Tween? = GeneralUI:SimpleTween(
        self.Container,
        {Size = self.Container:GetAttribute("OriginSize")},
        0.15
    )

    -- When the UI is revealed
    reveal.Completed:Connect(function()

        -- Make the play button visible
        self.PlayButton.Visible = true

        -- then animate it in
        task.delay(delayTime, function()
            GeneralUI:SimpleTween(
                self.PlayButton,
                {Position = self.PlayButton:GetAttribute("OriginPosition")},
                1
            )
        end)
    end)
end

-- Hide the entire UI
function GameEndGuiController:Hide()

    -- Allow player to reset
    StarterGui:SetCore("ResetButtonCallback", true)

    local hideTween : Tween? = GeneralUI:SimpleTween(
        self.Container,
        {Size = UDim2.new(0, 0, 0, 0)},
        0.15,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
    )

    return hideTween
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function GameEndGuiController:KnitInit()
    CameraController = Knit.GetController("CameraController")
    StatsGuiController = Knit.GetController("StatsGuiController")
    InitialLoadController = Knit.GetController("InitialLoadController")

    CharacterSetupService = Knit.GetService("CharacterSetupService")
end


function GameEndGuiController:KnitStart()
    local targetName = string.gsub(script.Name, "Controller", "")
    self.Gui = player.PlayerGui:WaitForChild(targetName)

    self.Container = self.Gui:WaitForChild("Container")
    self.Description = self.Container:WaitForChild("Description")
    self.PlayButton = self.Container:WaitForChild("PlayButton")

    -- Configure UI elements so that the attributes "OriginPosition" and "HiddenPosition"
    -- can be used
    GeneralUI:Configure(self.Container)
    GeneralUI:Configure(self.PlayButton, self.PlayButton.Position + UDim2.new(0, 0, 1, 0))

    CharacterSetupService.GameEndedForPlayer:Connect(function(playerWon : boolean?)
        self:GameEnded(playerWon)
    end)

    local debounce = true
    self.PlayButton.Activated:Connect(function()
        if not debounce then
            return
        end

        debounce = false

        local hide : Tween? = self:Hide()

        -- When hide tween has completed
        hide.Completed:Connect(function()
            self.Gui.Enabled = false

            -- Start the player on the Server
            CharacterSetupService:StartPlayer()
            debounce = true
        end)
    end)
end


return GameEndGuiController
