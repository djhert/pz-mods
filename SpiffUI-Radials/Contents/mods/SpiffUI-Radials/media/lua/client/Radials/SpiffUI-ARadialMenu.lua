------------------------------------------
-- SpiffUI Radials
---- Radial Menu Functions
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

-- Base SpiffUI Radial Menu
local SpiffUIRadialMenu = ISUIElement:derive("SpiffUIRadialMenu")

-- Base Radial Command
local SpiffUIRadialCommand = ISBaseObject:derive("SpiffUIRadialCommand")


-- Radial Command for Next Page
local SpiffUIRadialCommandNext = SpiffUIRadialCommand:derive("SpiffUIRadialCommandNext")

-- Radial Command for Prev Page
local SpiffUIRadialCommandPrev = SpiffUIRadialCommand:derive("SpiffUIRadialCommandPrev")
spiff.prevCmd = SpiffUIRadialCommandPrev -- need to be able to call this other places

------------------------------------------
function SpiffUIRadialCommand:new(menu, text, texture, tooltip)
    local o = ISBaseObject.new(self)
    o.menu = menu
    o.rmenu = menu.rmenu
    o.player = menu.player
    o.playerNum = menu.playerNum

    o.tooltip = tooltip

    -- -- Disable the text if the menu has a forced center image
    -- if menu.centerImg and menu.cIndex then
    --     text = ""
    -- end
    o.text = text

    o.texture = texture

    o.shouldAsk = 0
    o.askText = nil

    o.amount = 0

    return o
end

function SpiffUIRadialCommand:fillMenu()
    if self.texture then
        self.rmenu:addSlice(self.text, self.texture, self.invoke, self)
    else -- add a blank
        self.rmenu:addSlice(nil, nil, nil)
    end
end

function SpiffUIRadialCommand:Action()
    print("Base SpiffUIRadialCommand Action -- Override me!")
end

function SpiffUIRadialCommand:invoke()
    if self.shouldAsk > 0 then
        self.menu.command = self
        local rad = spiff.subradial.ask:new(self.player, self.menu, self.texture, self.menu.askText)
        rad:start()
        return
    end
    self:Action()
end

-- Add Definition
spiff.radialcommand = SpiffUIRadialCommand

------------------------------------------

function SpiffUIRadialCommandNext:invoke()
    self.menu.page = self.menu.page + 1
    self.menu:show()
end

function SpiffUIRadialCommandNext:new(menu, text, texture)
    return spiff.radialcommand.new(self, menu, text, texture, nil)
end

------------------------------------------

function SpiffUIRadialCommandPrev:invoke()
    if self.menu.page > 1 then
        local p = self.menu.page
        self.menu.page = self.menu.page - 1
        if self.menu.pageReset then
            self.menu.maxPage = self.menu.page
            self.menu.btmText[p] = nil
            self.menu.centerImg[p] = nil
            self.menu.cImgChange[p] = nil
        end
        self.menu:show()
    else
        self.menu.prev:show()
    end
end

function SpiffUIRadialCommandPrev:new(menu, text, texture)
    return spiff.radialcommand.new(self, menu, text, texture, nil)
end

------------------------------------------
function SpiffUIRadialMenu:start()
    print("Base SpiffUIRadialMenu start -- Override me!")
end

function SpiffUIRadialMenu:display()
    if self.start then
        self:start()
        self.page = 1      
        self:show()
    end
end

function SpiffUIRadialMenu:prepareCmds()
    if not self.commands[self.page] then
        self.commands[self.page] = {}
    else
        table.wipe(self.commands[self.page])
    end
end

function SpiffUIRadialMenu:show()
    self.rmenu:clear()
    local count = 0
    local min = 3

    -- Add the next page
    if self.maxPage > 1 and self.page < self.maxPage then
        local nextp = SpiffUIRadialCommandNext:new(self, getText("UI_radial_SpiffUI_Next"), self.nextTex)
        nextp:fillMenu()
    end

    if self.commands[self.page] then
        for _,command in ipairs(self.commands[self.page]) do
            command:fillMenu()
            count = count + 1
        end
    end

    -- rule of 3
    if count < min then
        for i=count,min-1 do
            self.rmenu:addSlice(nil, nil, nil)
        end
    end

    -- Add the previous page
    if (self.maxPage > 1 and self.page > 1) or (self.page == 1 and self.prev) then
        local nextp = SpiffUIRadialCommandPrev:new(self, getText("UI_radial_SpiffUI_Previous"), self.prevTex)
        nextp:fillMenu()
    end

    if count > 0 then
        if self.btmText[self.page] then
            self.rmenu:setRadialText(self.btmText[self.page])
        end
        if self.centerImg[self.page] then
            self.rmenu:setRadialImage(self.centerImg[self.page])
        end

        if self.cImgChange[self.page] ~= nil then
            self.rmenu:setImgChange(self.cImgChange[self.page])
        end

        self.rmenu:center()
        self.rmenu:addToUIManager()
        self.rmenu:setVisible(true)
        self.rmenu.activeMenu = self

        SpiffUI.action.wasVisible = true
        if JoypadState.players[self.playerNum+1] then
            self.rmenu:setHideWhenButtonReleased(Joypad.DPadUp)
            setJoypadFocus(self.playerNum, self.rmenu)
            self.player:setJoypadIgnoreAimUntilCentered(true)
        end
    else
        -- If no commands, just close the radial
        self.rmenu:undisplay()
    end
end

function SpiffUIRadialMenu:undisplay()
end

function SpiffUIRadialMenu:AddCommand(command)
    if self.cCount == self.cMax then
        self.cCount = 0
        self.page = self.page + 1
        self.maxPage = self.page
    end

    if not self.commands[self.page] then
        self.commands[self.page] = {}
    end
    table.insert(self.commands[self.page], command)
    self.cCount = self.cCount + 1
end

function SpiffUIRadialMenu:new(player, prev, centerImg, btmText)
    local o = ISUIElement.new(self, 0,0,0,0)

    o.player = player
    o.playerNum = player:getPlayerNum()

    o.rmenu = getPlayerRadialMenu(o.playerNum)

    o.commands = {}
    o.cCount = 0
    o.cMax = 16
    o.page = 1
    o.maxPage = 1

    o.prev = prev or nil

    o.nextTex = getTexture("media/spifcons/nextpage.png")
    o.prevTex = getTexture("media/spifcons/prevpage.png")

    o.centerImg = {
        [1] = centerImg
    }
    o.btmText = {
        [1] = btmText
    }

    o.cmdText = nil
    o.cmdImg = nil
    
    --o.cIndex = ((o.centerImg[o.page] ~= nil) or false)
    o.cImgChange = {}

    o:initialise()
    o.background = false

    return o
end

spiff.radialmenu = SpiffUIRadialMenu