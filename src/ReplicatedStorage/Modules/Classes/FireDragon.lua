
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


function FireDragon.new(spawnPosition : Vector3?)
	local fireDragonObject = Dragon.new("FireDragon", spawnPosition)
	setmetatable(fireDragonObject, FireDragon)
	

	return fireDragonObject
end


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------




return FireDragon