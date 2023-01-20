
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
        connection = animation.Stopped:Connect(function()
            connection:Disconnect()
            connection = nil

            if not Raycaster:IsFacing(self.Body, targetRoot.Parent) then
                return
            end

            if (self.Mouth.Position - targetRoot.Position).Magnitude < 20 then
                targetHumanoid:TakeDamage(20)
            end
        end)

    elseif self.NextAttack == "FireBreath" then
        task.wait(1)

        local connection
        local animation = self:_playAnimation("FireBreath", true)
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
    local deathConnection
    deathConnection = self.Humanoid.Died:Connect(function()
        self:_playAnimation("Death", true)

        deathConnection:Disconnect()
        deathConnection = nil

        -- Coin drop
        Knit.GetService("CoinService"):SpawnCoinsAt(
            self.HumanoidRootPart.Position + Vector3.new(0, 5, 0),
            10 * self.Level
        )

        -- Roll for a chance to get a weapon
        -- local randomNumber = math.random(1, 100)
        -- if randomNumber > self.WeaponDropChance then
        --     return
        -- end

        -- If the random number is less than the drop chance,,
        -- then drop a random weapon
        Knit.GetService("WeaponDropService"):DropRandomWeapon(
            self.HumanoidRootPart.Position + Vector3.new(0, 5, 0),
            self.Level
        )
    end)
end


function Dragon:_lerp(a, b, t)
	return a + (b - a) * t
end

function Dragon:_quadraticBezier(t, p0, p1, p2)
	local l1 = self:_lerp(p0, p1, t)
	local l2 = self:_lerp(p1, p2, t)
	local quad = self:_lerp(l1, l2, t)
	return quad
end


function Dragon:_runFireBreath()
    local targetRoot : BasePart? = self.Target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local targetPosition = targetRoot.Position

    -- The fireball part being launched
    local fireball : BasePart? = Assets.Effects.Fireball:Clone()
    fireball.Parent = workspace.EffectStorage
    fireball.CFrame = self.Mouth.CFrame

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

        ParticleHandler:PlayParticle("FireballPop", fireball)
        self:_fireballPopDamage(targetPosition)

        game.Debris:AddItem(fireball, 1)
    end)
end



function Dragon:_fireballPopDamage(explosionPosition : Vector3?)
    local radius : number? = 12

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
            humanoid:TakeDamage(10)
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
    self.CurrentAnimationTrack = self.Animator:LoadAnimation(self.CurrentAnimation)
    self.CurrentAnimationTrack:Play(0.5)

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