SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

-- RadialMenuOverlay
local SUIRadialMenuOverlay = ISUIElement:derive("SUIRadialMenuOverlay")

local timeImg = ISUIElement:derive("timeImg")

function timeImg:center()
    local x = getPlayerScreenLeft(self.playerNum)
	local y = getPlayerScreenTop(self.playerNum)
	local w = getPlayerScreenWidth(self.playerNum)
	local h = getPlayerScreenHeight(self.playerNum)

    x = x + w / 2
	y = y + h / 2

    self:setX(x - self.imgW / 2)
    self:setY(y - self.rad / 2)

    self.cenX = x
    self.cenY = y
end

function timeImg:render(one)
    self:center()
    local time = getGameTime():getHour()
    local h1 = 0
    local h2 = 0
    if time > 9 then
        h1 = math.floor(time/10)
    end
    h2 = time - (h1*10)

    self:drawTextureScaledAspect(one.icons[h1], self.X[1], 0, self.secW, self.imgH, 1,1,1,1)
    self:drawTextureScaledAspect(one.icons[h2], self.X[2], 0, self.secW, self.imgH, 1,1,1,1)

    self:drawTextureScaledAspect(one.icons["mid"], self.X[3], 0, self.midW, self.imgH, 1,1,1,1)

    time = getGameTime():getMinutes()
    h1 = 0
    h2 = 0
    if time > 9 then
        h1 = math.floor(time/10)
    end
    h2 = time - (h1*10)

    self:drawTextureScaledAspect(one.icons[h1], self.X[4], 0, self.secW, self.imgH, 1,1,1,1)
    self:drawTextureScaledAspect(one.icons[h2], self.X[5], 0, self.secW, self.imgH, 1,1,1,1)
end

function timeImg:new(playerNum, menu)
    local o = ISUIElement.new(self, 0, 0, menu.innerRadius, menu.innerRadius/3)
    o:initialise()
    o:instantiate()

    o.playerNum = playerNum
    
    o.menu = menu
    o.rad = menu.innerRadius  

    o.imgW = o.rad
    o.imgH= o.rad/3
    o.secW = o.rad/4
    o.midW = o.rad/8

    o.X = {
        [1] = 0,
        [2] = o.secW,
        [3] = o.secW + o.secW,
        [4] = o.secW + o.secW + o.midW,
        [5] = o.secW + o.secW + o.midW + o.secW
    }

    o.imgW = o.X[5] + o.secW
    return o
end

local dateImg = ISUIElement:derive("dateImg")

local function round(num)
    return math.floor(num * 10) / 10;
end

function dateImg:center()
    local x = getPlayerScreenLeft(self.playerNum)
	local y = getPlayerScreenTop(self.playerNum)
	local w = getPlayerScreenWidth(self.playerNum)
	local h = getPlayerScreenHeight(self.playerNum)

    x = x + w / 2
	y = y + h / 2

    self:setX(x - self.imgW / 2)
    self:setY((y - self.rad / 2) + (self.rad * 0.4))
end

function dateImg:render(one)
    self:center()
    local time = getGameTime():getMonth()+1
    local h1 = 0
    local h2 = 0
    if time > 9 then
        h1 = math.floor(time/10)
    end
    h2 = time - (h1*10)

    self:drawTextureScaledAspect(one.icons[h1], self.X[1], 0, self.secW, self.imgH, 1,1,1,1)
    self:drawTextureScaledAspect(one.icons[h2], self.X[2], 0, self.secW, self.imgH, 1,1,1,1)

    self:drawTextureScaledAspect(one.icons["date"], self.X[3], 0, self.secW, self.imgH, 1,1,1,1)

    time = getGameTime():getDay()+1
    h1 = 0
    h2 = 0
    if time > 9 then
        h1 = math.floor(time/10)
    end
    h2 = time - (h1*10)

    self:drawTextureScaledAspect(one.icons[h1], self.X[4], 0, self.secW, self.imgH, 1,1,1,1)
    self:drawTextureScaledAspect(one.icons[h2], self.X[5], 0, self.secW, self.imgH, 1,1,1,1)

    -------------------------------------
    local temp = round(self.climate:getAirTemperatureForCharacter(self.player))    

    time = math.floor(temp)
    h1 = 0
    h2 = 0
    if time > 9 then
        h1 = math.floor(time/10)
    end
    h2 = time - (h1*10)

    self:drawTextureScaledAspect(one.icons[h1], self.X[6], 0, self.secW, self.imgH, 1,1,1,1)
    self:drawTextureScaledAspect(one.icons[h2], self.X[7], 0, self.secW, self.imgH, 1,1,1,1)

    self:drawTextureScaledAspect(one.icons["dot"], self.X[8], 5, self.midW, self.imgH, 1,1,1,1)

    h1 = math.floor((temp - time) * 10)

    self:drawTextureScaledAspect(one.icons[h1], self.X[9], 0, self.secW, self.imgH, 1,1,1,1)

    self:drawTextureScaledAspect(one.icons["C"], self.X[10], 0, self.secW, self.imgH, 1,1,1,1)
