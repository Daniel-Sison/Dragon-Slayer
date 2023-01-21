
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)
local ParticleHandler = require(ReplicatedStorage.Source.Modules.General.ParticleHandler)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)

local Dragon = require(ReplicatedStorage.Source.Modules.Classes.Dragon)

-- This FrostDragon class inherits functions from the "Enemy" class
local FrostDragon = {}
FrostDragon.__index = FrostDragon
setmetatable(FrostDragon, Dragon)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------


function FrostDragon.new(spawnPosition : Vector3?)
	local frostDragonObject = Dragon.new("FrostDragon", spawnPosition)
	setmetatable(frostDragonObject, FrostDragon)
	

	return frostDragonObject
end



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------






return FrostDragon