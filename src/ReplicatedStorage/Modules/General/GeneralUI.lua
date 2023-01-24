local GeneralUI = {}


--[[

Usage:

Public Methods:
    - GeneralUI:Configure(frame : Frame?, hiddenPos : UDim2?)
		- Set origin position, size, and hidden position as attributes for easy access

	- GeneralUI:PlayUI(targetName : string?)
		- Play a certain UI from the ReplicatedStorage

	- GeneralUI:SimpleTween(frame, goal, duration, easingStyle, easingDirection)
		- Automatically play a tween and set the parameters in one function
		- Default is EasingStyle Quad for 1 second.
]]



----------- Services -----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")


----------- Initiated Variables -----------

local player = game.Players.LocalPlayer


----------- Public Functions -----------

-- This is used to save the original and hidden locations of a designated frame.
-- It is not a required method to use this module, but it is very helpful.
function GeneralUI:Configure(frame : Frame?, hiddenPos : UDim2?)
	frame:SetAttribute("OriginPosition", frame.Position)
	frame:SetAttribute("OriginSize", frame.Size)
	
	if hiddenPos then
		frame:SetAttribute("HiddenPosition", hiddenPos)
	end
end


-- This will find the appropriate UI in the ReplicatedStorage
-- Assuming there is a folder called "UI" in the ReplicatedStorage that holds GUIs.
function GeneralUI:PlayUI(targetName : string?)
	local gui : ScreenGui? = ReplicatedStorage.UI:FindFirstChild(targetName)
	
	if not gui then
		warn("The target GUI cannot be found.")
		return
	end
	
	gui:Clone().Parent = player.PlayerGui
end


-- Call the tween on the UI
-- If only the frame and goal are passed as parameters, 
-- then the function will default to what is provided.
function GeneralUI:SimpleTween(frame, goal, duration, easingStyle, easingDirection)
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

	local tween = TweenService:Create(frame, tweenInfo, goal)
	tween:Play()
	
	return tween
end



return GeneralUI
