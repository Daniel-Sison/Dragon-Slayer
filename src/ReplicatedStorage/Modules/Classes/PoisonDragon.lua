
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)
local ParticleHandler = require(ReplicatedStorage.Source.Modules.General.ParticleHandler)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)

local Dragon = require(ReplicatedStorage.Source.Modules.Classes.Dragon)

-- This PoisonDragon class inherits functions from the "Enemy" class
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
    local poison = Assets.Effects.Poison:Clone()
    poison.Parent = root

	local backdrop = Assets.Effects.PoisonBackdrop:Clone()
    backdrop.Parent = root

    for i = 1, 4 do
        task.delay(1 * i, function()
            if humanoid and humanoid.Health > 0 then
                humanoid:TakeDamage(1)
            end

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