
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
	- ElectricDragon:GetFireProjectile()
		- Replaces the default Fire Projectile with custom colors

	- ElectricDragon:GetFireExplosion()
		- Replace the explosion particle with custom colors

    - ElectricDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
		- Deal a specialized elemental effect to the humanoid
	
	
]]


local ElectricDragon = {}
ElectricDragon.__index = ElectricDragon
setmetatable(ElectricDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function ElectricDragon.new(spawnPosition : Vector3?, level : number?)
	local electricDragonObject = Dragon.new("Electric Dragon", spawnPosition)
	setmetatable(electricDragonObject, ElectricDragon)
	
	electricDragonObject.Level = level

	return electricDragonObject
end



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


-- Replace the default projectile with provided colors
function ElectricDragon:GetFireProjectile()
    local fireball = Assets.Effects.Fireball:Clone()
    fireball.Parent = workspace.EffectStorage
    fireball.CFrame = self.Mouth.CFrame

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(243, 255, 75)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 136, 255))
	}

	self:RecolorParticles(fireball, colorSequence)

    return fireball
end



-- Replace the default explosion with provided colors
function ElectricDragon:GetFireExplosion()
    local explosion = Assets.Effects.FireballPop:Clone()

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(243, 255, 75)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 136, 255))
	}

	self:RecolorParticles(explosion, colorSequence)

    return explosion
end


function ElectricDragon:DealElementalEffect(
    humanoid : Humanoid?,
    root : BasePart?
)

    if not humanoid then
        return
    end

    if not root then
        return
    end

    -- Clone electricity effect
    local electricAttachment : Attachment = Assets.Effects.Electricity.Attachment:Clone()
    electricAttachment.Parent = root

    -- Make the humanoid unable to walk
    humanoid.PlatformStand = true

    -- Lasts for 1.5 seconds
    local duration = 1.5
    local pulseAmount = 5

    -- Pulse the electric particle 5 times within the duration
    for i = 1, pulseAmount do
        task.delay((duration / pulseAmount) * i, function()
            for _, particle in ipairs(electricAttachment:GetChildren()) do
                particle:Emit(particle.Rate)
            end
        end)
    end

    -- At the end of the duration, player can walk and destroy the electric particle
    task.delay(duration, function()
        humanoid.PlatformStand = false
        electricAttachment:Destroy()
    end)
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------






return ElectricDragon