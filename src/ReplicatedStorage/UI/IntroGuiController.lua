local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)

-- Create the service:
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
    local fadeIn : Tween? = GeneralUI:SimpleTween(
        self.Container,
        {BackgroundTransparency = 0},
        0.5
    )

    fadeIn.Completed:Connect(function()
        task.delay(0.5, function()
            warn("Fading out")
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

function IntroGuiController:_runProgram()
    self.Gui.Enabled = true

    local loadingBarTween : Tween? = self:_animateLoadingBar()
    loadingBarTween.Completed:Wait()

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

    self.IntroCamTween = CameraController:CameraToPart(self.CameraPositions.StartCam2, 30)
end


function IntroGuiController:_transitionToPlayer()
    CameraController:ToggleBlur(false)

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

        if self.IntroCamTween then
            self.IntroCamTween:Cancel()
            self.IntroCamTween = nil
        end
        
        CameraController:ResetCameraToDefault()

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
