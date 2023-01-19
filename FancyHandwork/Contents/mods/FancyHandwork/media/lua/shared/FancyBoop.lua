------
--- This action is just a small animation for when a player does an action in the world
--- Like if they just opened a door or something

------
FancyHands = FancyHands or {}
------

local curtainType = {
    ["CurtainLong"] = 1,
    ["CurtainShort"] = 1,
    ["CurtainShade"] = 2,
    ["CurtainSheet"] = 2,
    ["DoorSheet"] = 2
}
-- Delayed parameter is for when the action is done after
FancyHands.checkWindow = function(obj, playerObj, delayed)
    local curtains = false
    local type = ""
    local open = false
    if instanceof(obj, "IsoCurtain") then
        curtains = true
        type = obj:getSoundPrefix()
        open = obj:IsOpen()
    elseif instanceof(obj, "IsoWindow") and obj:HasCurtains() then
        obj = obj:HasCurtains()
        curtains = obj:canInteractWith(playerObj) and isKeyDown(Keyboard.KEY_LSHIFT)
        type = obj:getSoundPrefix()
        open = obj:IsOpen()
    elseif instanceof(obj, "IsoDoor") and obj:HasCurtains() then
        curtains = playerObj:getCurrentSquare() == obj:getSheetSquare() and isKeyDown(Keyboard.KEY_LSHIFT)
        type = "DoorSheet"
        open = obj:isCurtainOpen()
    end
    --if curtains and not curtains:getSquare():getProperties():Is(IsoFlagType.exterior) and not playerObj:getCurrentSquare():Is(IsoFlagType.exterior) then
    if curtains then
        local cur = curtainType[type]
        if not cur or cur > 1 then
            if open then
                cur = 101
            else
                cur = 1
            end
        end
        return {item = obj, extra = cur}
    end
    return nil
end

FancyHands.doorDecide = function(obj, playerObj, delayed, fromClick)
    if (fromClick and isKeyDown(Keyboard.KEY_LSHIFT)) or obj:isDestroyed() then return end
    if obj:getProperties():Is("GarageDoor") then
        return { item = obj, extra = ((delayed and obj:IsOpen() and -1) or (not delayed and not obj:IsOpen() and -1)) or 101 }
    else
        return { item = obj, extra = 0 }
    end
end

FancyHands.checkDoor = function(obj, playerObj, delayed, fromClick) 
    local out
    if obj and playerObj then
        if instanceof(obj, "IsoCurtain") or instanceof(obj, "IsoWindow") then
            out = FancyHands.checkWindow(obj, playerObj)
        elseif instanceof(obj, "IsoDoor") then
            out = FancyHands.checkWindow(obj, playerObj) or FancyHands.doorDecide(obj, playerObj, delayed, fromClick)
        elseif instanceof(obj, "IsoThumpable") and obj:isDoor() then
            out = FancyHands.checkWindow(obj, playerObj) or FancyHands.doorDecide(obj, playerObj, delayed, fromClick)
        end
    end 
    return out
end

FancyHands.checkForSwitch = function(obj, playerObj, dir, doIt)
    local square1 = playerObj:getCurrentSquare();
    local square2 = square1:getAdjacentSquare(dir)
    if square2 == nil then return nil end

    local out

    -- Lightswitch does not seem to be something you can do via the "E" key by default
    if obj and square1:getRoom() then
        if (SandboxVars.ElecShutModifier > -1 and getGameTime():getNightsSurvived() < SandboxVars.ElecShutModifier) or square1:haveElectricity() then
            -- Light switch on the player's square
            for i=0,square1:getObjects():size()-1 do
                if instanceof(square1:getObjects():get(i), "IsoLightSwitch") then
                    --print("Found Lightswitch on Square")
                    if doIt then
                        print("Flipping Switch")
                    end
                    out = { item = obj, extra = 0 }
                    break
                end
            end
            -- Light switch on adjacent solidtrans square
            if not out and square2:getRoom() and not square2:isSomethingTo(square1) and square2:Is(IsoFlagType.solidtrans) then
                for i=0,square2:getObjects():size()-1 do
                    if instanceof(square2:getObjects():get(i), "IsoLightSwitch") then
                        --print("Found Lightswitch on Adjacent Square")
                        if doIt then
                            print("Flipping Switch")
                        end
                        out = { item = obj, extra = 0 }
                        break
                    end
                end
            end
        end
    end
    return out
