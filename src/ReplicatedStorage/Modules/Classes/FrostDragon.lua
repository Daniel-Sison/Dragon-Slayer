
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
	- FrostDragon:GetFireProjectile()
		- Replaces the default Fire Projectile with custom colors

	- FrostDragon:GetFireExplosion()
		- Replace the explosion particle with custom colors

    - FrostDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
		- Deal a specialized elemental effect to the humanoid
	
	
]]



local FrostDragon = {}
FrostDragon.__index = FrostDragon
setmetatable(FrostDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function FrostDragon.new(spawnPosition : Vector3?, level : number?)
	local frostDragonObject = Dragon.new("Frost Dragon", spawnPosition)
	setmetatable(frostDragonObject, FrostDragon)
	
	frostDragonObject.Level = level

	return frostDragonObject
end



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


-- Replace the default projectile with provided colors
function FrostDragon:GetFireProjectile()
    local fireball = Assets.Effects.Fireball:Clone()
    fireball.Parent = workspace.EffectStorage
    fireball.CFrame = self.Mouth.CFrame

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 167, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 223, 255))
	}

	self:RecolorParticles(fireball, colorSequence)

    return fireball
end



-- Replace the default explosion with provided colors
function FrostDragon:GetFireExplosion()
    local explosion = Assets.Effects.FireballPop:Clone()

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 167, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 223, 255))
	}

	self:RecolorParticles(explosion, colorSequence)

    return explosion
end


function FrostDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
    return
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------






return FrostDragon