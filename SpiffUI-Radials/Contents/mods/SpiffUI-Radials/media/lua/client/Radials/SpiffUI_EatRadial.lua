------------------------------------------
-- SpiffUI Eat Actions
----  Radial Menu for food
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIEatRadial = spiff.radialmenu:derive("SpiffUIEatRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[2] = SpiffUIEatRadial
------------------------------------------

local SpiffUIEatRadialCommand = spiff.radialcommand:derive("SpiffUIEatRadialCommand")

-- Code below is adapted from the excellent ExtraSauce Quality of Life mod by MonsterSauce
local function round(num)
    return math.floor(num * 100 + 0.5) / 100;
end

local function doEat(item, player, amount)
    -- If we don't specify an amount, then figure it out
    if amount == -1 then
        local itemHunger = 0
        if (item.getBaseHunger and item:getBaseHunger()) then
            itemHunger = round(item:getBaseHunger())
        end

        local charHunger = round(player:getStats():getHunger())

        if itemHunger < 0 and charHunger >= 0.1 then
            
            local percentage = 1

            if (charHunger + itemHunger < 0) then
                percentage = -1 * round(charHunger / itemHunger)
                if (percentage > 0.95) then percentage = 1.0 end
            end
            amount = percentage
        end        
    end

    if amount ~= -1 then
        ISInventoryPaneContextMenu.eatItem(item, amount, player:getPlayerNum())
    else
        player:Say(getText("UI_character_SpiffUI_notHungry"))
    end
end

------------------------------------------

function SpiffUIEatRadialCommand:Action()
    doEat(self.item, self.player, self.amount)
 
    -- Return from whence it came...
    if self.item:getContainer() ~= self.player:getInventory() then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(self.player, self.item, self.player:getInventory(), self.item:getContainer()))
    end
end

function SpiffUIEatRadialCommand:new(menu, item)
    local o = spiff.radialcommand.new(self, menu, item:getName(), item:getTexture(), item)

    o.amount = spiff.config.eatAmount

    o.item = item
    
    if spiff.config.eatAmount == 0 then
        o.shouldAsk = 1
    end
    
    return o
end

local function getItems(packs, player)
    local items = {}
    for p = 0, packs:size() - 1 do
        local pack = packs:get(p)
        local ps = pack:getAllEval(function(item)
            return (instanceof(item, "Food") and not player:isKnownPoison(item) and not item:getScriptItem():isCantEat())
                    and item:getHungChange() < 0 and not item:getCustomMenuOption()
        end)
        if ps and ps:size() > 0 then
            for i = 0, ps:size() - 1 do
                local item = ps:get(i)
                if item then
                    if not items then items = {} end
                    if not items[item:getType()] or items[item:getType()]:getHungChange() < item:getHungChange() then
                        items[item:getType()] = item
                    end
                end
            end
        end
    end
    local food = nil

    for _,j in pairs(items) do
        if not food then food = {} end
        table.insert(food, j)
    end

    if food then
        table.sort(food, function(a,b) 
            return a:getHungChange() > b:getHungChange()
        end)
    end

    return food
end

------------------------------------------

function SpiffUIEatRadial:start()
    local packs = ISInventoryPaneContextMenu.getContainers(self.player)
    local food = getItems(packs, self.player)

    if not food then
        self.player:Say(getText("UI_character_SpiffUI_noFood"))
        return
    end

    -- Build
    for _,j in ipairs(food) do
        self:AddCommand(SpiffUIEatRadialCommand:new(self, j))
        self.centerImg[self.page] = InventoryItemFactory.CreateItem("Base.Apple"):getTexture()
        self.btmText[self.page] = getText("UI_SpiffUI_Radial_Eat")
        self.cImgChange[self.page] = true
    end
end

function SpiffUIEatRadial:new(player, prev)
    local o = spiff.radialmenu.new(self, player, prev)
    o.askText = getText("UI_amount_SpiffUI_EatHowMuch")
    return o    
end

local function quickEat(player)
    if player:getStats():getHunger() < 0.1 then 
        player:Say(getText("UI_character_SpiffUI_notHungry"))
        return 
    end
    local packs = ISInventoryPaneContextMenu.getContainers(player)
    local food = getItems(packs)

    if not food then
        player:Say(getText("UI_character_SpiffUI_noFood"))
        return
    end

    for _,item in ipairs(food) do
       -- Just do the first thing
       local amount = spiff.config.eatQuickAmount
        if amount == 0 then amount = -1 end
       doEat(item, player, amount)
       --ISInventoryPaneContextMenu.eatItem(item, spiff.config.eatQuickAmount, player:getPlayerNum())
 
        -- Return from whence it came...
        if item:getContainer() ~= player:getInventory() then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, player:getInventory(), item:getContainer()))
        end
        return 
    end
end

local function EatDown(player)
    SpiffUI.onKeyDown(player)
    -- If showNow and we're doing an action, do it now
    if spiff.config.eatShowNow and not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUIEatRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

local function EatHold(player)
    if SpiffUI.holdTime() then
        -- Create Menu
        local menu = SpiffUIEatRadial:new(getSpecificPlayer(0))
        menu:display()
    end
end

local function EatRelease(player)
    if SpiffUI.releaseTime() then
        quickEat(player)
    end
end

local function actionInit()
    local bind = {        
        name = 'SpiffUIEatWheel',
        key = 27, -- }
        queue = true,
        Down = EatDown,
        Hold = EatHold,
        Up = EatRelease
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()