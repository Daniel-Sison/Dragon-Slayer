local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create the service:
local DragonService = Knit.CreateService {
    Name = "DragonService",
}

local Modules = ReplicatedStorage.Source.Modules
local Classes = Modules.Classes
local Assets = ReplicatedStorage.Assets

local Dragon = require(Classes.Dragon)
local FrostDragon = require(Classes.FrostDragon)

local CharacterSetupService


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function DragonService:SelectRandomDragon(locationPart : BasePart?)
    local targetDragonName : string? = self:_randomDragonName()

    local targetModule = Classes:FindFirstChild(targetDragonName)
    if not targetModule then
        warn("No dragon of this name exists in classes: ", targetDragonName)
        return
    end

    targetModule = require(targetModule)

    local dragonObject = targetModule.new(locationPart.Position)
    dragonObject:Start()

    return dragonObject
end

function DragonService:SpawnDragons(locationName : string?)
    local spawnFolder : Folder? = self.StartLocations:FindFirstChild(locationName .. "_Dragons")
    if not spawnFolder then
        warn("No folder of this location name.")
        return
    end

    for _, part in ipairs(spawnFolder:GetChildren()) do
        if not part:IsA("BasePart") then
            continue
        end

        self:SelectRandomDragon(part)
    end
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function DragonService:_randomDragonName()
    local availableDragons : table? = Assets.Dragons:GetChildren()
    local randomNumber : number? = math.random(1, #availableDragons)
    local targetDragonName :string? = availableDragons[randomNumber].Name
    
    if not self.DragonContainer:FindFirstChild(targetDragonName) then
        return targetDragonName
    end

    local backupNumber = randomNumber + 1
    if backupNumber > #availableDragons then
        backupNumber = 1
    end
    local backupDragonName = availableDragons[backupNumber].Name

    return backupDragonName
end


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function DragonService:KnitInit()
    CharacterSetupService = Knit.GetService("CharacterSetupService")
end

function DragonService:KnitStart()
    self.StartLocations = workspace:WaitForChild("StartLocations")
    self.DragonContainer = workspace:WaitForChild("DragonContainer")

    self.DragonContainer.ChildRemoved:Connect(function()
        if self.DragonContainer:FindFirstChildOfClass("Model") then
            return
        end

        CharacterSetupService:NextLevel()        
    end)
end


return DragonService