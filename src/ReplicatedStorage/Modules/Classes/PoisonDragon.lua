
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
	- PoisonDragon:GetFireProjectile()
		- Replaces the default Fire Projectile with custom colors

	- PoisonDragon:GetFireExplosion()
		- Replace the explosion particle with custom colors

    - PoisonDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
		- Deal a specialized elemental effect to the humanoid
	
	
]]


local PoisonDragon = {}
PoisonDragon.__index = PoisonDragon
setmetatable(PoisonDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function PoisonDragon.new(spawnPosition : Vector3?, level : number?)
	local poisonDragonObject = Dragon.new("Poison Dragon", spawnPosition)
	setmetatable(poisonDragonObject, PoisonDragon)
	
	poisonDragonObject.Level = level

	return poisonDragonObject
end



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


-- Replace the default projectile with provided colors
function PoisonDragon:GetFireProjectile()
    local fireball = Assets.Effects.Fireball:Clone()
    fireball.Parent = workspace.EffectStorage
    fireball.CFrame = self.Mouth.CFrame

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 255, 41)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 255, 220))
	}

	self:RecolorParticles(fireball, colorSequence)

    return fireball
end


-- Replace the default explosion with provided colors
function PoisonDragon:GetFireExplosion()
    local explosion = Assets.Effects.FireballPop:Clone()

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 255, 41)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 255, 220))
	}

	self:RecolorParticles(explosion, colorSequence)

    return explosion
end


function PoisonDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
    -- The poison particle
    local poison = Assets.Effects.Poison:Clone()
    poison.Parent = root

    -- The smoke behind the poison particle
	local backdrop = Assets.Effects.PoisonBackdrop:Clone()
    backdrop.Parent = root

    -- Deals 4 damage to the player
    for i = 1, 4 do
        task.delay(1 * i, function()
            if humanoid and humanoid.Health > 0 then
                humanoid:TakeDamage(1)
            end

            -- Destroy particle on the last loop
            if i == 4 then
                poison:Destroy()
				backdrop:Destroy()
            end
        end)
    end
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------






return PoisonDragon