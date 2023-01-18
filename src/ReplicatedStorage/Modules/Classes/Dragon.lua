
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets

local Dragon = {}
Dragon.__index = Dragon


local ANIMATION_LIST = {
    Idle = "rbxassetid://12191600961",
    Walk = "rbxassetid://12191604172",
    WingBeat = "rbxassetid://12191605953",
    FireBreath = "rbxassetid://12191607555",
    Death = "rbxassetid://12191609066",
}

----------------------------------------------
---------------- Constructor -----------------
----------------------------------------------

function Dragon.new(bodyName : string?, spawnPosition : Vector3?)
    local DragonObject = {}
    setmetatable(DragonObject, Dragon)

    DragonObject.Body = Assets.Dragons:FindFirstChild(bodyName):Clone()
    DragonObject.Humanoid = DragonObject.Body:WaitForChild("Humanoid")
    DragonObject.HumanoidRootPart = DragonObject.Body:WaitForChild("HumanoidRootPart")
    DragonObject.Animator = DragonObject.Humanoid:WaitForChild("Animator")
    
    DragonObject.Body.Parent = workspace.DragonContainer

    if spawnPosition then
        DragonObject.Body:MoveTo(spawnPosition)
    end

    return DragonObject
end

----------------------------------------------
------------------ Methods -------------------
----------------------------------------------

function Dragon:StartBehavior()
    self:PlayAnimation("Idle")
end

function Dragon:StopAnimations()
    if self.CurrentAnimationTrack then
        self.CurrentAnimationTrack:Stop()
        self.CurrentAnimationTrack:Destroy()
        self.CurrentAnimationTrack = nil
    end

    if self.CurrentAnimation then
        self.CurrentAnimation:Destroy()
        self.CurrentAnimation = nil
    end
end

function Dragon:PlayAnimation(animationName : string?)
    self:StopAnimations()

    self.CurrentAnimation = Instance.new("Animation")
    self.CurrentAnimation.AnimationId = ANIMATION_LIST[animationName]

    self.CurrentAnimationTrack = self.Animator:LoadAnimation(self.CurrentAnimation)
    self.CurrentAnimationTrack:Play()

    return self.CurrentAnimationTrack
end

function Dragon:Clean()
    -- Destroy the body
    self.Body:Destroy()

    -- Set self to nil
    self = nil
end




return Dragon