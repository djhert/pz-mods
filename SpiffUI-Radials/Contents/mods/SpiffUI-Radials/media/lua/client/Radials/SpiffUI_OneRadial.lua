------------------------------------------
-- SpiffUI Main Radial
----  One Radial to Rule Them All
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIOneRadial = spiff.radialmenu:derive("SpiffUIOneRadial")

------------------------------------------

local SpiffUIOneRadialCommand = spiff.radialcommand:derive("SpiffUIOneRadialCommand")

function SpiffUIOneRadialCommand:Action()
    local radial = spiff.radials[self.mode]
    if radial then
        local menu = radial:new(self.player, self.menu)
        menu:display()
    end

end

function SpiffUIOneRadialCommand:new(menu, name, texture, mode)
    local o = spiff.radialcommand.new(self, menu, name, texture, nil)
    o.mode = mode
    return o
end

-- local tickWatch = ISUIElement:derive("tickWatch")

-- function tickWatch:render()
--     local hour = getGameTime():getHour()
--     minutes = getGameTime():getMinutes()

--     hour = hour + (minutes/60)

--     local endX = self.cenX + ( (self.hrLen) * (math.sin(2 * math.pi * hour / 12 ) ) )
--     local endY = self.cenY + ( (-self.hrLen) * (math.cos(2 * math.pi * hour / 12 ) ) )

--     self:drawLine2(self.cenX, self.cenY, endX, endY, 1, 1, 1, 1)

--     endX = self.cenX + ( (self.minLen) * (math.sin(2 * math.pi * minutes / 60 ) ) )
--     endY = self.cenY + ( (-self.minLen) * (math.cos(2 * math.pi * minutes / 60 ) ) )

--     self:drawLine2(self.cenX, self.cenY, endX, endY, 1, 1, 1, 1)
-- end

-- function tickWatch:center()
--     local x = getPlayerScreenLeft(self.playerNum)
-- 	local y = getPlayerScreenTop(self.playerNum)
-- 	local w = getPlayerScreenWidth(self.playerNum)
-- 	local h = getPlayerScreenHeight(self.playerNum)

--     x = x + w / 2
-- 	y = y + h / 2

--     self:setX(x - self.rad / 2)
--     self:setY(y - self.rad / 2)

--     self.cenX = x
--     self.cenY = y
-- end

-- function tickWatch:new(playerNum, radius, clock, menu)
--     local o = ISUIElement.new(self, 0, 0, radius, radius/3)
--     o:initialise()

--     o.clock = clock
--     o.rad = radius

--     o.playerNum = playerNum

--     o.imgW = o.rad
--     o.imgH= o.rad

--     o.hrLen = o.rad*0.5
--     o.minLen = o.rad*0.8

--     self.menu = menu

--     o:center()

--     return o
-- end

local function getBestClock(player)
    local watch = nil

    local items = player:getInventory():getAllEval(function(item)
        return instanceof(item, "AlarmClock") or instanceof(item, "AlarmClockClothing")
    end)

    if items and items:size() > 0 then
        for i = 0, items:size()-1 do 
            local item = items:get(i)
            if not watch then
                watch = item
            else
                -- Check to always get best clock in inventory
                if (not watch:isDigital() or instanceof(item, "AlarmClock")) and (item:isDigital() and instanceof(item, "AlarmClockClothing")) then
                    watch = item
                end
            end
            if player:isEquipped(item) then
                watch = item
                break
            end
        end
    end
    return watch
end

function SpiffUIOneRadial:show()
    spiff.radialmenu.show(self)
    self.rmenu:setClock(getBestClock(self.player))
end

