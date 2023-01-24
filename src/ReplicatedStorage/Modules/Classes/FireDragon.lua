
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

    - FireDragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
		- Deal a specialized elemental effect to the humanoid
	
	
]]



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
	-- Use the default burn method on the humanoid that was hit
    self:Burn(humanoid, root)
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------




return FireDragon