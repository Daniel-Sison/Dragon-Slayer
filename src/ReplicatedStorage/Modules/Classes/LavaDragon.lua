
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)
local ParticleHandler = require(ReplicatedStorage.Source.Modules.General.ParticleHandler)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)

local Dragon = require(ReplicatedStorage.Source.Modules.Classes.Dragon)

-- This LavaDragon class inherits functions from the "Enemy" class
local LavaDragon = {}
LavaDragon.__index = LavaDragon
setmetatable(LavaDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function LavaDragon.new(spawnPosition : Vector3?, level : number?)
	local lavaDragonObject = Dragon.new("Lava Dragon", spawnPosition)
	setmetatable(lavaDragonObject, LavaDragon)
	
	lavaDragonObject.Level = level
	lavaDragonObject.LavaContainer = {}

	lavaDragonObject:_cleanLavaOnDeath()

	return lavaDragonObject
end



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


function LavaDragon:Bite(targetRoot : BasePart?, targetHumanoid : Humanoid?)
	local lavaCircle : Part? = Assets.Effects.LavaCircle:Clone()
	lavaCircle.Position = self.HumanoidRootPart.Position - Vector3.new(0, 2.85, 0)
	lavaCircle.Parent = workspace.EffectStorage
	table.insert(self.LavaContainer, lavaCircle)

	lavaCircle.Touched:Connect(function(hitPart : BasePart?)
		if not hitPart:IsDescendantOf(targetRoot.Parent) then
			return
		end

		if targetRoot:FindFirstChild("Flames") then
			return
		end

		self:Burn(targetHumanoid, targetRoot)
	end)

	GeneralTween:SimpleTween(
		lavaCircle,
		{Size = lavaCircle.Size + Vector3.new(0, 20, 20)},
		1
	)

	if not Raycaster:IsFacing(self.Body, targetRoot.Parent) then
        return
    end

    if (self.Mouth.Position - targetRoot.Position).Magnitude < 20 then
        targetHumanoid:TakeDamage(self.BaseBiteDamage)
    end
end



function LavaDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
    return
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function LavaDragon:_cleanLavaOnDeath()
	self.Humanoid.Died:Connect(function()
		if not self.LavaContainer then
			return
		end

		self:_cleanLava()
	end)
end


function LavaDragon:_cleanLava()
	for index, oldLava in ipairs(self.LavaContainer) do
		if not oldLava then
			continue
		end

		local hideTween = GeneralTween:SimpleTween(
			oldLava,
			{Transparency = 1},
			1
		)

		hideTween.Completed:Connect(function()
			oldLava:Destroy()
		end)
	end
end



return LavaDragon