function SpiffUIOneRadial:start()

    --self.clock = 
    
    -- if self.clock then
    --     self.cFace = nil
    --     if spiff.config.experimental and (not self.clock:isDigital() or instanceof(self.clock, "AlarmClock")) then
    --         -- hand clock or non-digital watch
    --         self.cFace = tickWatch:new(self.playerNum, self.rmenu.innerRadius, self.clock, self)
    --     else
    --         self.cFace = timeImg:new(self.playerNum, self.rmenu.innerRadius, self.clock, self)
    --     end
        
    --     self:addChild(self.cFace)
    --     -- show date/temp
    --     if self.clock:isDigital() and instanceof(self.clock, "AlarmClockClothing") then
    --         self.dFace = dateImg:new(self.playerNum, self.player, self.rmenu.innerRadius, self.clock, self)
    --         self:addChild(self.dFace)
    --     end
    -- end

    -- Crafting
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Crafting"), getTexture("media/spifcons/crafting.png"), 0))
    -- Drink
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Drink"), InventoryItemFactory.CreateItem("Base.WaterBottleFull"):getTexture(), 1))
    -- Eat
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Eat"), InventoryItemFactory.CreateItem("Base.Apple"):getTexture(), 2))
    -- Equipment
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Equipment"), getTexture("media/spifcons/inventory.png"), 3))
    -- First Aid Craft
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_FirstAidCraft"), InventoryItemFactory.CreateItem("Base.Bandage"):getTexture(), 4))
    -- Pills
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Pills"), InventoryItemFactory.CreateItem("Base.PillsAntiDep"):getTexture(), 5))
    -- Repair
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Repair"), InventoryItemFactory.CreateItem("Base.Hammer"):getTexture(), 6))

    if spiff.config.showSmokeCraftRadial then 
        local icon = nil
        if getActivatedMods():contains('jiggasGreenfireMod') then
            icon = InventoryItemFactory.CreateItem("Greenfire.SmokingPipe"):getTexture()
        elseif getActivatedMods():contains('Smoker') then
            icon = InventoryItemFactory.CreateItem("SM.SMSmokingBlendPipe"):getTexture()
        elseif getActivatedMods():contains('MoreCigsMod') then
            icon = InventoryItemFactory.CreateItem("Cigs.CigsOpenPackReg"):getTexture()
        else
            icon = InventoryItemFactory.CreateItem("Base.Cigarettes"):getTexture()
        end
        -- Smoke Craft
        self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_SmokeCraft"), icon, 7))
    end

    if spiff.config.showSmokeRadial then
        -- Smoke
        self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Smoke"), InventoryItemFactory.CreateItem("Base.Cigarettes"):getTexture(), 8))
    end

    if spiff.radials[9] then
        self:AddCommand(SpiffUIOneRadialCommand:new(self, "Clothing Action Radial Menu",InventoryItemFactory.CreateItem("Base.Hat_BaseballCapGreen"):getTexture(), 9))
    end

    if UIManager.getSpeedControls() and not isClient() then
        self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_GameSpeed"), getTexture("media/ui/Time_Wait_Off.png"), 10))
    end
end

function SpiffUIOneRadial:new(player)
    local o = spiff.radialmenu.new(self, player)
    
    o.icons = {
        ["mid"] = getTexture("media/spifcons/clock/mid.png"),
        ["date"] = getTexture("media/spifcons/clock/slash.png"),
        ["dot"] = getTexture("media/spifcons/clock/dot.png"),
        ["F"] = getTexture("media/spifcons/clock/F.png"),
        ["C"] = getTexture("media/spifcons/clock/C.png"),
        ["silence"] = getTexture("media/ui/ClockAssets/ClockAlarmLargeSet.png"),
        ["enable"] = getTexture("media/ui/ClockAssets/ClockAlarmLargeSound.png"),
    }
    for i=0,9 do
        o.icons[i] =  getTexture(string.format("media/spifcons/clock/%d.png", i))
    end

    return o
end

local function OneDown(player)
    SpiffUI.onKeyDown(player)
    -- if we're not ready, then we're doing an action.
    ---- do it now
    if not SpiffUI.action.ready then
        if UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
            if not isClient() then
                spiff.radials[10]:new(player):display()
            else 
                return
            end
        else
            SpiffUIOneRadial:new(player):display()
        end
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

------------------------------------------
--- For the DPad
local function showRadialMenu(player)
    if not player or player:isDead() then
        return
    end

    if UIManager.getSpeedControls() and (UIManager.getSpeedControls():getCurrentGameSpeed() == 0) then
        if not isClient() then
            spiff.radials[10]:new(player):display()
        end
        return
    end

    SpiffUIOneRadial:new(player):display()
end

---- Show the Radial Menu on the Up DPad when there's not a car around
local _ISDPadWheels_onDisplayUp = ISDPadWheels.onDisplayUp
function ISDPadWheels.onDisplayUp(joypadData)
    local player = getSpecificPlayer(joypadData.player)
    if not player:getVehicle() and not ISVehicleMenu.getVehicleToInteractWith(player) then
        showRadialMenu(player)
    else
        _ISDPadWheels_onDisplayUp(joypadData)
    end
end

local function actionInit()
    local bind = {        
        name = 'SpiffUIOneWheel',
        key = Keyboard.KEY_CAPITAL, -- ;
        queue = true,
        allowPause = true,
        Down = OneDown
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()