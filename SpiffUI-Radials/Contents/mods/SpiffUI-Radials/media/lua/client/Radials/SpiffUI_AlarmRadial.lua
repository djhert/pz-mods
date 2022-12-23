------------------------------------------
-- SpiffUI Alarm Actions
----  Radial Menu for setting the alarm
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIAlarmRadial = spiff.radialmenu:derive("SpiffUIAlarmRadial")
if not spiff.subradial then spiff.subradial = {} end
spiff.subradial.alarm = SpiffUIAlarmRadial

local SpiffUIAlarmRadialCommand = spiff.radialcommand:derive("SpiffUIAlarmRadialCommand")

function SpiffUIAlarmRadialCommand:Action()
    if self.mode == 1 then
        self.alarm:setAlarmSet(false)
        self.alarm:setHour(self.menu.hour)
        self.alarm:setMinute(self.menu.minute)
        self.alarm:syncAlarmClock()
    elseif self.mode == 2 then
        self.alarm:setAlarmSet(true)
        self.alarm:setHour(self.menu.hour)
        self.alarm:setMinute(self.menu.minute)
		self.alarm:syncAlarmClock()
    elseif self.mode == 3 then
        self.menu.oldPrev = self.menu.prev
        self.menu.prev = nil
        self.menu:hourRadial()
    elseif self.mode == 4 then
        self.alarm:syncStopRinging()
    end
end

function SpiffUIAlarmRadialCommand:new(menu, mode, alarm)
    local tex
    local label = ""
    if mode == 1 then
        tex = menu.aicons["silence"]
        label = getText("UI_alarm_SpiffUI_Silence")
    elseif mode == 2 then
        tex = menu.aicons["enable"]
        label = getText("UI_alarm_SpiffUI_Enable")
    elseif mode == 3 then
        tex = alarm:getTexture()
        label = getText("UI_alarm_SpiffUI_Reset")
    elseif mode == 4 then
        tex = menu.aicons["stop"]
        label = getText("ContextMenu_StopAlarm")
    end
    local o = spiff.radialcommand.new(self, menu, label, tex, nil)
    o.mode = mode
    o.alarm = alarm
    return o
end

local SpiffUIAlarmRadialCommandHour = spiff.radialcommand:derive("SpiffUIAlarmRadialCommandHour")

function SpiffUIAlarmRadialCommandHour:Action()
    self.menu.hour = self.hour
    self.menu:minuteRadial()
end

function SpiffUIAlarmRadialCommandHour:new(menu, hour)
    local o = spiff.radialcommand.new(self, menu, getText("UI_alarm_SpiffUI_SetHourF", string.format("%02d", hour), getText("UI_alarm_SpiffUI_MM")), menu.aicons[hour], nil)
    o.hour = hour
    return o
end

local SpiffUIAlarmRadialCommandMinute = spiff.radialcommand:derive("SpiffUIAlarmRadialCommandMinute")

function SpiffUIAlarmRadialCommandMinute:Action()
    self.menu.minute = self.minute
    self.menu.alarm:setHour(self.menu.hour)
    self.menu.alarm:setMinute(self.menu.minute)
    self.menu.alarm:syncAlarmClock()
    self.menu.prev = self.menu.oldPrev
    self.menu.oldPrev = nil
    self.menu:start()
end

function SpiffUIAlarmRadialCommandMinute:new(menu, minute, hText)
    local o = spiff.radialcommand.new(self, menu, getText("UI_alarm_SpiffUI_SetMinuteF", hText, string.format("%02d", minute)), menu.aicons[minute], nil)
    o.minute = minute
    return o
end

------------------------------------------

function SpiffUIAlarmRadial:show()
    spiff.radialmenu.show(self)
    self.rmenu:setClock(self.alarm)
end

