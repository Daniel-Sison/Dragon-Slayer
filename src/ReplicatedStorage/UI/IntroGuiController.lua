local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)
local StarterGui = game:GetService("StarterGui")


--[[

Usage:

Public Methods:
    - IntroGuiController:FadeInAndOut()
        - Runs the fade in-out effect
        - Currently only being called during teleportation of the player
]]

local IntroGuiController = Knit.CreateController {
    Name = "IntroGuiController",
}

local player = game.Players.LocalPlayer

local CameraController
local StatsGuiController
local InitialLoadController

local CharacterSetupService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function IntroGuiController:FadeInAndOut()

    -- Fade the dark background in
    local fadeIn : Tween? = GeneralUI:SimpleTween(
        self.Container,
        {BackgroundTransparency = 0},
        0.5
    )

    -- When previous tween has been completed, then fade out
    fadeIn.Completed:Connect(function()

        -- Use task.delay instead of task.wait to prevent yield
        task.delay(0.5, function()

            GeneralUI:SimpleTween(
                self.Container,
                {BackgroundTransparency = 1},
                0.5
            )
            
        end)
    end)
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


function IntroGuiController:_animateLoadingBar()
    self.LoadingBar.Size = UDim2.new(0, 0, self.LoadingBar.Size.Y, 0)

    return GeneralUI:SimpleTween(
        self.LoadingBar,
        {Size = self.LoadingBar:GetAttribute("OriginSize")},
        5
    )
end


-- Called at the start of the game, runs the loading bar and sets up the GUI
function IntroGuiController:_runProgram()
    self.Gui.Enabled = true
    StarterGui:SetCore("ResetButtonCallback", false)

    local loadingBarTween : Tween? = self:_animateLoadingBar()
    loadingBarTween.Completed:Wait()

    -- Animate various UI elements after loadingbar has completed

    for _, item in ipairs(self.LoadingItems:GetChildren()) do
        GeneralUI:SimpleTween(
            item,
            {Position = item:GetAttribute("HiddenPosition")},
            0.75,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        )
    end

    GeneralUI:SimpleTween(
        self.PlayButton,
        {Position = self.PlayButton:GetAttribute("OriginPosition")},
        1
    )

    GeneralUI:SimpleTween(
        self.Container,
        {BackgroundTransparency = 1},
        2
    )

    -- Simple camera effect
    self.IntroCamTween = CameraController:CameraToPart(self.CameraPositions.StartCam2, 30)
end

-- When the play button has been clicked
function IntroGuiController:_transitionToPlayer()

    -- Disable the blur
    CameraController:ToggleBlur(false)

    -- Animate UI elements out
    GeneralUI:SimpleTween(
        self.GameTitle,
        {Position = self.GameTitle.Position - UDim2.new(0, 0, 1, 0)},
        0.35,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    GeneralUI:SimpleTween(
        self.PlayButton,
        {Position = self.PlayButton:GetAttribute("HiddenPosition")},
        0.35,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local fadeIn : Tween? = GeneralUI:SimpleTween(
        self.Container,
        {BackgroundTransparency = 0},
        0.5
    )

    fadeIn.Completed:Connect(function()
        local fadeOut = GeneralUI:SimpleTween(
            self.Container,
            {BackgroundTransparency = 1},
            0.5
        )

        -- Cancel the IntroCamTween if it's still running
        if self.IntroCamTween then
            self.IntroCamTween:Cancel()
            self.IntroCamTween = nil
        end
        
        -- Reset the camera, enable resetting
        CameraController:ResetCameraToDefault()
        StarterGui:SetCore("ResetButtonCallback", true)

        -- When all animations have completed, then
        -- show the stats and activate IntroFinished()
        fadeOut.Completed:Connect(function()
            StatsGuiController:ShowAllUI()
            InitialLoadController:IntroFinished()
        end)
    end)
end

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function IntroGuiController:KnitInit()
    CameraController = Knit.GetController("CameraController")
    StatsGuiController = Knit.GetController("StatsGuiController")
    InitialLoadController = Knit.GetController("InitialLoadController")

    CharacterSetupService = Knit.GetService("CharacterSetupService")
end


function IntroGuiController:KnitStart()
    local targetName = string.gsub(script.Name, "Controller", "")
    self.Gui = player.PlayerGui:WaitForChild(targetName)

    self.CameraPositions = workspace:WaitForChild("CameraPositions")

    self.Container = self.Gui:WaitForChild("Container")
    self.GameTitle = self.Container:WaitForChild("Title")
    self.LoadingItems = self.Container:WaitForChild("LoadingItems")

    for index, item in ipairs(self.LoadingItems:GetChildren()) do
       -- Sets the second argument as the element's attribute as "HiddenPosition"
        GeneralUI:Configure(item, item.Position + UDim2.new(0, 0, 1, 0))
    end

    self.LoadingBar = self.LoadingItems:WaitForChild("LoadingBar")

    self.PlayButton = self.LoadingItems:WaitForChild("PlayButton")
    self.PlayButton.Parent = self.Container
    self.PlayButton.Position = self.PlayButton:GetAttribute("HiddenPosition")

    local debounce : boolean? = true
    self.PlayButton.Activated:Connect(function()
        if not debounce then
            return
        end

        debounce = false

        self:_transitionToPlayer()
    end)

    CharacterSetupService.FadeTransition:Connect(function()
        self:FadeInAndOut()
    end)


    self:_runProgram()
end



return IntroGuiController
