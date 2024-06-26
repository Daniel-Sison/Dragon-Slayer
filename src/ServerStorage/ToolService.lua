local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)

--[[

Usage:

Public Methods:
    - ToolService:ConfigureTool(tool, player)
        - Use this on each tool that the player gets to make it active
        - Currently will only set up on swords

    - ToolService:UseToolAction(tool, player)
        - Will cause the tool to activate
        - This is automatically connected to the tool once 
          ToolService:ConfigureTool has been applied to it.

]]


-- Create the service:
local ToolService = Knit.CreateService {
    Name = "ToolService",
}


----------------------------------------------
----------------- CONSTANTS ------------------
----------------------------------------------


local LeaderboardService

-- Set the damage values for each sword
local BASE_SWORD_DAMAGE = {
    ["Wood Stick"] = 10,

    ["Dull Sword"] = 12,
    ["Silver Sword"] = 14,
    ["Gold Sword"] = 16,

    ["Emerald Sword"] = 19,
    ["Sapphire Sword"] = 21,
    ["Violet Sword"] = 24,

    ["Blood Sword"] = 28,
    ["Sword of Darkness"] = 33,
    ["Sword of Starlight"] = 38,
}


local SWORD_ANIMATION_CYCLE = {
    ["SlashAnim"] = "StabAnim",
    ["StabAnim"] = "SlashAnim",
}


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

-- Adds a specified tool to a player's backpack
function ToolService:AddToolToPlayer(toolName : string, player : Player)
    
    -- If the specified target tool is not there, then return a warning.
    local targetWeapon = ReplicatedStorage.Assets.Weapons:FindFirstChild(toolName, true)
    if not targetWeapon then
        warn("Weapon of the name " .. toolName .. " cannot be found in weapons folder.")
    end

    -- Copy the weapon into the backpack
    targetWeapon = targetWeapon:Clone()
    targetWeapon.Parent = player.Backpack

    -- Configure the tool so that when equipped, it works
    self:ConfigureTool(targetWeapon, player)
end


-- Setup each of the tool's connections and such
function ToolService:ConfigureTool(tool : Tool, player : Player)
    local toolConnections = {}

    local activationConnection

    -- Whenever a tool is equipped
    local equipConnection = tool.Equipped:Connect(function()
        tool.Handle.Unsheath:Play()

        -- Whenever a tool is activated
        activationConnection = tool.Activated:Connect(function()
            self:UseToolAction(player, tool)
        end)

        table.insert(toolConnections, activationConnection)
    end)

    table.insert(toolConnections, equipConnection)

    -- Disconnect the activation connections when unequipped
    local unequipConnection = tool.Unequipped:Connect(function()
        activationConnection:Disconnect()
        activationConnection = nil
    end)

    table.insert(toolConnections, unequipConnection)

    -- Clear connections if the tool is not descendant of workspace or a player
    tool.AncestryChanged:Connect(function()
        if tool:IsDescendantOf(Players) or tool:IsDescendantOf(workspace) then
            return
        end

        self:_clearConnectionsTable(toolConnections)
    end)

    -- If there's no character then just return
    -- Will probably throw an error anyways if there isn't a character
    if not player.Character then
        return
    end

    -- Clear connections when the player dies
    local deathConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
        self:_clearConnectionsTable(toolConnections)
    end)

    table.insert(toolConnections, deathConnection)
end


-- This function is activated when the tool is activated on click/tap
function ToolService:UseToolAction(player : Player, tool : Tool)
    local character = tool.Parent

    -- Return if the character doesn't exist
    if not Players:GetPlayerFromCharacter(character) then
        return
    end

    -- Return if humanoid doesn't exist
    local humanoid : Humanoid? = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local playerStrength = LeaderboardService:GetData(player, "Strength")
    if not playerStrength then
        warn("Could not find Strength data of the player, ", player.Name)
        return
    end

    -- If humanoid is dead then return
    if humanoid.Health <= 0 then
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return
    end

    -- Create a debounce for the tool
    if tool:GetAttribute("Debounce") then
        return
    end

    tool:SetAttribute("Debounce", true)
    tool.Enabled = false

    -- Cycle to the next animation
    self:_cycleAnimation(tool)

    -- Play the correct attack sound
    self:_playAttackSound(tool)

    -- Play the animation, return all targets hit during animation
    local targetList : {} = self:_attackAnimation(
        animator,
        character,
        tool
    )
    self:_dealDamageToTargetList(targetList, tool, playerStrength)

    -- When the animation ends, do the following
    tool:SetAttribute("Debounce", false)
    tool.Enabled = true

    return
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