end

FancyHands.doAction = function(player, item)
    if not item or not player then 
        return
    end
    --local queue = ISTimedActionQueue.queues[player]
    if not ISTimedActionQueue.isPlayerDoingAction(player) then
        ISTimedActionQueue.add(FHBoopAction:new(player, item))
    end
end

FancyHands.testForAction = function(dir, playerObj)
    local playerNum = playerObj:getPlayerNum()
    local square1 = playerObj:getCurrentSquare()
    local square2 = square1:getAdjacentSquare(dir)
    if square2 == nil then return nil end

    local found = nil

    if not found then
        found = FancyHands.checkDoor(playerObj:getContextDoorOrWindowOrWindowFrame(dir), playerObj)
    end

    if not found then
        local vehicle = playerObj:getUseableVehicle()
        if vehicle then
            local part = vehicle:getUseablePart(playerObj)
            if part then
                if part:getDoor() and part:getDoor():isLocked() and part:getInventoryItem() then
                    if part:getId() == "EngineDoor" then
                        -- Skip the hood
                    elseif part:getId() == "TrunkDoor" or part:getId() == "DoorRear" then
                        -- Do the trunk/compartments
                        found = { item = vehicle, extra = 1 }
                    else
                        -- Do the doors
                        found = { item = vehicle, extra = 0 }
                    end
                end
            end
        end
    end

    return found
end

local function getBestAction(player)
    if UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then return end

    if getCell():getDrag(player:getPlayerNum()) then return end

    if player:getIgnoreMovement() or player:isAsleep() then return end

    if player:getVehicle() then return end

    local square = player:getCurrentSquare()
    if not square then return end

    local dir = player:getDir()

    local found = nil
    if dir == IsoDirections.NE then
        found = FancyHands.testForAction(IsoDirections.N, player)
        if not found then 
            found = FancyHands.testForAction(IsoDirections.E, player)
        end
    elseif dir == IsoDirections.SE then
        found = FancyHands.testForAction(IsoDirections.S, player)
        if not found then
            found = FancyHands.testForAction(IsoDirections.E, player)
        end
    elseif dir == IsoDirections.SW then
        found = FancyHands.testForAction(IsoDirections.S, player)
        if not found then
            found = FancyHands.testForAction(IsoDirections.W, player)
        end
    elseif dir == IsoDirections.NW then
        found = FancyHands.testForAction(IsoDirections.N, player)
        if not found then
            found = FancyHands.testForAction(IsoDirections.W, player);
        end
    else
        found = FancyHands.testForAction(dir, player);
    end

    -- We already did our action, so stop here
    if not found then
        local dir1 = nil
        local dir2 = nil
        if dir == IsoDirections.NW then
            dir1 = IsoDirections.S
            dir2 = IsoDirections.E
        elseif dir == IsoDirections.NE then
            dir1 = IsoDirections.S
            dir2 = IsoDirections.W
        elseif dir == IsoDirections.SE then
            dir1 = IsoDirections.N
            dir2 = IsoDirections.W
        elseif dir == IsoDirections.SW then
            dir1 = IsoDirections.N
            dir2 = IsoDirections.E
        else
            dir1 = dir:RotLeft(4) -- 180 degrees
        end
        if dir1 ~= nil then
            found = FancyHands.checkDoor(player:getContextDoorOrWindowOrWindowFrame(dir1), player)
        end
        if not found and dir2 ~= nil then
            found = FancyHands.checkDoor(player:getContextDoorOrWindowOrWindowFrame(dir2), player)
        end
    end

    FancyHands.doAction(player,found)
end

Events.OnGameStart.Add(function()
    -- Add this here so its not actually added to the available keybindings, just want the function
    FancyHands.addKeyBind({
        value = 'Interact',
        action = getBestAction,
        key = Keyboard.KEY_E,
    })
end)