--- These actions all do a small hand movement now.
FHBoopAction = ISBaseTimedAction:derive("FHBoopAction")

local rearObjects = {
	["LightSwitch"] = true,
	["LightSource"] = true,
	["Stove"] = true,
	["ClothingDryer"] = true,
	["ClothingWasher"] = true,
	["CombinationWasherDryer"] = true,
	["Door"] = true,
	["Radio"] = true,
	["Television"] = true,
}

local function skipInstances(obj)
	return not obj or rearObjects[obj:getObjectName()] or (obj:getObjectName() == "Thumpable" and obj:isDoor())
end

--character:getModData().FancyHands and not character:getModData().FancyHands.recentMove  and (character:getModData().FancyHands.recentMove and not skipInstances(data.item) or true)
local function shouldDoTurn(obj, player)
	if not obj or not player or player:isAiming() or not SandboxVars.FancyHandwork or SandboxVars.FancyHandwork.DisableTurn == 1 then return false end
	if SandboxVars.FancyHandwork.DisableTurn == 3 then return true end
	if instanceof(obj, "InventoryItem") and obj:isInPlayerInventory() then return false end -- safeguard
	if SandboxVars.FancyHandwork.TurnBehavior <= 2 then
		return (player:getModData().FancyHands and not player:getModData().FancyHands.recentMove)
	elseif SandboxVars.FancyHandwork.TurnBehavior == 3 then
		return not (skipInstances(obj) or not (player:getModData().FancyHands and not player:getModData().FancyHands.recentMove))
	end
	
	return false
end

function FHBoopAction:isValid()
	return true;
end

function FHBoopAction:waitToStart()
	if self.character:isSeatedInVehicle() then
		-- If we are in a car, we should just stop here actually
		self:forceComplete()
		return false
	elseif self.turn then
		self.character:faceThisObject(self.item)
		return self.character:shouldBeTurning()
	end
	
	return false
end

---Brought to you by ChuckGPT
---@param char IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
local function getDotSide(char,mouseX,mouseY)

    ---@type Vector2
    local lookVector = char:getLookVector(Vector2.new())
    local lookVX, lookVY = lookVector:getX(), lookVector:getY()
    
    local charX, charY, charZ, charNum = char:getX(), char:getY(), char:getZ(), char:getPlayerNum()
    
    ---@type Vector2
    local charVector = Vector2.new(charX,charY)
    local charVX, charVY = charVector:getX(), charVector:getY()

    local objX = screenToIsoX(charNum, mouseX, mouseY, charZ)
    local objY = screenToIsoY(charNum, mouseX, mouseY, charZ)

    ---@type Vector2
    local objVector = Vector2.new(objX-charVX,objY-charVY)
    objVector:normalize()

    local dot = Vector2.dot(objVector:getX(), objVector:getY(), lookVX, lookVY)

    local front = dot > 0.0

    -- if dot < 0.0 then
    --     results = false
    -- else--if (dot < 0.0 and dot < -0.5) then
    --     results = results.. "BEHIND"
    -- end

--    results = results.."|"

    local lcVX, lcVY = charVX + lookVX, charVY + lookVY
    local dotSide = (objX - charVX) * (lcVY - charVY) - (objY - charVY) * (lcVX - charVX)
	local left = dotSide > 0.0
    -- if dotSide > 0.0 then
    --     results = results.. "LEFT"
    -- else
    --     results = results.. "RIGHT"
    -- end

    return front, left
end

function FHBoopAction:isInRearRange()
	-- This game is weird man
	---- I tried to get the angle between the player and the object but its fucking inconsistent because large numbers, AND fucking light switches
	---- isFacingObject returns a value of 1,-1 and 0 represents it being perpendicular (left OR right)
	---- This is also SUPER picky, in that moving a step in the same direction can go from 0.4 to -0.1 and below, or in the opposite direction who knows man.
	---- So already off, not the best function.  I will revisit this, I am way to tired to do the math right now and don't give a shit.
	---- This function itself has lost me like 3 days. fuck this for now.
	return not (self.character:isFacingObject(self.item, -0.65))
end



function FHBoopAction:doRearDoor(left)
	if self.turn or not self:isInRearRange() then return false end

	if left == 1 then -- left
		self:setActionAnim("FH_Boop_Rear_L")
	elseif left == 2 then -- right
		self:setActionAnim("FH_Boop_Rear_R")
	else
		if ZombRand(3) == 1 then
			self:setActionAnim("FH_Boop_Rear_L")
		else
			self:setActionAnim("FH_Boop_Rear_R")
		end
	end
	return true
end

function FHBoopAction:doRearFlick(left)
	if self.turn or not self:isInRearRange() then return false end

	if left == 1 then -- left
		self:setActionAnim("FH_Boop_Rear_Flick_L")
	elseif left == 2 then -- right
		self:setActionAnim("FH_Boop_Rear_Flick_R")
	else
		if ZombRand(3) == 1 then
			self:setActionAnim("FH_Boop_Rear_Flick_L")
		else
			self:setActionAnim("FH_Boop_Rear_Flick_R")
		end
	end
	return true
end

function FHBoopAction:doThing(left)
	left = left or 0

	if instanceof(self.item, "IsoDoor") then
		if self:doRearDoor(left) then return end
	elseif skipInstances(self.item) then
		if self:doRearFlick(left) then return end
	end

	if left == 1 then -- left
		self:setActionAnim("FH_BoopL")
	elseif left == 2 then -- right
		self:setActionAnim("FH_Boop")
	else
		if ZombRand(3) == 1 then
			self:setActionAnim("FH_BoopL")
		else
			self:setActionAnim("FH_Boop")
		end
	end
end

function FHBoopAction:start()
	if self.extra > 100 then
		self:setAnimVariable("BoopPosition", "High")
		self.extra = self.extra - 100
	elseif self.extra < 0 then
		self:setAnimVariable("BoopPosition", "Low")
		self.extra = self.extra * -1
	end
	if self.extra == 1 then
		self:setActionAnim("FH_Boop_Dual")
	else
		local primary = self.character:getPrimaryHandItem()
		local secondary = self.character:getSecondaryHandItem()
		if primary then
			self:doThing((((primary and secondary) and not self.character:isAiming() and primary ~= secondary) and 0) or 1)	
		else
			self:doThing((not secondary and 0) or 2)
		end
	end
	--self.character
	-- set this here again to undo any moodles and such
	self.action:setTime(15)
end

function FHBoopAction:stop()
    ISBaseTimedAction.stop(self);
end

function FHBoopAction:perform()

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function FHBoopAction:new(character, data)
	if not data then return nil end
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.item = data.item
	o.extra = data.extra
	o.stopOnWalk = false
	o.stopOnRun = false
	o.maxTime = 15
	o.FHIgnore = true
	o.useProgressBar = false
	o.turn = shouldDoTurn(data.item, character)
	return o
end