-- Play a specified sound
function ToolService:_playAttackSound(tool : Tool)
    if tool:GetAttribute("NextAttack") == "SlashAnim" then
        tool.Handle.SwordSlash:Play()
    elseif tool:GetAttribute("NextAttack") == "StabAnim" then
        task.delay(0.75, function()
            tool.Handle.SwordLunge:Play()
        end)
    end
end

-- Given a target list, deal damage to each one
function ToolService:_dealDamageToTargetList(
    targetList : table,
    tool : Tool,
    playerStrength : number
)

    for _, model in ipairs(targetList) do
        -- If the model doesn't have a humanoid, filter it
        local humanoid : Humanoid = model:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            continue
        end

        -- Filter through all humanoids that are dead
        if humanoid.Health <= 0 then
            continue
        end

        local totalDamage = BASE_SWORD_DAMAGE[tool.Name] + playerStrength
        humanoid:TakeDamage(totalDamage)
    end
end


 -- This will cycle the attack animations
function ToolService:_cycleAnimation(tool : Tool)
    local nextAttack = tool:GetAttribute("NextAttack")

    if nextAttack then
        tool:SetAttribute("NextAttack", SWORD_ANIMATION_CYCLE[nextAttack])
    else
        -- If the attribute "NextAttack" doesn't exist, then
        -- create a new one.
        tool:SetAttribute("NextAttack", "SlashAnim")
    end
end


function ToolService:_attackAnimation(
    animator : Animator,
    character : Model,
    tool : Tool
)

    -- Find the animation of the next attack
    local chosenAnim = tool.Animations:FindFirstChild(
        tool:GetAttribute("NextAttack")
    )
    if not chosenAnim then
        warn("The chosen animation cannot be found in the animations folder of the tool.")
        return
    end

    -- Load the chosen animation into the track
    local animationTrack = animator:LoadAnimation(chosenAnim)
    animationTrack:Play()

    -- Create an attachment
    -- During the animation, the script will raycast between the attachments to see
    -- if there were any targets that intersected
    local attachment : Attachment? = tool.Handle.Attachment
    local debounce = true
    local targetList = {}

    -- While the sword is swinging, will raycast between points to detect hit
    local swingConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not debounce then
            return
        end

        debounce = false
        local oldPosition : Vector3? = attachment.WorldCFrame.Position

        task.delay(0.1, function()
            local newPosition : Vector3? = attachment.WorldCFrame.Position

            -- Use a RAYCAST system instead of TOUCH for more accurate hitboxes

            local raycastResult = Raycaster:Cast(
                oldPosition,
                newPosition,
                {character}
            )
            -- Cast between the old position and the new position of the given attachment
            -- Any results will be put into a table

            debounce = true

            
            if not raycastResult then
                return
            end

            -- If the model is already in the TargetList, then return
            local raycastModel : Model? = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
            if table.find(targetList, raycastModel) then
                return
            end

            -- If the model is not in the list, then add it
            table.insert(targetList, raycastModel)
        end)
    end)

    -- Wait for when the animationtrack ends
    animationTrack.Stopped:Wait()

    -- Disconnect the heartbeat
    swingConnection:Disconnect()
    swingConnection = nil

    -- Destroy the animation track since it's done playing
    animationTrack:Destroy()

    return targetList
end



-- Clear specified connection table given
function ToolService:_clearConnectionsTable(givenTable : {})
    for _, connection in ipairs(givenTable) do
        if not connection then
            return
        end

        connection:Disconnect()
        connection = nil
    end
end



function ToolService:_configureBackpack(player : Player)
    -- Configure tools in backpack
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if not tool:IsA("Tool") then
            continue
        end

        self:ConfigureTool(tool, player)
    end
end

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function ToolService:KnitInit()
    LeaderboardService = Knit.GetService("LeaderboardService")
end

function ToolService:KnitStart()
    
end


return ToolService