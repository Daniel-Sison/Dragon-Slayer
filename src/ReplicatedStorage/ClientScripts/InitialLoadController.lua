local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


--[[

Usage:

Public Methods:
	- InitialLoadController:IntroFinished()
		- Is called when the intro GUI is finished
        - Calls the CharacterSetupService to start the player

]]


local InitialLoadController = Knit.CreateController {
    Name = "InitialLoadController",
}

local CameraController
local CharacterSetupService

local player = game.Players.LocalPlayer

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function InitialLoadController:IntroFinished()
    CharacterSetupService:StartPlayer()
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function InitialLoadController:KnitInit()
    CameraController = Knit.GetController("CameraController")
    CharacterSetupService = Knit.GetService("CharacterSetupService")
end

function InitialLoadController:KnitStart()
    local camPositions = workspace:WaitForChild("CameraPositions")
    local camera = workspace.CurrentCamera

    local initialLoadIn = true

    player.CharacterAdded:Connect(function(character : Model?)

        -- If player has already loaded in, then return
        if not initialLoadIn then
            return
        end

        initialLoadIn = false

        task.wait(4)

        -- Setup the intro camera
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = camPositions.StartCam1.CFrame
    
        -- Turn on the blur
        CameraController:ToggleBlur(true, 15)
    end)
end


return InitialLoadController
