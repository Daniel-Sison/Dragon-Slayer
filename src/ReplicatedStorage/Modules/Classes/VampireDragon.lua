
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
	- VampireDragon:GetFireProjectile()
		- Replaces the default Fire Projectile with custom colors

	- VampireDragon:GetFireExplosion()
		- Replace the explosion particle with custom colors

    - VampireDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
		- Deal a specialized elemental effect to the humanoid
	
	
]]


local VampireDragon = {}
VampireDragon.__index = VampireDragon
setmetatable(VampireDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function VampireDragon.new(spawnPosition : Vector3, level : number)
	local vampireDragonObject = Dragon.new("Vampire Dragon", spawnPosition)
	setmetatable(vampireDragonObject, VampireDragon)
	
	vampireDragonObject.Level = level

	return vampireDragonObject
end


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


-- Replace the default projectile with provided colors
function VampireDragon:GetFireProjectile()
    local fireball = Assets.Effects.Fireball:Clone()
    fireball.Parent = workspace.EffectStorage
    fireball.CFrame = self.Mouth.CFrame

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 71, 71)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 32, 32))
	}

	self:RecolorParticles(fireball, colorSequence)

    return fireball
end



-- Replace the default explosion with provided colors
function VampireDragon:GetFireExplosion()
    local explosion = Assets.Effects.FireballPop:Clone()

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 71, 71)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 32, 32))
	}

	self:RecolorParticles(explosion, colorSequence)

    return explosion
end

-- Deal an elemental effect
function VampireDragon:DealElementalEffect(humanoid : Humanoid, root : BasePart)

    -- Create a beam
    local container = Assets.Effects.LifeDrainBeam
    local a0 : Attachment, a1 : Attachment = ParticleHandler:BeamLink(
        self.HumanoidRootPart,
        root,
        container
    )

    -- Deal damage to the player, while healing the dragon
    for i = 1, 3 do
        task.delay(1 * i, function()
            if humanoid and humanoid.Health > 0 then
                humanoid:TakeDamage(1)
                self.Humanoid.Health += 10
            end

            -- At the end of the loop, destroy the beam
            if i == 3 then
                a1:Destroy()
                a0:Destroy()
            end
        end)
    end
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------






return VampireDragon