local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)

--[[

Usage:

Public Methods:
    - WeaponDropService:DropRandomWeapon(targetPosition : Vector3?, level : number?)
        - Drops a random weapon at the specified target position
        - The weapon is based on the level provided
]]


local WeaponDropService = Knit.CreateService {
    Name = "WeaponDropService",
}

local ToolService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function WeaponDropService:DropRandomWeapon(targetPosition : Vector3?, level : number?)
    -- Search for the appropriate folder
    local levelFolder : Folder? = ReplicatedStorage.Assets.Weapons:FindFirstChild("Level_" .. level)
    if not levelFolder then
        warn("No levelfolder of given level can be found")
        return
    end

    -- Get a table of all the children of the level folder, 
    -- and generate a random number
    local availableWeapons : table? = levelFolder:GetChildren()
    local randomNumber : number? = math.random(1, #availableWeapons)

    -- Reference to the chosen weapon based on the random number
    local chosenWeapon : Tool? = availableWeapons[randomNumber]

    -- Return a warning if the handle of the weapon doesn't exist
    local handle = chosenWeapon:FindFirstChild("Handle")
    if not handle then
        warn("This weapon has no handle: ", chosenWeapon.Name)
        return
    end

    -- Create a copy of the handle
    local interactPart : BasePart? = handle:Clone()
    interactPart.Transparency = 1
    interactPart.CanCollide = false
    interactPart.Anchored = true
    interactPart.Position = targetPosition - Vector3.new(0, 5, 0)
    interactPart.Parent = workspace.EffectStorage

    -- Load appropriate particles into the handle
    local particle : BasePart? = ReplicatedStorage.Assets.Effects.NewWeapon:Clone()
    particle.Position = targetPosition
    particle.Parent = workspace.EffectStorage

    -- Create a prormpt
    local prompt : ProximityPrompt? = Instance.new("ProximityPrompt")
    prompt.ActionText = "Collect"
    prompt.ObjectText = chosenWeapon.Name
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 7
    prompt.Parent = interactPart

    -- Debounce to prevent triggering multiple times
    local debounce : boolean? = true
    prompt.Triggered:Connect(function(player : Player?)
        if not debounce then
            return
        end

        debounce = false

        -- Delete the particles and the fake handle
        interactPart:Destroy()
        particle:Destroy()

        -- Add the tool to the player
        ToolService:AddToolToPlayer(chosenWeapon.Name, player)
    end)

    GeneralTween:SimpleTween(
        interactPart,
        {Position = interactPart.Position + Vector3.new(0, 5, 0), Transparency = 0},
        1
    )
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function WeaponDropService:KnitInit()
    ToolService = Knit.GetService("ToolService")
end

function WeaponDropService:KnitStart()
    
end


return WeaponDropService