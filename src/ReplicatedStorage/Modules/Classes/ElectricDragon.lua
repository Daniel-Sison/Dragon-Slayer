
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)
local ParticleHandler = require(ReplicatedStorage.Source.Modules.General.ParticleHandler)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)

local Dragon = require(ReplicatedStorage.Source.Modules.Classes.Dragon)

-- This ElectricDragon class inherits functions from the "Enemy" class
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


function ElectricDragon:GetFireExplosion()
    local explosion = Assets.Effects.FireballPop:Clone()

	local colorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(243, 255, 75)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 136, 255))
	}

	self:RecolorParticles(explosion, colorSequence)

    return explosion
end


function ElectricDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
    local electricAttachment : Attachment? = Assets.Effects.Electricity.Attachment:Clone()
    electricAttachment.Parent = root

    humanoid.PlatformStand = true

    local duration = 2.5
    local pulseAmount = 5

    for i = 1, pulseAmount do
        task.delay((duration / pulseAmount) * i, function()
            for index, particle in ipairs(electricAttachment:GetChildren()) do
                particle:Emit(particle.Rate)
            end
        end)
    end

    task.delay(duration, function()
        humanoid.PlatformStand = false
        electricAttachment:Destroy()
    end)
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------






return ElectricDragon