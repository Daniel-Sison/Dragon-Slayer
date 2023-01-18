local CameraController = {}


----------- Services -----------

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")


----------- Initiated Variables -----------

local camera = workspace.CurrentCamera

local blur = Instance.new("BlurEffect")
blur.Size = 15


----------- Public Functions -----------

-- Snappy way to toggle blur in and out
function CameraController:ToggleBlur(value, size)
	if size then
		blur.Size = size
	end
	
	if value then
		blur.Parent = Lighting
	else
		blur.Parent = nil
	end
end


-- Will tween the camera to part
-- If part is not provided, then will return a warning
function CameraController:CameraToPart(part, duration, easingStyle, easingDirection)
	
	local goal = {}
	
	if part then
		goal.CFrame = part.CFrame
	else
		warn("No target part given for the camera to tween to.")
		return
	end
	
	if not duration then
		duration = 1
	end
	
	if not easingStyle then
		easingStyle = Enum.EasingStyle.Quad
	end
	
	if not easingDirection then
		easingDirection = Enum.EasingDirection.Out
	end

	local tweenInfo = TweenInfo.new(
		duration,
		easingStyle,
		easingDirection
	)

	local tween = TweenService:Create(camera, tweenInfo, goal)
	tween:Play()
	
	return tween
end



return CameraController
