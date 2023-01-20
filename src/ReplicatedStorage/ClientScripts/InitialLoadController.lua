local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local InitialLoadController = Knit.CreateController {
    Name = "InitialLoadController",
}

local CameraController

local player = game.Players.LocalPlayer

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function InitialLoadController:KnitInit()
    CameraController = Knit.GetController("CameraController")
end

function InitialLoadController:KnitStart()
   -- task.wait(1)

    local camPositions = workspace:WaitForChild("CameraPositions")
    local camera = workspace.CurrentCamera

    player.CharacterAdded:Connect(function(character)
        task.wait(4)

        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = camPositions.StartCam1.CFrame
     
        CameraController:ToggleBlur(true, 15)
    end)
end


return InitialLoadController