end

function dateImg:new(playerNum, menu)
    local o = ISUIElement.new(self, 0, 0, menu.innerRadius, menu.innerRadius/3)
    o:initialise()
    o:instantiate()

    o.menu = menu

    o.climate = getClimateManager()
    o.rad = menu.innerRadius

    o.playerNum = playerNum
    o.player = getSpecificPlayer(o.playerNum)

    o.imgW = o.rad
    o.imgH= o.rad/6
    o.secW = (o.rad/8)
    o.midW = (o.rad/10)

    o.X ={
        [1] = 0,
        [2] = o.secW,
        [3] = 2*o.secW,
        [4] = 3*o.secW,
        [5] = 4*o.secW,

        [6] = 6*o.secW,
        [7] = 7*o.secW,
        [8] = 8*o.secW-2,
        [9] = 8*o.secW+(o.midW/2)+2,
        [10] = 9*o.secW+(o.midW/2)+2,
    }

    o.imgW = 10*o.secW+(o.midW/2)    

    return o
end

function SUIRadialMenuOverlay:center()
    local x = getPlayerScreenLeft(self.playerNum)
	local y = getPlayerScreenTop(self.playerNum)
	local w = getPlayerScreenWidth(self.playerNum)
	local h = getPlayerScreenHeight(self.playerNum)

    x = x + w / 2
	y = y + h / 2

    self.imgH = self.rmenu.innerRadius*0.6
    self.imgW = self.imgH

    self.imgX = (x - self.imgW / 2)
    self.imgY = (y - self.imgH / 2) - getTextManager():getFontHeight(UIFont.Medium)

    if self.text then       
		self.textPanel:setWidth(self.rmenu.innerRadius*1.5)
		self.textPanel:paginate()

        self.textPanel:setX(x - self.textPanel:getWidth()/2)
        self.tpY = (y - self.textPanel:getHeight() / 2)
        self.btpY = self.imgY + self.imgH + getTextManager():getFontHeight(UIFont.Medium)
    else
		self.textPanel.lines = nil
    end

    self.cenX = x
    self.cenY = y
end

function SUIRadialMenuOverlay:renderClock()
    local clock = self.rmenu:getClock()
    local one = self.rmenu.activeMenu
    self.cFace:render(one)
    if clock:isDigital() and instanceof(clock, "AlarmClockClothing") and not one.alarm then
        self.dFace:render(one)
    end

    if clock:isAlarmSet() then
        local sz = self.rmenu.innerRadius/3
        local y = self.cFace:getY() - (sz*1.15)
        local x = self.cenX - sz/2
        if clock:isRinging() then
            self:drawTextureScaledAspect(one.icons["enable"], x, y, sz, sz, 1,1,1,1)
        else
            self:drawTextureScaledAspect(one.icons["silence"], x, y, sz, sz, 1,1,1,1)
        end
    end
end

