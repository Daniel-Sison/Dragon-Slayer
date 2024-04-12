local LocalSoundController = {}


--[[

Usage:

Public Methods:
    - LocalSoundController:PlaySound(
		targetName : string?,
		fadeOutOtherSounds : boolean?,
		fadeIn : boolean?,
		seconds : number?
	)
        - Play a certain sound in the SoundService locally

]]


----------- Services -----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")


----------- Initiated Variables -----------

local player = game.Players.LocalPlayer



----------- Public Functions -----------


function LocalSoundController:PlaySound(
	targetName : string,
	fadeOutOtherSounds : boolean?,
	fadeIn : boolean?,
	seconds : number?
)
	
	-- If the targetSound cannot be found, then return
	local targetSound : Sound? = SoundService:FindFirstChild(targetName)
	if not targetSound then
		return
	end
	
	-- Will fade out all other sounds IN SOUNDSERVICE if this is set to true
	if fadeOutOtherSounds then
		self:_fadeOutOtherSounds(targetSound)
	end
	
	
	if fadeIn then
		targetSound.Volume = 0

		local goal = {Volume = targetSound:GetAttribute("OriginVolume")}

		local tweenInfo = TweenInfo.new(
			1,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local tween = TweenService:Create(targetSound, tweenInfo, goal)
		tween:Play()
	else
		if targetSound:GetAttribute("OriginVolume") then
			targetSound.Volume = targetSound:GetAttribute("OriginVolume")
		end
	end
	
	-- The time position for the sound to start at
	if seconds then
		targetSound.TimePosition = seconds
	end

	targetSound:Play()
	
	-- Return targetsound in case an event needs to be connected
	return targetSound
end





----------- Private Functions -----------

function LocalSoundController:_fadeOutOtherSounds(ignoreSound: Sound)
	for _, sound in ipairs(SoundService:GetDescendants()) do
		
		-- Ignore playing sounds
		if not sound.Playing then
			continue
		end
		
		-- Ignore sounds that are NOT music
		if not sound.Looped then
			continue
		end
		
		-- Ignore targeted sound
		if sound == ignoreSound then
			continue
		end
		
		local goal = {Volume = 0}
		
		local tweenInfo = TweenInfo.new(
			1,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local tween = TweenService:Create(sound, tweenInfo, goal)
		tween:Play()
		
		tween.Completed:Connect(function()
			sound:Stop()
		end)
	end
end


return LocalSoundController
