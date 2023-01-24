
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)
local ParticleHandler = require(ReplicatedStorage.Source.Modules.General.ParticleHandler)
local Raycaster = require(ReplicatedStorage.Source.Modules.General.Raycaster)



--[[

Usage:

Public Methods:
    - The Dragon superclass

    - Dragon.new(bodyName, spawnPosition)
        - Constructor to initiate the object

    - Dragon:Start()
        - Needs to be called after being initialized
        - Begins the dragon's behavior


    ----------
    - The following functions will automatically be activated after Dragon:Start() is called
    ----------


    - Dragon:MoveDragonTo(position)
        - Makes the Dragon walk to a certain position

    - Dragon:Attack()
        - If self.Target has been set, then will attack that target
    
    - Dragon:Clean()
        - Cleans up the dragon and its connections

    - Dragon:Roam()
        - Dragon will roam around its origin point

    - Dragon:Bite(targetRoot : BasePart?, targetHumanoid : Humanoid?)
        - Default bite attack
    
    - Dragon:Burn(humanoid : Humanoid?, root : BasePart?)
        - Default burn effect

    - Dragon:RecolorParticles(container : any?, colorSequence : ColorSequence?)
        - Recolors given paricles, applies the new colorsequence
]]



local Dragon = {}
Dragon.__index = Dragon

----------------------------------------------
----------------- CONSTANTS ------------------
----------------------------------------------


local ANIMATION_LIST = {
    Idle = "rbxassetid://12191600961",
    Walk = "rbxassetid://12191604172",
    WingBeat = "rbxassetid://12191605953",
    FireBreath = "rbxassetid://12191607555",
    Death = "rbxassetid://12191609066",
}

local BEHAVIOR_CYCLE = {
    Roam = "Stay",
    Stay = "Roam",
}

local ATTACK_CYCLE = {
    WingBeat = "FireBreath",
    FireBreath = "WingBeat",
}

----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------

function Dragon.new(bodyName : string?, spawnPosition : Vector3?)
    local DragonObject = {}
    setmetatable(DragonObject, Dragon)

    -- BodyParts
    DragonObject.Body = Assets.Dragons:FindFirstChild(bodyName):Clone()
    DragonObject.Body.Parent = workspace.DragonContainer
    DragonObject.Humanoid = DragonObject.Body:WaitForChild("Humanoid")
    DragonObject.HumanoidRootPart = DragonObject.Body:WaitForChild("HumanoidRootPart")
    DragonObject.Mouth = DragonObject.Body:WaitForChild("Mouth")
    DragonObject.Animator = DragonObject.Humanoid:WaitForChild("Animator")
    
    if spawnPosition then
        DragonObject.Body:MoveTo(spawnPosition)
    end
    
    -- Dragon Settings
    DragonObject.SightRange = 100
    DragonObject.Level = 1
    DragonObject.OriginPosition = DragonObject.HumanoidRootPart.Position
    DragonObject.WeaponDropChance = 80 -- This means 80% chance to drop a sword
    DragonObject.BaseFireballDamage = 5
    DragonObject.BaseBiteDamage = 10

    -- Misc
    DragonObject.NextIdleBehavior = BEHAVIOR_CYCLE["Roam"]
    DragonObject.NextAttack = ATTACK_CYCLE["FireBreath"]
    DragonObject.PlayingAnimation = nil
    DragonObject.Target = nil


    return DragonObject
end

----------------------------------------------
--------------- Main Methods -----------------
----------------------------------------------

-- Start the Dragon's behavior
function Dragon:Start()
    self:_setupHumanoidConnections()
    self:_startBehaviorLoop()
end

-- Primary method to clean up the object
function Dragon:Clean()
    if not self.Body then
        self = nil
        return
    end

    self:_stopAnimations()

    -- Destroy the body
    self.Body:Destroy()

    -- Set self to nil
    self = nil
end

-- Very simple roam function for now
function Dragon:Roam()
    local randomX = math.random(-20, 20)
    local randomZ = math.random(-20, 20)

    local randomPosition : Vector3 = self.OriginPosition + Vector3.new(randomX, 0, randomZ)
    self:MoveDragonTo(randomPosition)
end


