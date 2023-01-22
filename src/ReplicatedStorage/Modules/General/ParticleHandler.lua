local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GeneralTween = require(ReplicatedStorage.Source.Modules.General.GeneralTween)

----------- Initiated Variables -----------

local Assets = ReplicatedStorage.Assets

function module:BeamLink(part0 : BasePart?, part1 : BasePart?, container : any?)
    local beam = container:FindFirstChild("Beam", true)
    if not beam then
        warn("No beam in this container")
        return
    end

    beam = beam:Clone()

    local attach0 = Instance.new("Attachment")
    attach0.Parent = part0

    local attach1 = Instance.new("Attachment")
    attach1.Parent = part1

    beam.Attachment0 = attach0
    beam.Attachment1 = attach1
    beam.Parent = attach0

    return attach0, attach1
end


function module:PulseUntilDeath(core : BasePart?, humanoid : Humanoid?, particleName : string?, pulseDelay : number?)
    local attach = Instance.new("Attachment")
    attach.Parent = core

    local allParticles = {}
    local particleContainer : BasePart? = Assets.Effects:FindFirstChild(particleName)
    
    if not particleContainer then
        warn("Particle of that name cannot be found")
        return
    end

    for index, particle in ipairs(particleContainer:GetDescendants()) do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        local copy = particle:Clone()
        copy.Parent = attach
        copy:Emit(particle.Rate)

        table.insert(allParticles, copy)
    end

    task.spawn(function()
        while humanoid.Health > 0 do
            for _, particle in ipairs(allParticles) do
                particle:Emit(particle.Rate)
            end

            task.wait(pulseDelay)
        end

        attach:Destroy()
        allParticles = nil
    end)
end


function module:PlayParticleGiven(container : BasePart?, part : BasePart?, special : table?) : BasePart?
    if not container then
        warn("No particle given")
        return
    end

    container.CanCollide = false
    container.CanQuery = false
    container.CanTouch = false
    container.Massless = true
    container.Anchored = true

    container.Position = part.Position
    container.Parent = workspace.EffectStorage

    self:EmitParticles(container, special)

    return container
end


function module:PlayParticle(particleContainerName : string?, part : BasePart?, special : table?) : BasePart?
    local container : BasePart? = Assets.Effects:FindFirstChild(particleContainerName)
    if not container then
        warn("No particle of this name in Effects")
        return
    end

    container = container:Clone()

    container.CanCollide = false
    container.CanQuery = false
    container.CanTouch = false
    container.Massless = true
    container.Anchored = true

    container.Position = part.Position
    container.Parent = workspace.EffectStorage

    self:EmitParticles(container, special)

    return container
end


function module:EarthCircleEffect(targetPart : Part?)
	local rayParams : RaycastParams? = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {workspace.EffectStorage}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local angle = 0
	
	for i = 1, 30 do

		local targetSize = 3
		local part = Instance.new("Part")

		part.Anchored = true
		part.Size = Vector3.new(1, 1, 1)
		part.CFrame = targetPart.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(angle), 0) * CFrame.new(10, 5, 0)
		
		local raycastResult = workspace:Raycast(part.CFrame.Position, part.CFrame.UpVector * - 10, rayParams)
		if not raycastResult then
            continue
        end

        part.Position = raycastResult.Position + Vector3.new(0, -5, 0)
        part.Material = Enum.Material.Basalt
        part.Color = raycastResult.Instance.Color
        part.Orientation = Vector3.new(math.random(-180,180), math.random(-180,180), math.random(-180,180))
        part.Parent = game.Workspace.EffectStorage

        GeneralTween:SimpleTween(
            part,
            {Position = part.Position + Vector3.new(0, 5, 0), Size = Vector3.new(targetSize, targetSize, targetSize)},
            0.25,
            Enum.EasingStyle.Bounce,
            Enum.EasingDirection.InOut
        )

        task.delay(4,function()
            local fadeTween = GeneralTween:SimpleTween(
                part,
                {Transparency = 1, Position = part.Position + Vector3.new(0, -5, 0)},
                1
            )

            fadeTween.Completed:Connect(function()
                part:Destroy()
            end)
        end)
		

		angle += 25
	end
end


function module:EmitInstant(item : any?)
    for _, particle in ipairs(item:GetDescendants()) do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        particle:Emit(particle.Rate)
    end
end


function module:EmitParticles(item : any?, special : table?)
    local longestLifetime = 1

    for _, particle in ipairs(item:GetDescendants()) do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        particle:Emit(particle.Rate)

        if particle.Lifetime.Max > longestLifetime then
            longestLifetime = particle.Lifetime.Max
        end

        if not special then
            continue
        end

        for key, value in pairs(special) do
            if key ~= particle.Name then
                continue
            end

            local increment = value[1]
            local delayTime = value[2]

            for i = 1, increment do
                task.delay(delayTime * i, function()
                    particle:Emit(particle.Rate)
                end)
            end

            local totalTime = particle.Lifetime.Max * increment * delayTime
            if totalTime > longestLifetime then
                longestLifetime = totalTime
            end
        end
    end


    task.delay(longestLifetime + 3, function()
        item:Destroy()
    end)
end


return module
