
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
    - LavaDragon:Bite(targetRoot : BasePart?, targetHumanoid : Humanoid?)
		- Replaces the regular Bite method of the dragon class with a custom Bite.
	
	
]]


local LavaDragon = {}
LavaDragon.__index = LavaDragon
setmetatable(LavaDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function LavaDragon.new(spawnPosition : Vector3, level : number)
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


-- Replaces the Dragon parent class bite
function LavaDragon:Bite(targetRoot : BasePart, targetHumanoid : Humanoid)

	-- Copy the LavaCircle part
	local lavaCircle : Part = Assets.Effects.LavaCircle:Clone()
	lavaCircle.Position = self.HumanoidRootPart.Position - Vector3.new(0, 2.85, 0)
	lavaCircle.Parent = workspace.EffectStorage

	-- Insert the lavaCircle into the LavaContainer
	table.insert(self.LavaContainer, lavaCircle)

	-- When the lava circle is touched, then set player on fire
	lavaCircle.Touched:Connect(function(hitPart : BasePart?)
		if not hitPart:IsDescendantOf(targetRoot.Parent) then
			return
		end

		-- If the player is already burning, then return
		if targetRoot:FindFirstChild("Flames") then
			return
		end

		-- Calls the default Dragon method "Burn"
		self:Burn(targetHumanoid, targetRoot)
	end)

	GeneralTween:SimpleTween(
		lavaCircle,
		{Size = lavaCircle.Size + Vector3.new(0, 20, 20)},
		1
	)


	-- The regular bite code
	if not Raycaster:IsFacing(self.Body, targetRoot.Parent) then
        return
    end

    if (self.Mouth.Position - targetRoot.Position).Magnitude < 20 then
        targetHumanoid:TakeDamage(self.BaseBiteDamage)
    end
end



function LavaDragon:DealElementalEffect(
	humanoid : Humanoid?,
	root : BasePart?,
	explosionPosition : Vector3?
)
    return
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

-- When dragon dies, clean up the lava
function LavaDragon:_cleanLavaOnDeath()
	self.Humanoid.Died:Connect(function()
		if not self.LavaContainer then
			return
		end

		self:_cleanLava()
	end)
end

-- Cleans the lava
function LavaDragon:_cleanLava()
	for _, oldLava in ipairs(self.LavaContainer) do
		if not oldLava then
			continue
		end

		-- Fade tween
		local hideTween = GeneralTween:SimpleTween(
			oldLava,
			{Transparency = 1},
			1
		)

		-- as soon as the tween is completed, then destroy the lava
		hideTween.Completed:Connect(function()
			oldLava:Destroy()
		end)
	end
end



return LavaDragon