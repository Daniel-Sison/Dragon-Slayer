local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)


for _, module in ipairs(ServerStorage.Source:GetDescendants()) do
    if not module:IsA("ModuleScript") then
        continue
    end

    if not string.match(module.Name, "Service$") then
        continue
    end

    require(module)
end




Knit.Start():andThen(function()
    print("KnitStartServer")
end):catch(warn)