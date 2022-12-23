------------------------------------------
-- SpiffUI Repair Actions
----  Radial Menu for Repair
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIRepairRadial = spiff.radialmenu:derive("SpiffUIRepairRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[6] = SpiffUIRepairRadial
------------------------------------------

local SpiffUIRepairRadialCommand = spiff.radialcommand:derive("SpiffUIRepairRadialCommand")

local function returnItems(items, player)
    for i=0,items:size() - 1 do
        local item = items:get(i)
        if item:getContainer() ~= player:getInventory() then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, player:getInventory(), item:getContainer()))
        end
    end
end

function SpiffUIRepairRadialCommand:Action()
    local items = self.item.fixing:getRequiredItems(self.player, self.item.fixer, self.item.item)
    ISInventoryPaneContextMenu.onFix(self.item.item, self.playerNum, self.item.fixing, self.item.fixer)
    returnItems(items, self.player)
end

function SpiffUIRepairRadialCommand:new(menu, stuff)
    local o = spiff.radialcommand.new(self, menu, stuff.label, stuff.item:getTexture(), stuff.tooltip)
    o.item = stuff
    o.forceText = true
    return o
end

-- This is mostly a combination function that reimplements 'ISInventoryPaneContextMenu.addFixerSubOption'
---- The tooltip is used in our radial override tooltip
---- returns a "stuff" table that is used to build a radial command
local function fixerStuff(item, fixing, fixer, player)
    local unavailable = false
    local tooltip = {
        description = "",
        texture = item:getTex(),
        name = item:getName(),
        isFix = true
    }
    local fixerItem = fixing:haveThisFixer(player, fixer, item)

    local usedItem = InventoryItemFactory.CreateItem(fixing:getModule():getName() .. "." .. fixer:getFixerName())
    local itemName
    if usedItem then
        tooltip.texture = usedItem:getTex()
        itemName = getItemNameFromFullType(usedItem:getFullType())
    else
        itemName = fixer:getFixerName()
    end
    tooltip.name = itemName 

    local condPercentRepaired = FixingManager.getCondRepaired(item, player, fixing, fixer)
    local color1 = "<RED>";
    if condPercentRepaired > 15 and condPercentRepaired <= 25 then
        color1 = "<ORANGE>";
    elseif condPercentRepaired > 25 then
        color1 = "<GREEN>";
    end

    local chanceOfSucess = 100 - FixingManager.getChanceOfFail(item, player, fixing, fixer)
    local color2 = "<RED>";
    if chanceOfSucess > 15 and chanceOfSucess <= 40 then
        color2 = "<ORANGE>";
    elseif chanceOfSucess > 40 then
        color2 = "<GREEN>";
    end

    tooltip.description = " " .. color1 .. " " .. getText("Tooltip_potentialRepair") .. " " .. math.ceil(condPercentRepaired) .. "%"
    tooltip.description = tooltip.description .. " <LINE> " .. color2 .. " " .. getText("Tooltip_chanceSuccess") .. " " .. math.ceil(chanceOfSucess) .. "%"
	tooltip.description = tooltip.description .. " <LINE> <LINE> <RGB:1,1,1> " .. getText("Tooltip_craft_Needs") .. ": <LINE> "
    
    if fixing:getGlobalItem() then
        local globalItem = fixing:haveGlobalItem(player);
        local uses = fixing:countUses(player, fixing:getGlobalItem(), nil)
        if globalItem then
            tooltip.description = tooltip.description .. " <LINE> " .. globalItem:getName() .. " " .. uses .. "/" .. fixing:getGlobalItem():getNumberOfUse() .. " <LINE> "
        else
            local globalItem = InventoryItemFactory.CreateItem(fixing:getModule():getName() .. "." .. fixing:getGlobalItem():getFixerName())
            local name = fixing:getGlobalItem():getFixerName();
            if globalItem then name = globalItem:getName(); end
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. name .. " " .. uses .. "/" .. fixing:getGlobalItem():getNumberOfUse() .. " <LINE> "
            unavailable = true
        end
    end

    local uses = fixing:countUses(player, fixer, item)
	if uses >= fixer:getNumberOfUse() then 
        color1 = " <RGB:1,1,1> " 
    else 
        color1 = " <RED> " 
        unavailable = true
    end
	tooltip.description = tooltip.description .. color1 .. itemName .. " " .. uses .. "/" .. fixer:getNumberOfUse()
	
    if fixer:getFixerSkills() then
		local skills = fixer:getFixerSkills()
		for j=0,skills:size()-1 do
			local skill = skills:get(j)
			local perk = Perks.FromString(skill:getSkillName())
			local perkLvl = player:getPerkLevel(perk)
			if perkLvl >= skill:getSkillLevel() then
                color1 = " <RGB:1,1,1> "
            else
                color1 = " <RED> "
                unavailable = true
            end
			tooltip.description = tooltip.description .. " <LINE> " .. color1 .. PerkFactory.getPerk(perk):getName() .. " " .. perkLvl .. "/" .. skill:getSkillLevel()
		end
	end

    return {
        fixing = fixing,
        fixer = fixer,
        item = item,
        tooltip = tooltip,
        label = getItemNameFromFullType(item:getFullType()),
        texture = tooltip.texture,
        unavailable = unavailable,
        mode = 5
    }
