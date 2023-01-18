local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
