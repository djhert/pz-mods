------------------------------------------
-- SpiffUI Smoke Radial
----  Radial Menu for smoking
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUISmokeRadial = spiff.radialmenu:derive("SpiffUISmokeRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[8] = SpiffUISmokeRadial
------------------------------------------

local SpiffUISmokeRadialCommand = spiff.radialcommand:derive("SpiffUISmokeRadialCommand")

local function doSmokePack(pack, category, nextItem, player)
    -- Smoking a pack requires AutoSmoke.
    ---- AutoSmoke already has support for various mods out there, and is very popular
    ---- All Credit to NoctisFalco for the original AutoSmoke code
    if not AutoSmoke then return end
    AutoSmoke.currentAction = AutoSmoke.activeMod.unpackAction(player, pack, pack:getContainer(), nextItem, 
        AutoSmoke.activeMod.actions[category].time, AutoSmoke.activeMod.actions[category].jobType, AutoSmoke.activeMod.actions[category].sound)

    ISInventoryPaneContextMenu.transferIfNeeded(player, pack)
    ISTimedActionQueue.add(AutoSmoke.currentAction)
end

function SpiffUISmokeRadialCommand:Action()
    local lighterInv
    -- let AutoSmoke handle the inventory for the lighter
    ---- It seems to break it otherwise
    if not AutoSmoke then
        -- First we handle the lighter
        lighterInv = self.lighter:getContainer()
        ISInventoryPaneContextMenu.transferIfNeeded(self.player, self.lighter)
    end
    
    -- If we have a "nextitem" its from a pack of something
    if self.item.next then
        doSmokePack(self.item.item, self.item.category, self.item.next, self.player)
    else
        ISInventoryPaneContextMenu.eatItem(self.item.item, 1, self.playerNum)
    end

    -- Return lighter whence it came if needed!
    if lighterInv and lighterInv ~= self.player:getInventory() then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(self.player, self.lighter, self.player:getInventory(), lighterInv))
    end
end

function SpiffUISmokeRadialCommand:new(menu, item, lighter)
    local o = spiff.radialcommand.new(self, menu, item.item:getName(), item.item:getTexture(), item.item)

    o.item = item
    o.lighter = lighter
    return o
end

local function getNext(item)
    for i,_ in pairs(spiff.filters.smoke) do
        local out = spiff.filters.smoke[i][item]
        if out then
            return out
        end
    end
    return nil
end

local function getCat(item)
    for i,_ in pairs(spiff.filters.smoke) do
        local out = spiff.filters.smoke[i][item]
        if out then
            return i
        end
    end
    return "misc"
end

local function findRecursive(item)
    local found = false
    local out 
    local i = 0
    repeat
        local iS = luautils.split(item, ".")[2]
        if iS then
            item = iS
        end
        local t = getNext(item)
        if t and t ~= "" then
            if not out then out = {} end
            out[i] = t
            i = i + 1
            item = t
        else
            found = true
        end
    until(found)

    return out
end

local function checkFilters(item)
    if not AutoSmoke then return false end
    for i,_ in pairs(spiff.filters.smoke) do
        if spiff.filters.smoke[i][item] then
            return true
        end
    end
    return false
end

local function getItems(packs, lighter)
    local items = {}

    -- This will get any smokeables
    for p = 0, packs:size() - 1 do
        local pack = packs:get(p)
        local ps = pack:getAllEval(function(item)
            -- Our Filter is only active if AutoSmoke is enabled
            return (checkFilters(item:getType()) or item:getCustomMenuOption() == "Smoke")
        end)
        if ps and ps:size() > 0 then
            for i = 0, ps:size() - 1 do
                local item = ps:get(i)
                local stuff = {
                    item = item,
                    category = getCat(item:getType()),
                    next = nil,
                    nexti = nil
                }
                local nexti = findRecursive(item:getType())
                if nexti then
                    stuff.nexti = nexti
                    stuff.next = nexti[0]  
                end

                local addItem = false
                if item then
                    if spiff.rFilters.smoke.butts[item:getType()] then
                        if spiff.config.smokeShowButts then
                            addItem = true
                        end
                    elseif spiff.rFilters.smoke.gum[item:getType()] then
                        if spiff.config.smokeShowGum then
                            addItem = true
                        end
                    else
                        -- Everything else
                        addItem = true
                    end
                    if addItem and lighter then
                        items[item:getFullType()] = stuff              
                    end
                end

            end
        end
    end

    -- Only keep the most relevant.  Cigs > Open Pack > Closed Pack > Carton | Gum > Gum Pack > Gum Carton
    for i,j in pairs(items) do
        if j.nexti then
            for _,m in pairs(j.nexti) do
                if items[m] then
                    items[i] = nil
                    break
                end
            end
        end
    end

    return items
end

local function getLighter(pack)
    return pack:getFirstEvalRecurse(function(item)
        return (item:getType() == "Matches") or (item:getType() == "Lighter" and item:getUsedDelta() > 0)
    end)
end

function SpiffUISmokeRadial:start()
    -- A lighter is required to be on you
    local lighter = getLighter(self.player:getInventory())
    
    local bags = ISInventoryPaneContextMenu.getContainers(self.player)
    local items = getItems(bags, lighter)

    local haveItems = false

    for i,_ in pairs(items) do
        haveItems = true
        break
    end

    -- We may still have gum!
    if not haveItems then
        self.player:Say(getText("UI_character_SpiffUI_noSmokes"))
        return
    end
    if not haveItems and not lighter then
        self.player:Say(getText("UI_character_SpiffUI_noLighter"))
        return
    end

    -- Build Smokeables
    for _,j in pairs(items) do
        self:AddCommand(SpiffUISmokeRadialCommand:new(self, j, lighter))
        self.centerImg[self.page] = InventoryItemFactory.CreateItem("Base.Cigarettes"):getTexture()
        self.btmText[self.page] = getText("UI_SpiffUI_Radial_Smoke")
        self.cImgChange[self.page] = true
    end
end

function SpiffUISmokeRadial:new(player, prev)
    return spiff.radialmenu.new(self, player, prev)
end

local function SmokeDown(player)
    SpiffUI.onKeyDown(player)
    -- If showNow and we're doing an action, do it now
    if spiff.config.smokeShowNow and not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUISmokeRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

local function SmokeHold(player)
    if SpiffUI.holdTime() then
        -- Create Menu
        local menu = SpiffUISmokeRadial:new(player)
        menu:display()
    end
end

local function SmokeRelease(player)
    if SpiffUI.releaseTime() then
        -- We do the AutoSmoke Stuff if we don't do the radial
        ---- From AutoSmoke
        if AutoSmoke and AutoSmoke.player then
            if AutoSmoke.Options.characterSpeaks then
                AutoSmoke.pressedKey = true
            end
            AutoSmoke:checkInventory()
        end
    end
end

local function actionInit()
    local bind = {        
        name = 'SpiffUISmokeWheel',
        key = Keyboard.KEY_BACK,
        queue = true,
        Down = SmokeDown,
        Hold = SmokeHold,
        Up = SmokeRelease
    }

    SpiffUI:AddKeyBind(bind)
end

actionInit()