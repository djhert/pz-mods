------------------------------------------
-- SpiffUI Radials
---- Radial Menu Functions
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

-- Base SpiffUI Radial Menu
local SpiffUIRadialMenu = ISBaseObject:derive("SpiffUIRadialMenu")

-- Base Radial Command
local SpiffUIRadialCommand = ISBaseObject:derive("SpiffUIRadialCommand")

-- Radial Command for asking amount
local SpiffUIRadialCommandAsk = SpiffUIRadialCommand:derive("SpiffUIRadialCommandAsk")

-- Radial Command for Next Page
local SpiffUIRadialCommandNext = SpiffUIRadialCommand:derive("SpiffUIRadialCommandNext")

-- Radial Command for Prev Page
local SpiffUIRadialCommandPrev = SpiffUIRadialCommand:derive("SpiffUIRadialCommandPrev")

------------------------------------------
function SpiffUIRadialCommand:new(menu, text, texture, tooltip)
    local o = ISBaseObject.new(self)
    o.menu = menu
    o.rmenu = menu.rmenu
    o.player = menu.player
    o.playerNum = menu.playerNum

    o.tooltip = tooltip

    o.text = text
    o.texture = texture

    o.shouldAsk = 0
    o.amount = 0

    return o
end

function SpiffUIRadialCommand:fillMenu()
    if spiff.config.showTooltips and self.tooltip then
        if self.forceText then
            self.rmenu:addSlice(self.text, self.texture, self.invoke, self)
        else
            self.rmenu:addSlice("", self.texture, self.invoke, self)
        end
    else 
        self.rmenu:addSlice(self.text, self.texture, self.invoke, self)
    end
end

function SpiffUIRadialCommand:Action()
    print("Base SpiffUIRadialCommand Action -- Override me!")
end

function SpiffUIRadialCommand:invoke()
    if self.shouldAsk > 0 then
        self.menu.command = self
        self.menu:askAmount()
        return
    end
    self:Action()
end

-- Add Definition
spiff.radialcommand = SpiffUIRadialCommand

------------------------------------------

function SpiffUIRadialCommandAsk:invoke()
    self.menu.command.amount = self.amount
    self.menu.command:Action()
end

function SpiffUIRadialCommandAsk:new(menu, text, texture, amount)
    local o = spiff.radialcommand.new(self, menu, text, texture, nil)
    o.amount = amount
    return o
end

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
    self.menu.page = self.menu.page - 1
    if self.menu.pageReset then
        self.menu.maxPage = self.menu.page
    end
    self.menu:show()
end

function SpiffUIRadialCommandPrev:new(menu, text, texture)
    return spiff.radialcommand.new(self, menu, text, texture, nil)
end

------------------------------------------

function SpiffUIRadialMenu:build()
    print("Base SpiffUIRadialMenu build -- Override me!")
end

function SpiffUIRadialMenu:askAmount()
    self.rmenu:clear()
    --table.wipe(self.commands)

    local askCommands = {}

    if self.command.shouldAsk == 1 then -- Consume: 1 (all), 1/2, 1/4, Dieter
        table.insert(askCommands, SpiffUIRadialCommandAsk:new(self, self.command.item:getName(), spiff.icons[4], 1))
        table.insert(askCommands, SpiffUIRadialCommandAsk:new(self, self.command.item:getName(), spiff.icons[2], 0.5))
        table.insert(askCommands, SpiffUIRadialCommandAsk:new(self, self.command.item:getName(), spiff.icons[3], 0.25))
        table.insert(askCommands, SpiffUIRadialCommandAsk:new(self, self.command.item:getName(), spiff.icons[5], -1))
    elseif self.command.shouldAsk == 2 then -- Crafting, all or 1
        table.insert(askCommands, SpiffUIRadialCommandAsk:new(self, self.command.recipe:getName(), spiff.icons[4], true))
        table.insert(askCommands, SpiffUIRadialCommandAsk:new(self, self.command.recipe:getName(), spiff.icons[1], false))
    end

    for _,command in ipairs(askCommands) do
        local count = #self.rmenu.slices
        command:fillMenu()
        if count == #self.rmenu.slices then
            self.rmenu:addSlice(nil, nil, nil)
        end
    end

    self.rmenu:center()
    self.rmenu:addToUIManager()
    self.rmenu:setVisible(true)
    SpiffUI.action.wasVisible = true
    if JoypadState.players[self.playerNum+1] then
        self.rmenu:setHideWhenButtonReleased(Joypad.DPadUp)
        setJoypadFocus(self.playerNum, self.rmenu)
        self.player:setJoypadIgnoreAimUntilCentered(true)
    end
end

function SpiffUIRadialMenu:display()    
    self:build()
    self.page = 1
    
    self:show()
end

function SpiffUIRadialMenu:show()
    self.rmenu:clear()

    local hasCommands = false

    -- Add the next page
    if self.maxPage > 1 and self.page < self.maxPage then
        local nextp = SpiffUIRadialCommandNext:new(self, "Next", self.nextTex)
        local count = #self.rmenu.slices
        nextp:fillMenu()
        if count == #self.rmenu.slices then
            self.rmenu:addSlice(nil, nil, nil)
        end
    end

    if self.commands[self.page] then
        for _,command in ipairs(self.commands[self.page]) do
            local count = #self.rmenu.slices
            command:fillMenu()
            if count == #self.rmenu.slices then
                self.rmenu:addSlice(nil, nil, nil)
            end
            hasCommands = true
        end
    end

    -- Add the previous page
    if self.maxPage > 1 and self.page > 1 then
        local nextp = SpiffUIRadialCommandPrev:new(self, "Previous", self.prevTex)
        local count = #self.rmenu.slices
        nextp:fillMenu()
        if count == #self.rmenu.slices then
            self.rmenu:addSlice(nil, nil, nil)
        end
    end

    if hasCommands then
        self.rmenu:center()
        self.rmenu:addToUIManager()
        self.rmenu:setVisible(true)
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

function SpiffUIRadialMenu:AddCommand(command)
    if self.cCount == self.cMax then
        --print("Adding New Page: " .. self.cCount)
        self.cCount = 0
        self.page = self.page + 1
        self.maxPage = self.page
    end

    if not self.commands[self.page] then
        self.commands[self.page] = {}
    end
    table.insert(self.commands[self.page], command)
    self.cCount = self.cCount + 1
    --print("Count: " .. self.cCount)
end

function SpiffUIRadialMenu:new(player)
    local o = ISBaseObject.new(self)

    o.player = player
    o.playerNum = player:getPlayerNum()

    o.rmenu = getPlayerRadialMenu(o.playerNum)

    o.commands = {}
    o.cCount = 0
    o.cMax = 16
    o.page = 1
    o.maxPage = 1

    o.nextTex = getTexture("media/SpiffUI/nextpage.png")                                              
    o.prevTex = getTexture("media/SpiffUI/prevpage.png")

    return o
end

spiff.radialmenu = SpiffUIRadialMenu