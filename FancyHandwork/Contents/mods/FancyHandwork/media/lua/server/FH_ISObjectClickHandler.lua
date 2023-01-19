------
FancyHands = FancyHands or {}
------

local _ISObjectClickHandler_doClickCurtain = ISObjectClickHandler.doClickCurtain
function ISObjectClickHandler.doClickCurtain(object, playerNum, playerObj)
    if _ISObjectClickHandler_doClickCurtain(object, playerNum, playerObj) then
        FancyHands.doAction(playerObj, FancyHands.checkDoor(object, playerObj, true))
        return true
    end
    return false
end

local _ISObjectClickHandler_doClickDoor = ISObjectClickHandler.doClickDoor
function ISObjectClickHandler.doClickDoor(object, playerNum, playerObj)
    if _ISObjectClickHandler_doClickDoor(object, playerNum, playerObj) then
        FancyHands.doAction(playerObj, FancyHands.checkDoor(object, playerObj, true, true))
        return true
    end
    return false
end

local _ISObjectClickHandler_doClickLightSwitch = ISObjectClickHandler.doClickLightSwitch
function ISObjectClickHandler.doClickLightSwitch(object, playerNum, playerObj)
    if _ISObjectClickHandler_doClickLightSwitch(object, playerNum, playerObj) then
        FancyHands.doAction(playerObj, {item = object, extra = 0 })
        return true
    end
    return false
end

local _ISObjectClickHandler_doClickThumpable = ISObjectClickHandler.doClickThumpable
function ISObjectClickHandler.doClickThumpable(object, playerNum, playerObj)
    if _ISObjectClickHandler_doClickThumpable(object, playerNum, playerObj) then
        FancyHands.doAction(playerObj, FancyHands.checkDoor(object, playerObj, true, true))
        return true
    end
    return false
end

local _ISObjectClickHandler_doClickWindow = ISObjectClickHandler.doClickWindow
function ISObjectClickHandler.doClickWindow(object, playerNum, playerObj)
    if _ISObjectClickHandler_doClickWindow(object, playerNum, playerObj) then
        FancyHands.doAction(playerObj, FancyHands.checkDoor(object, playerObj, true))
        return true
    end
    return false
end