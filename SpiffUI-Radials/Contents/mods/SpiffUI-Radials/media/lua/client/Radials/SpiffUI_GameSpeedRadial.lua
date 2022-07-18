------------------------------------------
-- SpiffUI Game Speed Radial
----  does anyone else even read these? if so, hello. :) 
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIGSRadial = spiff.radialmenu:derive("SpiffUIGSRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[10] = SpiffUIGSRadial

------------------------------------------

local SpiffUIGSRadialCommand = spiff.radialcommand:derive("SpiffUIGSRadialCommand")

function SpiffUIGSRadialCommand:Action()
    if self.mode == 0 then
        UIManager.getSpeedControls():ButtonClicked("Pause")
    elseif self.mode == 1 then
        UIManager.getSpeedControls():ButtonClicked("Play")
    elseif self.mode == 2 then
        UIManager.getSpeedControls():ButtonClicked("Fast Forward x 1")
    elseif self.mode == 3 then
        UIManager.getSpeedControls():ButtonClicked("Fast Forward x 2")
    elseif self.mode == 4 then
        UIManager.getSpeedControls():ButtonClicked("Wait")
    end
end

function SpiffUIGSRadialCommand:new(menu, name, texture, mode)
    local o = spiff.radialcommand.new(self, menu, name, texture, nil)
    o.mode = mode
    return o
end

function SpiffUIGSRadial:start()
    local multiplier = getGameTime():getTrueMultiplier()

    self.cImgChange[self.page] = true

    -- Play/pause
    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 or multiplier > 1 then
        self:AddCommand(SpiffUIGSRadialCommand:new(self, getText("IGUI_BackButton_Play"), getTexture("media/ui/Time_Play_Off.png"), 1))
    else
        self:AddCommand(spiff.radialcommand:new(self, nil, nil, nil))
        self.centerImg[self.page] = getTexture("media/ui/Time_Play_On.png")
        self.btmText[self.page] = getText("IGUI_BackButton_Play")
    end

    if UIManager.getSpeedControls():getCurrentGameSpeed() ~= 0 then
        self:AddCommand(SpiffUIGSRadialCommand:new(self, getText("UI_optionscreen_binding_Pause"), getTexture("media/ui/Time_Pause_Off.png"), 0))
    else
        self:AddCommand(spiff.radialcommand:new(self, nil, nil, nil))
        self.centerImg[self.page] = getTexture("media/ui/Time_Pause_Off.png")
        self.btmText[self.page] = getText("UI_optionscreen_binding_Pause")
    end

    -- FF
    if multiplier == 5 then
        self:AddCommand(spiff.radialcommand:new(self, nil, nil, nil))
        self.centerImg[self.page] = getTexture("media/ui/Time_FFwd1_Off.png")
        self.btmText[self.page] = getText("IGUI_BackButton_FF1")
    else
        self:AddCommand(SpiffUIGSRadialCommand:new(self, getText("IGUI_BackButton_FF1"), getTexture("media/ui/Time_FFwd1_Off.png"), 2))
    end

    -- FF x2
    if multiplier == 20 then
        self:AddCommand(spiff.radialcommand:new(self, nil, nil, nil))
        self.centerImg[self.page] = getTexture("media/ui/Time_FFwd2_Off.png")
        self.btmText[self.page] = getText("IGUI_BackButton_FF2")
    else
        self:AddCommand(SpiffUIGSRadialCommand:new(self, getText("IGUI_BackButton_FF2"), getTexture("media/ui/Time_FFwd2_Off.png"), 3))
    end

    -- FF xWait
    if multiplier == 40 then
        self:AddCommand(spiff.radialcommand:new(self, nil, nil, nil))
        self.centerImg[self.page] = getTexture("media/ui/Time_Wait_Off.png")
        self.btmText[self.page] = getText("IGUI_BackButton_FF3")
    else
        self:AddCommand(SpiffUIGSRadialCommand:new(self, getText("IGUI_BackButton_FF3"), getTexture("media/ui/Time_Wait_Off.png"), 4))
    end
end

function SpiffUIGSRadial:new(player, menu)
    local o = spiff.radialmenu.new(self, player, menu)
    return o
end

local function GSDown(player)
    -- Does nothing in multiplayer
    if not UIManager.getSpeedControls() or isClient() then return end

    SpiffUI.onKeyDown(player)
    -- if we're not ready, then we're not doing an action.
    ---- do it now
    if not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUIGSRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end


local function actionInit()
    local bind = {        
        name = 'SpiffUIGSWheel',
        key = Keyboard.KEY_GRAVE, -- ~
        queue = true,
        allowPause = true,
        Down = GSDown
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()