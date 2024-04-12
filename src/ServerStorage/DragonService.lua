local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

--[[

Usage:

Public Methods:
    - DragonService:SelectRandomDragon(locationPart : BasePart, level : number)
        - Find a random dragon in the available dragons folder
        - Spawns it at the specified part at the specified level

    - DragonService:SpawnDragons(locationName : string, level : number)
        - Go through each available dragon spawn location and spawn a dragon
        - Calls "SelectRandomDragon" on each location
    
    - DragonService:LoadCustomDragons()
        - Loads custom dragons based on the CUSTOM_DRAGONS table

    - DragonService:ResetDragons()
        - Reset all the dragons when the game ends or resets
]]

local DragonService = Knit.CreateService {
    Name = "DragonService",
    Client = {
        LinkDragonToUI = Knit.CreateSignal(), -- Create the signal
    },
}

local Modules = ReplicatedStorage.Source.Modules
local Classes = Modules.Classes
local Assets = ReplicatedStorage.Assets


local CharacterSetupService


-- Describes each dragon and their primary color theme
local CUSTOM_DRAGONS = {
    ["Poison Dragon"] = "Bright green",
    ["Earth Dragon"] = "Pine Cone",
    ["Lava Dragon"] = "Bright orange",
    ["Shadow Dragon"] = "Really black",
    ["Vampire Dragon"] = "White",
    ["Electric Dragon"] = "New Yeller",
}


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

-- Select a random dragon from the dragons folder
function DragonService:SelectRandomDragon(locationPart : BasePart, level : number)
    local originDragonName : string = self:_randomDragonName()
    local targetDragonName : string = string.gsub(originDragonName, " ", "")

    -- Finds the correct module that inherits from the specified dragon class
    local targetModule : ModuleScript? = Classes:FindFirstChild(targetDragonName)
    if not targetModule then
        warn("No dragon of this name exists in classes: ", targetDragonName)
        return
    end

    targetModule = require(targetModule)

    -- Create the dragon
    local dragonObject = targetModule.new(locationPart.Position, level)
    -- Start it up
    dragonObject:Start()

    -- Move the dragon model to "UseDragons" so that it will not be used
    -- in future levels until the game is reset
    local usedDragon : Model? = Assets.Dragons:FindFirstChild(originDragonName)
    if usedDragon then
        usedDragon.Parent = Assets.UsedDragons
    end

    -- Return the dragon object
    return dragonObject
end

-- Spawn the dragons
function DragonService:SpawnDragons(locationName : string, level : number)
    local spawnFolder : Folder? = self.StartLocations:FindFirstChild(
        locationName .. "_Dragons"
    )
    if not spawnFolder then
        warn("No folder of this location name.")
        return
    end

    for _, part in ipairs(spawnFolder:GetChildren()) do
        if not part:IsA("BasePart") then
            continue
        end

        -- Select a random dragon and spawn it at the part
        local dragonObject = self:SelectRandomDragon(part, level)

        -- Insert it into the "AllDragons" table
        table.insert(self.AllDragons, dragonObject)

        -- Prep the UI so that when the player gets close,
        -- They can see its healthbar, name, and level above
        self:_linkDragonUI(dragonObject)
    end
end

-- Called at the beginning of the game
function DragonService:LoadCustomDragons()

    -- Basically loops through the CUSTOM_DRAGONS dictionary
    -- and creates a dragon, and places it into the Dragons folder in ReplicatedStorage > Assets
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

-- Reset all the dragons
-- This is called when the game ends
function DragonService:ResetDragons()
    self.Resetting = true

    -- Clean up existing dragons
    for index, dragon in ipairs(self.AllDragons) do
        if not dragon then
            continue
        end

        dragon:Clean()
    end

    -- Move used dragons back to Dragons folder
    -- so that it can be used again in the next game
    for index, usedDragon in ipairs(Assets.UsedDragons:GetChildren()) do
        usedDragon.Parent = Assets.Dragons
    end


    self.Resetting = false
    self.AllDragons = {}
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

-- Link the dragon to the UI so when the player gets close, the UI shows up
function DragonService:_linkDragonUI(dragonObject)
    for _, player in ipairs(game.Players:GetChildren()) do
        if not player then
            continue
        end

        -- Call it on the client
        self.Client.LinkDragonToUI:Fire(
            player,
            dragonObject.Humanoid,
            dragonObject.HumanoidRootPart,
            dragonObject.Level
        )
    end
end


-- Find a random dragon name based on available dragons
function DragonService:_randomDragonName()
    local availableDragons : table? = Assets.Dragons:GetChildren()
    local randomNumber : number? = math.random(1, #availableDragons)
    local targetDragonName :string? = availableDragons[randomNumber].Name
    
    -- If this dragon is NOT in the workspace, then return it
    if not self.DragonContainer:FindFirstChild(targetDragonName) then
        return targetDragonName
    end

    -- If this dragon is already in the workspace, then find a different one
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

    -- Load the custom dragons in
    self:LoadCustomDragons()

    -- Whenever a dragon dies, check for level complete
    self.DragonContainer.ChildRemoved:Connect(function()

        -- If game ended and is resetting, then return
        if self.Resetting then
            return
        end

        -- If there is still a dragon in the container, then return
        if self.DragonContainer:FindFirstChildOfClass("Model") then
            return
        end

        -- Run level complete when there are no more dragons left
        CharacterSetupService:LevelComplete()        
    end)
end


return DragonService