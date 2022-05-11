------------------------------------------
-- SpiffUI First Aid Craft Actions
----  Radial Menu for First Aid Crafting
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
        local menu = radial:new(self.player)
        menu:display()
    end

end

function SpiffUIOneRadialCommand:new(menu, name, texture, mode)
    local o = spiff.radialcommand.new(self, menu, name, texture, nil)
    o.mode = mode
    return o
end

function SpiffUIOneRadial:build()
    -- Crafting
    self:AddCommand(SpiffUIOneRadialCommand:new(self, "Crafting",getTexture("media/SpiffUI/crafting.png"), 0))
    -- Drink
    self:AddCommand(SpiffUIOneRadialCommand:new(self, "Drink", InventoryItemFactory.CreateItem("Base.WaterBottleFull"):getTexture(), 1))
    -- Eat
    self:AddCommand(SpiffUIOneRadialCommand:new(self, "Eat", InventoryItemFactory.CreateItem("Base.ChickenFried"):getTexture(), 2))
    -- Equipment
    self:AddCommand(SpiffUIOneRadialCommand:new(self, "Equipment", getTexture("media/SpiffUI/inventory.png"), 3))
    -- First Aid Craft
    self:AddCommand(SpiffUIOneRadialCommand:new(self, "First Aid Craft", InventoryItemFactory.CreateItem("Base.Bandage"):getTexture(), 4))
    -- Pills
    self:AddCommand(SpiffUIOneRadialCommand:new(self, "Pills", InventoryItemFactory.CreateItem("Base.PillsAntiDep"):getTexture(), 5))
    -- Repair
    self:AddCommand(SpiffUIOneRadialCommand:new(self, "Repair",InventoryItemFactory.CreateItem("Base.Hammer"):getTexture(), 6))
    -- Smoke Craft
    if getActivatedMods():contains('jiggasGreenfireMod') then
        self:AddCommand(SpiffUIOneRadialCommand:new(self, "Smoke Craft", InventoryItemFactory.CreateItem("Greenfire.SmokingPipe"):getTexture(), 7))
    elseif getActivatedMods():contains('Smoker') then
        self:AddCommand(SpiffUIOneRadialCommand:new(self, "Smoke Craft", InventoryItemFactory.CreateItem("SM.SMSmokingBlend"):getTexture(), 7))
    elseif getActivatedMods():contains('MoreCigsMod') then
        self:AddCommand(SpiffUIOneRadialCommand:new(self, "Smoke Craft", InventoryItemFactory.CreateItem("Cigs.CigsOpenPackReg"):getTexture(), 7))
    else
        self:AddCommand(SpiffUIOneRadialCommand:new(self, "Smoke Craft", InventoryItemFactory.CreateItem("Base.Cigarettes"):getTexture(), 7))
    end
    -- Smoke
    self:AddCommand(SpiffUIOneRadialCommand:new(self, "Smoke",InventoryItemFactory.CreateItem("Base.Cigarettes"):getTexture(), 8))
    if spiff.radials[9] then
        self:AddCommand(SpiffUIOneRadialCommand:new(self, "Clothing Action Radial Menu",InventoryItemFactory.CreateItem("Base.Hat_BaseballCapGreen"):getTexture(), 9))
    end
end

function SpiffUIOneRadial:new(player)
    return spiff.radialmenu.new(self, player)
end

local function OneDown(player)
    SpiffUI.onKeyDown(player)
    -- if we're not ready, then we're doing an action.
    ---- do it now
    if not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUIOneRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

------------------------------------------
--- For the DPad
local function showRadialMenu(player)
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

    local menu = SpiffUIOneRadial:new(player)
    menu:display()
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
        Down = OneDown
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()