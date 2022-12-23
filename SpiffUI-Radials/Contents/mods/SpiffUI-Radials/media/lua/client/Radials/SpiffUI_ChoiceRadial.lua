------------------------------------------
-- SpiffUI Choice Actions
----  Radial Menu for making choices (ie how many)
------------------------------------------
SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIAskRadial = spiff.radialmenu:derive("SpiffUIAskRadial")
if not spiff.subradial then spiff.subradial = {} end
spiff.subradial.ask = SpiffUIAskRadial

------------------------------------------
-- Radial Command for asking amount
local SpiffUIRadialCommandAsk = spiff.radialcommand:derive("SpiffUIRadialCommandAsk")

function SpiffUIRadialCommandAsk:invoke()
    self.menu.prev.command.amount = self.amount
    self.menu.prev.command:Action()
end

function SpiffUIRadialCommandAsk:new(menu, text, texture, amount)
    local o = spiff.radialcommand.new(self, menu, text, texture, nil)
    o.amount = amount
    return o
end

------------------------------------------

function SpiffUIAskRadial:start()
    self:prepareCmds()

    if self.prev.command.shouldAsk == 1 then -- Consume: 1 (all), 1/2, 1/4, Dieter
        table.insert(self.commands[self.page], SpiffUIRadialCommandAsk:new(self, getText("UI_amount_SpiffUI_One"), getTexture("media/spifcons/choice/ALL.png"), 1))
        table.insert(self.commands[self.page], SpiffUIRadialCommandAsk:new(self, getText("UI_amount_SpiffUI_Half"), getTexture("media/spifcons/choice/1-2.png"), 0.5))
        table.insert(self.commands[self.page], SpiffUIRadialCommandAsk:new(self, getText("UI_amount_SpiffUI_Quarter"), getTexture("media/spifcons/choice/1-4.png"), 0.25))
        table.insert(self.commands[self.page], SpiffUIRadialCommandAsk:new(self, getText("UI_amount_SpiffUI_Full"), getTexture("media/spifcons/choice/FULL.png"), -1))
    elseif self.prev.command.shouldAsk == 2 then -- Crafting, all or 1
        table.insert(self.commands[self.page], SpiffUIRadialCommandAsk:new(self, getText("UI_amount_SpiffUI_All"), getTexture("media/spifcons/choice/ALL.png"), true))
        table.insert(self.commands[self.page], SpiffUIRadialCommandAsk:new(self, getText("UI_amount_SpiffUI_One"), getTexture("media/spifcons/choice/1.png"), false))
    end

    self:show()
end

function SpiffUIAskRadial:new(player, prev, centerImg, btmText)
    local o = spiff.radialmenu.new(self, player, prev, centerImg, btmText)
    return o
end