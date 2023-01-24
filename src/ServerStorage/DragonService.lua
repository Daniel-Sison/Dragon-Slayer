local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create the service:
local DragonService = Knit.CreateService {
    Name = "DragonService",
    Client = {
        LinkDragonToUI = Knit.CreateSignal(), -- Create the signal
    },
}

local Modules = ReplicatedStorage.Source.Modules
local Classes = Modules.Classes
local Assets = ReplicatedStorage.Assets

local Dragon = require(Classes.Dragon)
local FrostDragon = require(Classes.FrostDragon)

local CharacterSetupService


local CUSTOM_DRAGONS = {
    ["Poison Dragon"] = "Bright green", -- DOT damage
    ["Earth Dragon"] = "Pine Cone", -- stuns
    ["Lava Dragon"] = "Bright orange", -- places lava pools
    ["Shadow Dragon"] = "Really black", -- blinds
    ["Vampire Dragon"] = "White", -- steals health
    ["Electric Dragon"] = "New Yeller", -- stuns
}


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function DragonService:SelectRandomDragon(locationPart : BasePart?, level : number?)
    local originDragonName : string? = self:_randomDragonName()
    local targetDragonName : string? = string.gsub(originDragonName, " ", "")

    local targetModule : ModuleScript? = Classes:FindFirstChild(targetDragonName)
    if not targetModule then
        warn("No dragon of this name exists in classes: ", targetDragonName)
        return
    end

    targetModule = require(targetModule)

    local dragonObject = targetModule.new(locationPart.Position, level)
    dragonObject:Start()

    local usedDragon : Model? = Assets.Dragons:FindFirstChild(originDragonName)
    if usedDragon then
        usedDragon.Parent = Assets.UsedDragons
    end

    return dragonObject
end


function DragonService:SpawnDragons(locationName : string?, level : number?)
    local spawnFolder : Folder? = self.StartLocations:FindFirstChild(locationName .. "_Dragons")
    if not spawnFolder then
        warn("No folder of this location name.")
        return
    end

    for _, part in ipairs(spawnFolder:GetChildren()) do
        if not part:IsA("BasePart") then
            continue
        end

        local dragonObject = self:SelectRandomDragon(part, level)
        table.insert(self.AllDragons, dragonObject)

        self:_linkDragonUI(dragonObject)
    end
end


function DragonService:LoadCustomDragons()
    for dragonName, dragonColor in pairs(CUSTOM_DRAGONS) do
        local blueprintDragon : Model? = Assets.Misc.BlueprintDragon:Clone()
        blueprintDragon.Name = dragonName

        for _, part in ipairs(blueprintDragon:GetDescendants()) do
            if not part:IsA("BasePart") then
                continue
            end
    
            if part.BrickColor.Name == "White" then
                part.BrickColor = BrickColor.new(dragonColor)
            end
        end

        blueprintDragon.Parent = Assets.Dragons
    end
end


function DragonService:ResetDragons()
    self.Resetting = true

    for index, dragon in ipairs(self.AllDragons) do
        if not dragon then
            continue
        end

        dragon:Clean()
    end

    for index, usedDragon in ipairs(Assets.UsedDragons:GetChildren()) do
        usedDragon.Parent = Assets.Dragons
    end

    self.Resetting = false
    self.AllDragons = {}
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function DragonService:_linkDragonUI(dragonObject)
    for index, player in ipairs(game.Players:GetChildren()) do
        if not player then
            continue
        end

        self.Client.LinkDragonToUI:Fire(player, dragonObject.Humanoid, dragonObject.HumanoidRootPart, dragonObject.Level)
    end
end


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

    self.Resetting = false
    self.AllDragons = {}

    self:LoadCustomDragons()

    self.DragonContainer.ChildRemoved:Connect(function()
        if self.Resetting then
            return
        end

        if self.DragonContainer:FindFirstChildOfClass("Model") then
            return
        end

        CharacterSetupService:LevelComplete()        
    end)
end


return DragonService