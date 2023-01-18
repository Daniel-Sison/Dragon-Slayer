local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create the service:
local TestService = Knit.CreateService {
    Name = "TestService",
    Client = {
        TestDataChanged = Knit.CreateSignal(), -- Create the signal
    },
}


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function TestService.Client:GetSomethingFromClient(player : Player?)
    return self.Server:DoTheServerThing(player)
end

function TestService:DoTheServerThing(player)

    task.delay(3, function()
        -- update the Test Data
        self.Client.TestDataChanged:Fire(player, "New Data!")
    end)

    return "Data wohoo"
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function TestService:KnitInit()

end

function TestService:KnitStart()
    warn("Hey i am in here u stopid")
end


return TestService