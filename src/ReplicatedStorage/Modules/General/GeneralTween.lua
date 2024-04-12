local GeneralTween = {}



--[[

Usage:

Public Methods:
    - GeneralTween:SimpleTween(item : any?, goal, duration, easingStyle, easingDirection)
		- A simple tween for any item
		- Similar to GeneralUI:SimpleTween
]]



----------- Services -----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")


----------- Initiated Variables -----------

local player = game.Players.LocalPlayer


----------- Public Functions -----------

-- Same thing as GeneralUI but for any item
function GeneralTween:SimpleTween(
	item : any,
	goal: {},
	duration: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?
)

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

	local tween = TweenService:Create(item, tweenInfo, goal)
	tween:Play()
	
	return tween
end



return GeneralTween
