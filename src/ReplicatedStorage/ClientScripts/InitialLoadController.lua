local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


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
    if game:GetService("RunService"):IsStudio() then
        initialLoadIn = false
    end

    player.CharacterAdded:Connect(function(character : Model?)
        if not initialLoadIn then
            return
        end

        initialLoadIn = false
        task.wait(4)

        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = camPositions.StartCam1.CFrame
    
        CameraController:ToggleBlur(true, 15)
    end)
end


return InitialLoadController