function Dragon:Attack()
    if not self.Target then
        return
    end

    local targetRoot : BasePart? = self.Target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local targetHumanoid : Humanoid? = self.Target:FindFirstChild("Humanoid")
    if not targetHumanoid then
        return
    end

    self:_rotateAttackCycle()
    
    if self.NextAttack == "WingBeat" then

        self:MoveDragonTo(targetRoot.Position)
        task.wait(1)

        local connection
        local animation = self:_playAnimation("WingBeat", true)
        if not animation then
            return
        end
        connection = animation.Stopped:Connect(function()
            connection:Disconnect()
            connection = nil

            self:Bite(targetRoot, targetHumanoid)
        end)

    elseif self.NextAttack == "FireBreath" then
        task.wait(1)

        local connection
        local animation = self:_playAnimation("FireBreath", true)
        if not animation then
            return
        end
        connection = animation.Stopped:Connect(function()
            connection:Disconnect()
            connection = nil

            self:_runFireBreath()
        end)

        task.delay(1, function()
            self:_stopAnimations()
        end)
    end
end


-- Move the dragon to a specified position
function Dragon:MoveDragonTo(position : Vector3?)
    if self.MoveToFinishedConnection then
        self.MoveToFinishedConnection:Disconnect()
        self.MoveToFinishedConnection = nil
    end

    self.Humanoid:MoveTo(position)
    self:_playAnimation("Walk")

    -- When the move is finished, then stop the walk animation
    self.MoveToFinishedConnection = self.Humanoid.MoveToFinished:Connect(function()
        if self.PlayingAnimation == "Walk" then
            self:_stopAnimations()
        end
    end)
end


---
--- The following methods will probably be overridden by specific class ---
---


-- Bite the player
function Dragon:Bite(targetRoot : BasePart?, targetHumanoid : Humanoid?)

    -- Will only bite if the dragon is facing the player
    if not Raycaster:IsFacing(self.Body, targetRoot.Parent) then
        return
    end

    -- Determines the range of the bite
    if (self.Mouth.Position - targetRoot.Position).Magnitude < 20 then
        targetHumanoid:TakeDamage(self.BaseBiteDamage)
    end
end


-- Returns the fire projectile part
function Dragon:GetFireProjectile()
    local fireball : BasePart? = Assets.Effects.Fireball:Clone()
    fireball.Parent = workspace.EffectStorage
    fireball.CFrame = self.Mouth.CFrame

    return fireball
end

-- Returns the fire explosion part
function Dragon:GetFireExplosion()
    local explosion : BasePart? = Assets.Effects.FireballPop:Clone()
    return explosion
end


-- The default doesn't deal any elemental effects, just does damage
function Dragon:DealElementalEffect(humanoid : Humanoid?, root : BasePart?, explosionPosition : Vector3?)
   return
end


-- Default burn method
function Dragon:Burn(humanoid : Humanoid?, root : BasePart?)
    local flames : ParticleEmitter? = Assets.Effects.Flames:Clone()
    flames.Parent = root

    -- Burn the player 4 times for 1 damage
    for i = 1, 4 do
        task.delay(1 * i, function()
            if humanoid and humanoid.Health > 0 then
                humanoid:TakeDamage(1)
            end

            -- Cleanup flames on last loop
            if i == 4 then
                flames:Destroy()
            end
        end)
    end
end

-- Recolor the specified particles in a container
-- the colorSequence gets passed onto each particle
function Dragon:RecolorParticles(container : any?, colorSequence : ColorSequence?)
    for index, particle in ipairs(container:GetDescendants()) do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        if particle:GetAttribute("NoColorChange") then
            continue
        end

        particle.Color = colorSequence
    end
end

----------------------------------------------
---------------- Sub Methods -----------------
----------------------------------------------

-- General behavior loop
function Dragon:_startBehaviorLoop()
    -- If dragon is alive
    if self.Humanoid.Health <= 0 then
        return
    end

    -- Search for target
    self.Target = self:_searchForNearbyPlayers()

    -- If no target, then just roam
    if self.Target then
        self:Attack()
    else
        self:_rotateIdleCycle()

        if self.NextIdleBehavior == "Roam" then
            self:Roam()
        else
            self:_playAnimation("Idle", true)

            task.delay(1.8, function()
                self:_stopAnimations()
            end)
        end
    end

    -- Restart behavior loop after two seconds
    task.delay(2, function()
        self:_startBehaviorLoop()
    end)