function SUIRadialMenuOverlay:render()
    
    if not self.rmenu:isReallyVisible() then
        self:setVisible(false)
        return
    end

    local hasClock = false
    if self.rmenu:getClock() then
        hasClock = true
    end

    local index = -1
    if JoypadState.players[self.playerNum+1] then
        index = self.rmenu.javaObject:getSliceIndexFromJoypad(self.rmenu.joyfocus.id)
    else
        index = self.rmenu.javaObject:getSliceIndexFromMouse(self.rmenu:getMouseX(), self.rmenu:getMouseY())
    end

    self.cmdText = nil
    self.cmdImg = nil

    if index > -1 then
        local obj = self.rmenu:getSliceText(index+1)
        if obj then
            self.cmdText = obj
        end
        obj = self.rmenu:getSliceTexture(index+1)
        if obj then
            self.cmdImg = obj
        end
    end

    if self.btmText then
        self.text = "<CENTRE> "..self.btmText
    end
    
    if index > -1 then
        if self.cmdText then
            self.text = "<CENTRE> "..self.cmdText 
        elseif self.btmText then
            self.text = "<CENTRE> "..self.btmText
        else
            self.text = " "
        end
    end

    if self.text == "" then
        self.text = nil
        self.textPanel.text = ""
    else
        self.textPanel.text = self.text
    end
    
    self:center()

    if hasClock then
        self:renderClock()
    end

    if index == -1 then
        if self.centerImg and not hasClock then
            self:drawTextureScaledAspect(self.centerImg, self.imgX, self.imgY, self.imgW, self.imgH, 1, 1, 1, 1)
        end
        if self.btmText then
            self.textPanel:setY(self.btpY)
        end
    else
        if self.cImgChange then
            if self.cmdImg then
                if not hasClock then
                    self:drawTextureScaledAspect(self.cmdImg, self.imgX, self.imgY, self.imgW, self.imgH, 1, 1, 1, 1)
                end
            else
                if self.centerImg and not hasClock then
                    self:drawTextureScaledAspect(self.centerImg, self.imgX, self.imgY, self.imgW, self.imgH, 1, 1, 1, 1)
                end
            end
        else
            if self.centerImg and not hasClock then 
                self:drawTextureScaledAspect(self.centerImg, self.imgX, self.imgY, self.imgW, self.imgH, 1, 1, 1, 1)
            end
        end

        if self.cmdText then
            if self.centerImg or self.cmdImg or hasClock then
                -- Draw cmdText at bottom
                self.textPanel:setY(self.btpY)
            else
                if self.btmText then
                    -- Draw btmText
                    self.textPanel:setY(self.btpY)
                end
                -- Draw cmdText at middle like default
                self.textPanel:setY(self.tpY)
            end
        else
            if self.btmText then
                self.textPanel:setY(self.btpY)
            end
        end

        if JoypadState.players[self.playerNum+1] then
            self.rmenu:showTooltip(self.rmenu:getSliceTooltipJoyPad())
        end
    end

    self.textPanel:prerender()
    self.textPanel:render()
    self.text = ""
end

function SUIRadialMenuOverlay:undisplay()
    self:removeFromUIManager()
	self:setVisible(false)

    self.btmText = nil
    self.centerImg = nil
    self.cImgChange = true
end

function SUIRadialMenuOverlay:display()
    self:addToUIManager()
	self:setVisible(true)
	self:bringToTop()

    if self.rmenu.radText then
        self.btmText = self.rmenu.radText
        --print("Bottom Text!")
    end

    if self.rmenu.radImg then
        self.centerImg = self.rmenu.radImg
        --print("centerImg!")
    end

    if self.rmenu.radImgChange ~= nil then
        self.cImgChange = self.rmenu.radImgChange
        --print("cImgChange!")
    end
end

function SUIRadialMenuOverlay:new(menu)
    local o = ISUIElement.new(self, 0,0,0,0)

    o.rmenu = menu
    o.playerNum = menu.playerNum

    o.btmText = nil
    o.centerImg = nil
    o.cImgChange = true

    o.textPanel = ISRichTextPanel:new(0, 0, 0, 0)
    o.textPanel.marginLeft = 0
    o.textPanel.marginRight = 0
    o.textPanel:initialise()
    o.textPanel:instantiate()
    o.textPanel:noBackground()
    o.textPanel.backgroundColor = {r=0, g=0, b=0, a=0.3}
    o.textPanel.borderColor = {r=1, g=1, b=1, a=0.1}
    o.textPanel.defaultFont = UIFont.Medium

    o.cFace = timeImg:new(o.playerNum, o.rmenu)
    o.dFace = dateImg:new(o.playerNum, o.rmenu)

    return o

end

return SUIRadialMenuOverlay