end

local function getItems(packs, player)
    local items = {}
    for p = 0, packs:size() - 1 do
        local pack = packs:get(p)
        local ps = pack:getAllEval(function(item) 
            return item:isBroken() or item:getCondition() < item:getConditionMax()
        end)
        if ps and ps:size() > 0 then
            for i = 0, ps:size() - 1 do
                local item = ps:get(i)
                if item then
                    items[i] = item
                end
            end
        end
    end

    if not spiff.config.repairShowEquipped then
        for i,item in pairs(items) do
            if player:isEquipped(item) then
                items[i] = nil
            end
        end
    end

    if not spiff.config.repairShowHotbar then
        local hotbar = getPlayerHotbar(player:getPlayerNum())
        for i,item in pairs(items) do
            if hotbar:isInHotbar(item) then
                items[i] = nil
            end
        end
    end

    local repairs = nil
    local count = 0
    for _,item in pairs(items) do 
        local fixingList = FixingManager.getFixes(item)
        if not fixingList:isEmpty() then
            for i=0,fixingList:size()-1 do
                local fixing = fixingList:get(i)
                for j=0,fixing:getFixers():size()-1 do
                    local fixer = fixing:getFixers():get(j)
                    local stuff = fixerStuff(item, fixing, fixer, player)
                    if not stuff.unavailable then
                        if not repairs then repairs = {} end
                        table.insert(repairs, stuff)
                    end
                end
            end
        end
    end
    return repairs
end

function SpiffUIRepairRadial:start()

    local packs = ISInventoryPaneContextMenu.getContainers(self.player)
    local items = getItems(packs, self.player)

    -- Build
    if items then
        for _,stuff in ipairs(items) do
            self:AddCommand(SpiffUIRepairRadialCommand:new(self, stuff))
            self.btmText[self.page] = getText("UI_SpiffUI_Radial_Repair")
            self.centerImg[self.page] = InventoryItemFactory.CreateItem("Base.Hammer"):getTexture()
            self.cImgChange[self.page] = true
        end
    else
        self.player:Say(getText("UI_character_SpiffUI_noRepair"))
    end
end

function SpiffUIRepairRadial:new(player, prev)
    return spiff.radialmenu.new(self, player, prev)    
end

local function RepairDown(player)
    SpiffUI.onKeyDown(player)
    -- If showNow and we're doing an action, do it now
    if not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUIRepairRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

local function actionInit()
    local bind = {        
        name = 'SpiffUIRepairWheel',
        key = Keyboard.KEY_N,
        queue = true,
        Down = RepairDown
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()