end



-- When the dragon dies, these connections clean up
function Dragon:_setupHumanoidConnections()

    -- Setup the humanoid health stats based on level
    self.Humanoid.MaxHealth = self.Level * 100
    self.Humanoid.Health = self.Humanoid.MaxHealth

    -- Watch for when the Dragon dies
    local deathConnection
    deathConnection = self.Humanoid.Died:Connect(function()

        -- Play the death animation
        local deathAnim = self:_playAnimation("Death", true)
        local connection
        connection = deathAnim.Stopped:Connect(function()
            connection:Disconnect()
            connection = nil

            -- Delete the body when death animation completed
            self:_deleteBody()
        end)

        -- Disconnect the death connection 
        deathConnection:Disconnect()
        deathConnection = nil

        -- Play death sound
        local deathSound : Sound? = Assets.Sounds.DragonRoar:Clone()
        deathSound.Parent = self.HumanoidRootPart
        deathSound.PlayOnRemove = true

        task.delay(0.1, function()
            deathSound:Destroy()
        end)

        -- Coin drop, amount dropped is based on level
        Knit.GetService("CoinService"):SpawnCoinsAt(
            self.HumanoidRootPart.Position + Vector3.new(0, 5, 0),
            (10 * self.Level) + math.random(1, 10)
        )

        -- Roll for a chance to get a weapon
        local randomNumber = math.random(1, 100)
        if randomNumber > self.WeaponDropChance then
            return
        end

        -- If the random number is less than the drop chance,,
        -- then drop a random weapon
        Knit.GetService("WeaponDropService"):DropRandomWeapon(
            self.HumanoidRootPart.Position + Vector3.new(0, 3, 0),
            self.Level
        )
    end)
end

