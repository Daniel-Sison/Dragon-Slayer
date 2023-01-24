local module = {}


-- Raycast from one point to another
-- Will return the result
function module:Cast(originPoint : Vector3?, destinationPoint : Vector3?, ignoreList : table?)
	local raycastResult

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true

    raycastResult = workspace:Raycast(originPoint, destinationPoint - originPoint, raycastParams)

    if raycastResult then
        --	print("Object/terrain hit:", raycastResult.Instance:GetFullName())
        --	print("Hit position:", raycastResult.Position)
        --	print("Name of Parent:", raycastResult.Instance.Parent.Name)
        --	print("Material hit:", raycastResult.Material.Name)
        return raycastResult
    else
        --	print("Nothing was hit!")
        return nil
    end

	
	return nil
end

-- Checks to see if model1 is facing model 2
function module:IsFacing(model1 : Model?, model2 : Model?) : boolean?
	
	local head1 = model1:FindFirstChild("Head")
	local head2 = model2:FindFirstChild("Head")

    if not head1 then
        warn("No head 1 on model 1")
        return false
    end

    if not head2 then
        warn("No head 2 on model 2")
        return false
    end

    local unitVector = (head2.Position - head1.Position).Unit
    local direction = head1.CFrame.LookVector

    local dotProduct = unitVector:Dot(direction)
    if dotProduct > 0.1 then
        return true
    end

	return false
end



return module
