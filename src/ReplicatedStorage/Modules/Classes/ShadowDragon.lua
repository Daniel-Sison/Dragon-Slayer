
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)
local ParticleHandler = require(ReplicatedStorage.Source.Modules.General.ParticleHandler)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)

local Dragon = require(ReplicatedStorage.Source.Modules.Classes.Dragon)


--[[

This Class inherits functions from the "Dragon" class.

The public methods for this class override 
default "Dragon" class methods of the same name.

Public Methods:
	- ShadowDragon:GetFireProjectile()
		- Replaces the default Fire Projectile with custom colors

	- ShadowDragon:GetFireExplosion()
		- Replace the explosion particle with custom colors

    - ShadowDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
		- Deal a specialized elemental effect to the humanoid
	
	
]]



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

-- Replace the default projectile with provided colors
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


-- Replace the default explosion with provided colors
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

	-- Find the player's PlayerGui
	-- If it doesn't exist, return
	if not player:FindFirstChild("PlayerGui") then
		return
	end

	-- Clone the blindness GUI from the effects folder
	local blindness = Assets.Effects.Blindness:Clone()
	blindness.Parent = player.PlayerGui

	-- Fade in the general tween
	local fadeIn = GeneralTween:SimpleTween(
		blindness.Frame,
		{BackgroundTransparency = 0},
		0.5
	)

	
	fadeIn.Completed:Connect(function()
		task.delay(1, function()
			-- Fade out the darkness
			local fadeOut = GeneralTween:SimpleTween(
				blindness.Frame,
				{BackgroundTransparency = 1},
				0.5
			)

			-- When the fade is completed, the blindness GUI gets destroyed
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