-- Deletes the body of the dragon
function Dragon:_deleteBody()
    for index, part in ipairs(self.Body:GetDescendants()) do
        if not part:IsA("BasePart") then
            continue
        end

        part.Anchored = true
        part.CanCollide = false

        -- Allows the dragon body to fade away
        GeneralTween:SimpleTween(
            part,
            {Transparency = 1},
            1,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
    end

    -- After 1.5 seconds, clean up the object
    task.delay(1.5, function()
        self:Clean()
    end)
end


-- Creates a lerp between the specified points
function Dragon:_lerp(a, b, t)
	return a + (b - a) * t
end

-- Creates a bezier curve between the specified points
-- the fireball follows the curve
function Dragon:_quadraticBezier(t, p0, p1, p2)
	local l1 = self:_lerp(p0, p1, t)
	local l2 = self:_lerp(p1, p2, t)
	local quad = self:_lerp(l1, l2, t)
	return quad
end

-- When the dragon breathes the fireball
-- this function is called
function Dragon:_runFireBreath()

    -- If the root doesnt exist anymore, return
    local targetRoot : BasePart? = self.Target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    -- if the Dragon is dead, return
    if self.Humanoid.Health <= 0 then
        return
    end

    local targetPosition = targetRoot.Position

    -- The fireball part being launched
    local fireball : BasePart? = self:GetFireProjectile()

    -- Spawn the sound inside the fireball as it moves
    local fireSound : Sound? = ReplicatedStorage.Assets.Sounds.FireballSound:Clone()
    fireSound.Parent = fireball
    fireSound:Play()

    -- Create a CFrame between the two CFrames for generating Bezier curves
    local middleCFrame : CFrame? = self.Mouth.CFrame:Lerp(self.Mouth.CFrame, 0.5)
    middleCFrame = middleCFrame + Vector3.new(math.random(-10, 10), math.random(5, 10), math.random(-10, 10))

    local numberValue : NumberValue? = Instance.new("NumberValue")
    local debounce : boolean? = true

    local connection
    connection = numberValue.Changed:Connect(function()
        fireball.CFrame = CFrame.new(
            self:_quadraticBezier(
                numberValue.Value,
                self.Mouth.Position,
                middleCFrame.Position,
                targetPosition
            )
        )

        if debounce == true then
            debounce = false

            -- Emit particles as the ball is flying
            ParticleHandler:EmitInstant(fireball)

            task.delay(0.01, function()
                debounce = true
            end)
        end
    end)

    local tween = GeneralTween:SimpleTween(
        numberValue,
        {Value = 1},
        1,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    tween.Completed:Connect(function()
        connection:Disconnect()
        connection = nil

        local explosionBall = self:GetFireExplosion()

        ParticleHandler:PlayParticleGiven(explosionBall, fireball)
        self:_fireballPopDamage(targetPosition)

        game.Debris:AddItem(fireball, 1)
    end)
end


-- When the fireball explodes after reaching the target location
function Dragon:_fireballPopDamage(explosionPosition : Vector3?)
    -- Describes the hit radius of the explosion
    local radius : number? = 12

    -- Gets all models that are players
    -- deals damage to them
    for _, model in ipairs(workspace:GetDescendants()) do
        if not model:IsA("Model") then
            continue
        end

        if not game.Players:GetPlayerFromCharacter(model) then
            continue
        end

        local root : BasePart? = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Core")
        if not root then
            continue
        end

        if (root.Position - explosionPosition).Magnitude > radius then
            continue
        end

        local humanoid : Humanoid? = model:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(self.BaseFireballDamage)
            self:DealElementalEffect(humanoid, root, explosionPosition)
        end
    end
end



-- Rotate behavior from just standing to roaming around
function Dragon:_rotateIdleCycle()
    self.NextIdleBehavior = BEHAVIOR_CYCLE[self.NextIdleBehavior]
end


-- Rotate attacks
function Dragon:_rotateAttackCycle()
    self.NextAttack = ATTACK_CYCLE[self.NextAttack]
end

-- Stop and clean up all animations that are playing
function Dragon:_stopAnimations()
    if self.CurrentAnimation and self.CurrentAnimation.AnimationId == ANIMATION_LIST["Death"] then
        return
    end

    if self.CurrentAnimationTrack then
        self.CurrentAnimationTrack:Stop(0.5)

        -- self.CurrentAnimationTrack is set to nil after this, so 
        -- the oldTrack variable is created as a reference
        local oldTrack = self.CurrentAnimationTrack
        task.delay(0.5, function()
            oldTrack:Destroy()
        end)
        
        self.CurrentAnimationTrack = nil
    end

    -- If there is a current animation, then destroy it
    if self.CurrentAnimation then
        self.CurrentAnimation:Destroy()
        self.CurrentAnimation = nil
    end

    -- This value is used more as a debounce for animations
    self.PlayingAnimation = nil
end

function Dragon:_playAnimation(animationName : string?, override : boolean?)

    -- If this parameter is not left empty, then will stop old animation
    if override then
        self:_stopAnimations()
    end

    -- If existing animation is playing, then return
    if self.PlayingAnimation then
        return
    end

    self.PlayingAnimation = animationName

    -- Create new animation
    self.CurrentAnimation = Instance.new("Animation")
    self.CurrentAnimation.AnimationId = ANIMATION_LIST[animationName]

    -- Load it into a track
    pcall(function()
        self.CurrentAnimationTrack = self.Animator:LoadAnimation(self.CurrentAnimation)
        self.CurrentAnimationTrack:Play(0.5)
    end)
    
    -- Return animation in case you want to detect when it ended or if its on a certain frame
    return self.CurrentAnimationTrack
end

-- Search for the closest character (that is a player), returning a model
function Dragon:_searchForNearbyPlayers() : Model?
    local closestDistance = self.SightRange
    local target = nil

    -- Loops through all the players, finds the closest one
    for _, player in ipairs(game.Players:GetChildren()) do
        if not player:IsA("Player") then
            continue
        end

        if not player.Character then
            continue
        end

        local humanoid : Humanoid? = player.Character:FindFirstChild("Humanoid")
        if not humanoid then
            continue
        end

        local root : BasePart? = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then
            continue
        end

        local currentDistance : number? = (root.Position - self.HumanoidRootPart.Position).Magnitude
        if currentDistance > closestDistance then
            continue
        end

        closestDistance = currentDistance
        target = player.Character
    end

    return target
end



return Dragon