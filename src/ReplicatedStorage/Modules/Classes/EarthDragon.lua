
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
    - EarthDragon:Bite(targetRoot : BasePart?, targetHumanoid : Humanoid?)
		- Replaces the regular Bite method of the dragon class with a custom Bite.
	
	
]]

local EarthDragon = {}
EarthDragon.__index = EarthDragon
setmetatable(EarthDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function EarthDragon.new(spawnPosition : Vector3?, level : number?)
	local earthDragonObject = Dragon.new("Earth Dragon", spawnPosition)
	setmetatable(earthDragonObject, EarthDragon)
	
	earthDragonObject.Level = level

	return earthDragonObject
end


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


function EarthDragon:Bite(targetRoot : BasePart?, targetHumanoid : Humanoid?)

	-- Create the effect every bite
	ParticleHandler:EarthCircleEffect(self.HumanoidRootPart)

	-- If the player is in range, then deal damage to them
	if (self.HumanoidRootPart.Position - targetRoot.Position).Magnitude < 10 then
        targetHumanoid:TakeDamage(self.BaseBiteDamage)
    end
end


function EarthDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
    return
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------






return EarthDragon