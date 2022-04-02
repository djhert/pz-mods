------------------------------------------
-- Clothing Actions Radial Menu
------------------------------------------

CARadialMenu = ISBaseObject:derive("CARadialMenu")
activeMenu = nil

------------------------------------------
local CACommand = ISBaseObject:derive("CACommand")

function CACommand:new(menu, item, text, itype, action)
    local o = ISBaseObject.new(self)
    o.menu = menu
    o.player = menu.player

    o.item = item
    o.text = text
    o.itype = itype
    o.action = action

    return o
end

function CACommand:fillMenu(menu)
    menu:addSlice(self.text, self.item:getTexture(), self.invoke, self)
end

function CACommand:invoke()
    ISTimedActionQueue.add(ISClothingExtraAction:new(self.player, self.item, self.itype))
end

------------------------------------------

function CARadialMenu:center()
    local menu = getPlayerRadialMenu(self.playerNum)

    local x = getPlayerScreenLeft(self.playerNum)
    local y = getPlayerScreenTop(self.playerNum)
    local w = getPlayerScreenWidth(self.playerNum)
    local h = getPlayerScreenHeight(self.playerNum)

    x = x + w / 2
    y = y + h / 2
    
    menu:setX(x - menu:getWidth() / 2)
    menu:setY(y - menu:getHeight() / 2)
end

local function checkClothes(item)
    -- If there's extra options
    if item and item:getClothingItemExtraOption() then
        -- Check if we have the filter enabled or clothes, and, item is not watch or filter
        if (instanceof(item, "Clothing") or CARMconfig.filter) and (not instanceof(item, "AlarmClockClothing") or CARMconfig.filter) then
            return true
        end
    end
    return false
end

function CARadialMenu:fillMenu()
    local menu = getPlayerRadialMenu(self.playerNum)
    menu:clear()

    local commands = {}
    local clothes = self.player:getWornItems()
    for i=0, clothes:size() - 1 do
        local item = clothes:get(i):getItem()
        if checkClothes(item) then
            for i=0,item:getClothingItemExtraOption():size()-1 do
                local action = item:getClothingItemExtraOption():get(i)
                local itemType = moduleDotType(item:getModule(), item:getClothingItemExtra():get(i))
                table.insert(commands, CACommand:new(self, item, getText("ContextMenu_" .. action), itemType, action))
            end
        end
    end

    for _,command in ipairs(commands) do
        local count = #menu.slices
        command:fillMenu(menu)
        if count == #menu.slices then
            menu:addSlice(nil, nil, nil)
        end
    end
end

function CARadialMenu:display()
    local menu = getPlayerRadialMenu(self.playerNum)
    self:center()
    menu:addToUIManager()
    if JoypadState.players[self.playerNum+1] then
        menu:setHideWhenButtonReleased(Joypad.DPadUp)
        setJoypadFocus(self.playerNum, menu)
        self.player:setJoypadIgnoreAimUntilCentered(true)
    end
end

function CARadialMenu:new(player)
    local o = ISBaseObject.new(self)
    o.player = player
    o.playerNum = player:getPlayerNum()
    return o
end

local ticks = 0
local wasVisible = false

function CARadialMenu.checkKey(key)
    if key ~= getCore():getKey("CARM") then
        return false
    end

    if UIManager.getSpeedControls() and (UIManager.getSpeedControls():getCurrentGameSpeed() == 0) then
        return false
    end

    local player = getSpecificPlayer(0)
    if not player or player:isDead() then
            return false
    end

    if player:isSeatedInVehicle() then
        return false
    end
    
    local queue = ISTimedActionQueue.queues[player]
    if queue and #queue.queue > 0 then
            return false
    end
    if getCell():getDrag(0) then
            return false
    end
    return true
end

------------------------------------------
--- For the DPad
function CARadialMenu.showRadialMenu(player)
    if UIManager.getSpeedControls() and (UIManager.getSpeedControls():getCurrentGameSpeed() == 0) then
        return
    end

    if not player or player:isDead() then
            return
    end
    local queue = ISTimedActionQueue.queues[player]
    if queue and #queue.queue > 0 then
            return false
    end

    local menu = CARadialMenu:new(player)
    menu:fillMenu()
    menu:display()
    activeMenu = menu
end

---- Show the Radial Menu on the Up DPad when there's not a car around
local _ISDPadWheels_onDisplayUp = ISDPadWheels.onDisplayUp
function ISDPadWheels.onDisplayUp(joypadData)
    local player = getSpecificPlayer(joypadData.player)
    if not player:getVehicle() and not ISVehicleMenu.getVehicleToInteractWith(player) then
        CARadialMenu.showRadialMenu(player)
    else
        _ISDPadWheels_onDisplayUp(joypadData)
    end
end
------------------------------------------

function CARadialMenu.onKeyPress(key)
    if not CARadialMenu.checkKey(key) then
        return
    end
    local radialMenu = getPlayerRadialMenu(0)
    if radialMenu:isReallyVisible() and getCore():getOptionRadialMenuKeyToggle() then
        wasVisible = true
        radialMenu:removeFromUIManager()
        setJoypadFocus(activeMenu.playerNum, nil)
        activeMenu = nil
        return
    end
    ticks = getTimestampMs()
    wasVisible = false
end

function CARadialMenu.onKeyHold(key)
    if not CARadialMenu.checkKey(key) then
        return
    end
    if wasVisible then
        return
    end

    local radialMenu = getPlayerRadialMenu(0)
    local delay = 500
    if CARMconfig.delay then
        delay = 0
    end
    if (getTimestampMs() - ticks >= delay) and not radialMenu:isReallyVisible() then
        local menu = CARadialMenu:new(getSpecificPlayer(0))
        menu:fillMenu()
        menu:display()
        activeMenu = menu
    end

end

Events.OnGameStart.Add(function()
    Events.OnKeyStartPressed.Add(CARadialMenu.onKeyPress)
    Events.OnKeyKeepPressed.Add(CARadialMenu.onKeyHold)
end)