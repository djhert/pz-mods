------------------------------------------
-- SpiffUI Pills Actions
---- Radial Menu for pills
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIPillsRadial = spiff.radialmenu:derive("SpiffUIPillsRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[5] = SpiffUIPillsRadial
------------------------------------------

local SpiffUIPillsRadialCommand = spiff.radialcommand:derive("SpiffUIPillsRadialCommand")

local function takePill(item, player)
    ISInventoryPaneContextMenu.takePill(item, player:getPlayerNum())
    
    -- Return from whence it came...
    if item:getContainer() ~= player:getInventory() then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, player:getInventory(), item:getContainer()))
    end
end

function SpiffUIPillsRadialCommand:Action()
    takePill(self.item, self.player)
end

function SpiffUIPillsRadialCommand:new(menu, item)
    local o = spiff.radialcommand.new(self, menu, item:getName(), item:getTexture(), item)

    o.item = item
    return o
end

------------------------------------------

local function getItems(packs, pills)
    for p = 0, packs:size() - 1 do
        local pack = packs:get(p)
        local ps = pack:getAllEval(function(item) 
            return luautils.stringStarts(item:getType(), "Pills") or item:getType() == "Antibiotics" -- special case
        end)
        if ps and ps:size() > 0 then
            for i = 0, ps:size() - 1 do
                local pill = ps:get(i)
                if pill then
                    -- If not found or has less pills
                    if not pills[pill:getType()] or (pill.getUsedDelta and pills[pill:getType()]:getUsedDelta() > pill:getUsedDelta()) then
                        pills[pill:getType()] = pill                        
                    end
                end
            end
        end
    end
    return pills
end

function SpiffUIPillsRadial:start()
    local pills = {}

    local packs = ISInventoryPaneContextMenu.getContainers(self.player)
    pills = getItems(packs, pills)

    local hasPills = false
    -- Build
    for i,j in pairs(pills) do
        self:AddCommand(SpiffUIPillsRadialCommand:new(self, j))
        hasPills = true
        self.btmText[self.page] = getText("UI_SpiffUI_Radial_Pills")
        self.centerImg[self.page] = InventoryItemFactory.CreateItem("Base.PillsAntiDep"):getTexture()
        self.cImgChange[self.page] = true
    end
    if not hasPills then
        self.player:Say(getText("UI_character_SpiffUI_noPills"))
    end
end

function SpiffUIPillsRadial:new(player, prev)
    local o = spiff.radialmenu.new(self, player, prev)
    o.askText = getText("UI_amount_SpiffUI_HowManyPills")
    return o  
end

------------------------------------------

local function getPillsQuick(player, ptype)
    return player:getInventory():getFirstEvalRecurse(function(item)
        return item:getType() == ptype
    end)
end

local function takePills(items, player)
    -- First we'll take all our pills
    for _,item in ipairs(items) do
        ISInventoryPaneContextMenu.takePill(item, player:getPlayerNum())
    end
    
    -- Then we send them back
    for _,item in ipairs(items) do
        if item:getContainer() ~= player:getInventory() then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, player:getInventory(), item:getContainer()))
        end
    end
end

local function quickPills(player)
    local tried = ""
    local pills = nil
    if player:getMoodles():getMoodleLevel(MoodleType.Pain) >= 1 then
        tried = getItemNameFromFullType("Base.Pills")
        -- Take Painpills
        local pill = getPillsQuick(player, "Pills")
        if pill then
            --print("Pain Pills")
            if not pills then pills = {} end
            table.insert(pills, pill)
        end
    end
    if player:getMoodles():getMoodleLevel(MoodleType.Tired) >= 1 then
        local name = getItemNameFromFullType("Base.PillsVitamins")
        if tried ~= "" then
            tried = tried .. ", " .. name
        else
            tried = name
        end
        -- Take Vitamins
        local pill = getPillsQuick(player, "PillsVitamins")
        if pill then
            --print("Vitamins")
            if not pills then pills = {} end
            table.insert(pills, pill)
        end
    end
    if player:getMoodles():getMoodleLevel(MoodleType.Panic) >= 1 then
        local name = getItemNameFromFullType("Base.PillsBeta")
        if tried ~= "" then
            tried = tried .. ", " .. name
        else
            tried = name
        end
        -- Take Beta Blockers
        local pill = getPillsQuick(player, "PillsBeta")
        if pill then
            --print("Beta Blockers")
            if not pills then pills = {} end
            table.insert(pills, pill)
        end
    end
    if player:getMoodles():getMoodleLevel(MoodleType.Unhappy) >= 1 then
        local name = getItemNameFromFullType("Base.PillsAntiDep")
        if tried ~= "" then
            tried = tried .. ", " .. name
        else
            tried = name
        end
        -- Take Antidepressents
        local pill = getPillsQuick(player, "PillsAntiDep")
        if pill then
            --print("Antidepressents")
            if not pills then pills = {} end
            table.insert(pills, pill)
        end
    end
    
    if tried ~= "" then
        if not pills then
            player:Say(getText("UI_character_SpiffUI_noPillsQuick") .. tried)
        else
            takePills(pills, player)
        end
    else
        player:Say(getText("UI_character_SpiffUI_noPillsNeed"))
    end
end

local function PillsDown(player)
    SpiffUI.onKeyDown(player)
    -- If showNow and we're doing an action, do it now
    if spiff.config.pillsShowNow and not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUIPillsRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

local function PillsHold(player)
    if SpiffUI.holdTime() then
        -- Create Menu
        local menu = SpiffUIPillsRadial:new(player)
        menu:display()
    end
end

local function PillsRelease(player)
    if SpiffUI.releaseTime() then
        quickPills(player)
    end
end

local function actionInit()
    local bind = {       
        name = 'SpiffUIPillWheel',
        key = 40, -- '
        queue = true,
        Down = PillsDown,
        Hold = PillsHold,
        Up = PillsRelease
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()