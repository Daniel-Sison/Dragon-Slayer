
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)
local ParticleHandler = require(ReplicatedStorage.Source.Modules.General.ParticleHandler)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)

local Dragon = require(ReplicatedStorage.Source.Modules.Classes.Dragon)

-- This ShadowDragon class inherits functions from the "Enemy" class
local ShadowDragon = {}
ShadowDragon.__index = ShadowDragon
setmetatable(ShadowDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function ShadowDragon.new(spawnPosition : Vector3?, level : number?)
	local shadowDragonObject = Dragon.new("Shadow Dragon", spawnPosition)
	setmetatable(shadowDragonObject, ShadowDragon)
	
	shadowDragonObject.Level = level

	return shadowDragonObject
end



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


function ShadowDragon:GetFireProjectile()
    local fireball = Assets.Effects.Fireball:Clone()
    fireball.Parent = workspace.EffectStorage
    fireball.CFrame = self.Mouth.CFrame

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	}

	self:RecolorParticles(fireball, colorSequence)

    return fireball
end


function ShadowDragon:GetFireExplosion()
    local explosion = Assets.Effects.FireballPop:Clone()

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	}

	self:RecolorParticles(explosion, colorSequence)

    return explosion
end


function ShadowDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
    local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
	if not player then
		return
	end

	if not player:FindFirstChild("PlayerGui") then
		return
	end

	local blindness = Assets.Effects.Blindness:Clone()
	blindness.Parent = player.PlayerGui

	local fadeIn = GeneralTween:SimpleTween(
		blindness.Frame,
		{BackgroundTransparency = 0},
		0.5
	)

	fadeIn.Completed:Connect(function(playbackState)
		task.delay(1, function()
			local fadeOut = GeneralTween:SimpleTween(
				blindness.Frame,
				{BackgroundTransparency = 1},
				0.5
			)

			fadeOut.Completed:Connect(function()
				blindness:Destroy()
			end)
		end)
	end)
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------






return ShadowDragon