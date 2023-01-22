
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)
local ParticleHandler = require(ReplicatedStorage.Source.Modules.General.ParticleHandler)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)

local Dragon = require(ReplicatedStorage.Source.Modules.Classes.Dragon)

-- This FireDragon class inherits functions from the "Enemy" class
local FireDragon = {}
FireDragon.__index = FireDragon
setmetatable(FireDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function FireDragon.new(spawnPosition : Vector3?, level : number?)
	local fireDragonObject = Dragon.new("Fire Dragon", spawnPosition)
	setmetatable(fireDragonObject, FireDragon)
	
	fireDragonObject.Level = level

	return fireDragonObject
end


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


function Dragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
    self:Burn(humanoid, root)
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------




return FireDragon