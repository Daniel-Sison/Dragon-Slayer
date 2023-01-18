local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

for _, module in ipairs(ReplicatedStorage.Source:GetDescendants()) do
    if not module:IsA("ModuleScript") then
        continue
    end

    if not string.match(module.Name, "Controller$") then
        continue
    end

    require(module)
end


Knit.Start():andThen(function()
    print("KnitStartClient")
end):catch(warn)