function SpiffUIAlarmRadial:start()
    self:prepareCmds()

    local hText = ""
    if self.hour == -1 then
        hText = getText("UI_alarm_SpiffUI_HH")
    else
        hText = string.format("%02d", self.hour)
    end

    local mText = ""
    if self.minute == -1 then
        mText = getText("UI_alarm_SpiffUI_MM")
    else
        mText = string.format("%02d", self.minute)
    end

    self.btmText[self.page] = getText("UI_alarm_SpiffUI_CurrentF", hText, mText)

    if self.alarm:isRinging() then
        self:AddCommand(SpiffUIAlarmRadialCommand:new(self,4,self.alarm))
    end
    self:AddCommand(SpiffUIAlarmRadialCommand:new(self,3,self.alarm))
    self:AddCommand(SpiffUIAlarmRadialCommand:new(self,1,self.alarm))
    self:AddCommand(SpiffUIAlarmRadialCommand:new(self,2,self.alarm))

    self:show()
end

function SpiffUIAlarmRadial:hourRadial()
    self:prepareCmds()

    self.btmText[self.page] = getText("UI_alarm_SpiffUI_SetHourF", getText("UI_alarm_SpiffUI_HH"), getText("UI_alarm_SpiffUI_MM"))
    self.cImgChange[self.page] = false

    for i = 0, 23 do
        table.insert(self.commands[self.page], SpiffUIAlarmRadialCommandHour:new(self, i))
    end

    self:show()
end

function SpiffUIAlarmRadial:minuteRadial()
    self:prepareCmds()

    local hText = ""
    if self.hour == -1 then
        hText = getText("UI_alarm_SpiffUI_HH")
    else
        hText = string.format("%02d", self.hour)
    end

    self.btmText[self.page] = getText("UI_alarm_SpiffUI_SetMinuteF", hText, getText("UI_alarm_SpiffUI_MM"))
    self.cImgChange[self.page] = false

    for i = 0, 5 do
        table.insert(self.commands[self.page], SpiffUIAlarmRadialCommandMinute:new(self, i*10, hText))
    end

    self:show()
end

function SpiffUIAlarmRadial:new(player, alarm, prev)
    local o = spiff.radialmenu.new(self, player, prev)
    o.alarm = alarm
    o.hour = o.alarm:getHour()
    o.minute = o.alarm:getMinute()

    -- Alarm icons
    o.aicons = {
        [30] = getTexture("media/spifcons/alarm/30.png"),
        [40] = getTexture("media/spifcons/alarm/40.png"),
        [50] = getTexture("media/spifcons/alarm/50.png"),
        ["silence"] = getTexture("media/ui/ClockAssets/ClockAlarmLargeSet.png"),
        ["enable"] = getTexture("media/ui/ClockAssets/ClockAlarmLargeSound.png"),
        ["stop"] = getTexture("media/ui/emotes/no.png"),
    }
    -- Do the rest
    for i=0,23 do
        o.aicons[i] =  getTexture("media/spifcons/alarm/" .. string.format("%02d", i) .. ".png")
    end

    o.icons = {
        ["mid"] = getTexture("media/spifcons/clock/mid.png"),
        ["silence"] = getTexture("media/ui/ClockAssets/ClockAlarmLargeSet.png"),
        ["enable"] = getTexture("media/ui/ClockAssets/ClockAlarmLargeSound.png"),
    }
    for i=0,9 do
        o.icons[i] =  getTexture(string.format("media/spifcons/clock/%d.png", i))
    end


    return o
end

-- later when i get the inventory to dismiss/reappear for controllers. i've delayed release enough for now
local _ISAlarmClockDialog_new = ISAlarmClockDialog.new
function ISAlarmClockDialog:new(x, y, width, height, player, alarm)
    if JoypadState.players[player+1] then
        return _ISAlarmClockDialog_new(self, x, y, width, height, player, alarm)
    else
        return SpiffUIAlarmRadial:new(getSpecificPlayer(player), alarm)
    end
end

function SpiffUIAlarmRadial:initialise()
    if self.init then
        -- This is called again by "onSetAlarm"
        -- We'll just override this to show the radial instead
        self:display()
    else
        ISUIElement.initialise(self)
        self.init = true
    end
end