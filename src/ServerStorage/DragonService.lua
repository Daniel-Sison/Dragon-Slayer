local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create the service:
local DragonService = Knit.CreateService {
    Name = "DragonService",
}

local Modules = ReplicatedStorage.Source.Modules
local Classes = Modules.Classes

local Dragon = require(Classes.Dragon)

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function DragonService:KnitInit()

end

function DragonService:KnitStart()
    local dragonObject = Dragon.new("FrostDragon")
    dragonObject:StartBehavior()
end


return DragonService