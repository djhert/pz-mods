------------------------------------------
-- SpiffUI Drink Actions
----  Radial Menu for drinks
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIDrinkRadial = spiff.radialmenu:derive("SpiffUIDrinkRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[1] = SpiffUIDrinkRadial

------------------------------------------

local SpiffUIDrinkThirstRadialCommand = spiff.radialcommand:derive("SpiffUIDrinkThirstRadialCommand")

function SpiffUIDrinkThirstRadialCommand:Action()
    ISInventoryPaneContextMenu.onDrinkForThirst(self.item, self.player)

    -- Return from whence it came...
    if self.item:getContainer() ~= self.player:getInventory() then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(self.player, self.item, self.player:getInventory(), self.item:getContainer()))
    end
end

function SpiffUIDrinkThirstRadialCommand:new(menu, item)
    local o = spiff.radialcommand.new(self, menu, item:getName(), item:getTexture(), item)
    
    o.item = item
    return o
end

------------------------------------------

local SpiffUIDrinkRadialCommand = spiff.radialcommand:derive("SpiffUIDrinkRadialCommand")

-- Code below is adapted from the "Dieter" feature of the excellent ExtraSauce Quality of Life mod by MonsterSauce
local function round(num)
    return math.floor(num * 100 + 0.5) / 100;
end

local function doDrink(item, player, amount)
    -- If we don't specify an amount, then figure it out
    if amount == -1 then
        local itemThirst = 0
        if (item.getThirstChange and item:getThirstChange()) then
            itemThirst = round(item:getThirstChange())
        end
        local charThirst = round(player:getStats():getThirst())

        if itemThirst < 0 and charThirst >= 0.1 then
            
            local percentage = 1

            if (charThirst + itemThirst < 0) then
                percentage = -1 * round(charThirst / itemThirst)
                if (percentage > 0.95) then percentage = 1.0 end
            end
            amount = percentage
        end        
    end

    if amount ~= -1 then
        ISInventoryPaneContextMenu.eatItem(item, amount, player:getPlayerNum())
    else
        player:Say(getText("UI_character_SpiffUI_notThirsty"))
    end
end

function SpiffUIDrinkRadialCommand:Action()
    doDrink(self.item, self.player, self.amount) 
    -- Return from whence it came...
    if self.item:getContainer() ~= self.player:getInventory() then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(self.player, self.item, self.player:getInventory(), self.item:getContainer()))
    end
end

function SpiffUIDrinkRadialCommand:new(menu, item)
    local o = spiff.radialcommand.new(self, menu, item:getName(), item:getTexture(), item)

    o.amount = spiff.config.drinkAmount

    o.item = item
    
    if spiff.config.drinkAmount == 0 then
        o.shouldAsk = 1
    end
    
    return o
end

local function getItems(packs, player)
    local items = {}
    for p = 0, packs:size() - 1 do
        local pack = packs:get(p)
        local ps = pack:getAllEval(function(item)
            -- the only real difference between food and drinks is if there is a custom menu option/animation it seems.
            return item:isWaterSource()
                    or (instanceof(item, "Food") and not player:isKnownPoison(item) and not item:getScriptItem():isCantEat()) 
                    and (item:getCustomMenuOption() == getText("ContextMenu_Drink"))
        end)
        if ps and ps:size() > 0 then
            for i = 0, ps:size() - 1 do
                local item = ps:get(i)
                if item then
                    if item:isWaterSource() then
                        if not items[item:getType()] or items[item:getType()]:getUsedDelta() > item:getUsedDelta() then
                            items[item:getType()] = item
                        end
                    else
                        if not items[item:getType()] or items[item:getType()]:getThirstChange() < item:getThirstChange() then
                            items[item:getType()] = item
                        end
                    end
                    
                end
            end
        end
    end

    local drinks = nil

    for _,j in pairs(items) do
        if not drinks then drinks = {} end
        table.insert(drinks, j)
    end

    if drinks then
        table.sort(drinks, function(a,b)
            if a:isWaterSource() then
                return true
            end
            if b:isWaterSource() then
                return false
            end 
            return a:getThirstChange() > b:getThirstChange()
        end)
    end

    return drinks
end

------------------------------------------

function SpiffUIDrinkRadial:start()
    local packs = ISInventoryPaneContextMenu.getContainers(self.player)
    local drinks = getItems(packs, self.player)

    if not drinks then
        self.player:Say(getText("UI_character_SpiffUI_noDrinks"))
        return
    end

    local hasCmd = false
    
    -- Build
    for _,j in ipairs(drinks) do
        if j:isWaterSource() then
            if self.player:getStats():getThirst() > 0.1 then
                self:AddCommand(SpiffUIDrinkThirstRadialCommand:new(self, j))
                hasCmd = true
            end
        else
            self:AddCommand(SpiffUIDrinkRadialCommand:new(self, j))
            hasCmd = true
        end
        self.centerImg[self.page] = InventoryItemFactory.CreateItem("Base.WaterBottleFull"):getTexture()
        self.btmText[self.page] = "<RGB:1,0,0> "..getText("UI_SpiffUI_Radial_Drink")
        self.cImgChange[self.page] = true
    end

    if not hasCmd then
        self.player:Say(getText("UI_character_SpiffUI_noDrinks"))
    end
end

function SpiffUIDrinkRadial:new(player, prev)
    local o = spiff.radialmenu.new(self, player, prev)    
    o.askText = getText("UI_amount_SpiffUI_DrinkHowMuch")
    return o
end

local function quickDrink(player)
    if player:getStats():getThirst() < 0.1 then 
        player:Say(getText("UI_character_SpiffUI_notThirsty"))
        return 
    end
    local packs = ISInventoryPaneContextMenu.getContainers(player)
    local items = getItems(packs, player)

    if items then
        for _,item in ipairs(items) do
            if item:isWaterSource() then
                ISInventoryPaneContextMenu.onDrinkForThirst(item, player)
            else
                local amount = spiff.config.drinkQuickAmount
                if amount == 0 then amount = -1 end
                doDrink(item, player, amount)
            end
            -- Return from whence it came...
            if item:getContainer() ~= player:getInventory() then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, player:getInventory(), item:getContainer()))
            end
            -- Just do the first
            return
        end
    else
        player:Say(getText("UI_character_SpiffUI_noDrinks"))
    end
end

local function DrinksDown(player)
    SpiffUI.onKeyDown(player)
    -- If showNow and we're doing an action, do it now
    if spiff.config.drinkShowNow and not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUIDrinkRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

local function DrinksHold(player)
    if SpiffUI.holdTime() then
        -- Create Menu
        local menu = SpiffUIDrinkRadial:new(getSpecificPlayer(0))
        menu:display()
    end
end

local function DrinksRelease(player)
    if SpiffUI.releaseTime() then
        quickDrink(player)
    end
end

local function actionInit()
    local bind = {        
        name = 'SpiffUIDrinkWheel',
        key = 26, -- {
        queue = true,
        Down = DrinksDown,
        Hold = DrinksHold,
        Up = DrinksRelease
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()