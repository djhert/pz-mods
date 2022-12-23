------------------------------------------
-- SpiffUI Equipment Actions
----  Radial Menu for Equipment
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIEquipmentRadial = spiff.radialmenu:derive("SpiffUIEquipmentRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[3] = SpiffUIEquipmentRadial
------------------------------------------

local SpiffUIEquipmentRadialCommand = spiff.radialcommand:derive("SpiffUIEquipmentRadialCommand")
local SpiffUIEquipmentItemRadialCommand = spiff.radialcommand:derive("SpiffUIEquipmentItemRadialCommand")

local function returnItem(item, player)
    if item:getContainer() ~= player:getInventory() then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, player:getInventory(), item:getContainer()))
    end
end

local function returnItems(items, player)
    for i=0,items:size() - 1 do
        local item = items:get(i)
        returnItem(item, player)
    end
end

------------------------------------------

function SpiffUIEquipmentItemRadialCommand:Action()
    if self.mode == 0 then -- "Inspect"
        ISInventoryPaneContextMenu.onInspectClothing(self.player, self.item.item)
    elseif self.mode == 1 then -- "Unequip"                                                                                                                                                                      
        if self.item.inHotbar then
            -- We Detach it
            ISTimedActionQueue.add(ISDetachItemHotbar:new(self.player, self.item.item))
        end
        ISInventoryPaneContextMenu.unequipItem(self.item.item, self.playerNum)
    elseif self.mode == 2 then -- "Transfer To"
        ISTimedActionQueue.add(ISInventoryTransferAction:new(self.player, self.item.item, self.player:getInventory(), self.item.inv))
    elseif self.mode == 3 then -- "Drop"
        ISInventoryPaneContextMenu.dropItem(self.item.item, self.playerNum)
    elseif self.mode == 4 then -- Clothing Items Extra
        ISTimedActionQueue.add(ISClothingExtraAction:new(self.player, self.item.item, self.item.itype))
    elseif self.mode == 5 then --Recipes
        ISInventoryPaneContextMenu.OnCraft(self.item.item, self.item.recipe, self.playerNum, false)
    elseif self.mode == 6 then -- Item Repairs
        if not self.item.unavailable then
            local items = self.item.fixing:getRequiredItems(self.player, self.item.fixer, self.item.item)
            ISInventoryPaneContextMenu.onFix(self.item.item, self.playerNum, self.item.fixing, self.item.fixer)
            returnItems(items, self.player)
        else
            self.player:Say(getText("UI_character_SpiffUI_noRepairItems"))
        end
    elseif self.mode == 7 then -- Guns!
        if self.item.item ~= self.player:getPrimaryHandItem() then
            -- The gun has to be equipped in order for the radial menu to work
            ISInventoryPaneContextMenu.equipWeapon(self.item.item, true, self.item.item:isTwoHandWeapon(), self.playerNum)
        end
        local frm = ISFirearmRadialMenu:new(self.player)
        frm.weapon = self.item.item
        frm.prev = self.menu
		frm:fillMenu()
		frm:display()
    elseif self.mode == 8 then -- Place
        ISInventoryPaneContextMenu.onPlaceItemOnGround({self.item.item}, self.player)
    elseif self.mode == 9 then
        spiff.subradial.alarm:new(self.player, self.item.item, self.menu):display()
    elseif self.mode == 10 then
        self.item.item:stopRinging()
    else
        self.player:Say("OOPS! I don't know how to do that.  That's not supposed to happen!")
    end
end

function SpiffUIEquipmentItemRadialCommand:new(menu, stuff)
    local o = spiff.radialcommand.new(self, menu, stuff.label, stuff.texture, stuff.tooltip)
    o.item = stuff
    o.mode = stuff.mode
    o.forceText = true
       
    return o
end
------------------------------------------

function SpiffUIEquipmentRadialCommand:Action()
    self.menu.page = self.menu.page + 1
    self.menu.maxPage = self.menu.page
    if self.mode == 0 then
        -- base menu, show item
        self.menu:itemOptions(self.item)
    elseif self.mode == 1 then
        -- show accessories
        self.menu:accessories()
    elseif self.mode == 2 then
        -- show accessories
        self.menu:hotbar()
    end
end

function SpiffUIEquipmentRadialCommand:new(menu, item, mode)
    local o
    if mode == 0 then
        o = spiff.radialcommand.new(self, menu, item:getName(), item:getTexture(), item)
    else
        o = spiff.radialcommand.new(self, menu, item.label, item.texture, nil)
    end

    o.item = item
    o.mode = mode
    return o
end

------------------------------------------

local clothesSort = {
    ["Hat"] = 0,
    ["FullHat"] = 1,
    ["FullHelmet"] = 2,
    ["FullSuit"] = 3,
    ["FullSuitHead"] = 4,
    ["FullTop"] = 5,
    ["JacketHat"] = 6,
    ["SweaterHat"] = 7,
    ["Ears"] = 108,
    ["EarTop"] = 109,
    ["Eyes"] = 110,
    ["MakeUp_Eyes"] = 111,
    ["MakeUp_EyesShadow"] = 112,
    ["MaskEyes"] = 113,
    ["RightEye"] = 114,
    ["LeftEye"] = 115,
    ["Nose"] = 116,
    ["MakeUp_Lips"] = 117,
    ["MakeUp_FullFace"] = 118,
    ["Mask"] = 119,
    ["MaskFull"] = 120,
    ["Neck"] = 121,
    ["Necklace"] = 122,
    ["Necklace_Long"] = 123,
    ["Scarf"] = 24,
    ["Jacket"] = 25,
    ["Sweater"] = 26,
    ["JacketHat"] = 27,
    ["SweaterHat"] = 28,
    ["Dress"] = 29,
    ["BathRobe"] = 30,
    ["Shirt"] = 31,
    ["TankTop"] = 32,
    ["TorsoExtra"] = 33,
    ["Tshirt"] = 34,
    ["ShortSleeveShirt"] = 35,
    ["Sweater"] = 36,
    ["AmmoStrap"] = 137,
    ["BellyButton"] = 138,
    ["Belt"] = 39,
    ["Holster"] = 139,
    ["BeltExtra"] = 140,
    ["FannyPackBack"] = 41,
    ["FannyPackFront"] = 42,
    ["Hands"] = 43,
    ["Watch"] = 44,
    ["Left_MiddleFinger"] = 144,
    ["Left_RingFinger"] = 145,
    ["LeftWrist"] = 146,
    ["Right_MiddleFinger"] = 147,
    ["Right_RingFinger"] = 148,
    ["RightWrist"] = 149,
    ["Tail"] = 150,
    ["Underwear"] = 51,
    ["UnderwearBottom"] = 52,
    ["UnderwearExtra1"] = 53,
    ["UnderwearExtra2"] = 54,
    ["UnderwearInner"] = 55,
    ["UnderwearTop"] = 56,
    ["Skirt"] = 57,
    ["Torso1Legs1"] = 58,
    ["Legs1"] = 59,
    ["Pants"] = 60,
    ["Socks"] = 61,
    ["Shoes"] = 62,
    [""] = 99
}

local clothesFilter = {
    ["Bandage"] = true,
    ["Wound"] = true,
    ["ZedDmg"] = true
}

local isWatch = function(item)
    if instanceof(item, "AlarmClock") or instanceof(item, "AlarmClockClothing") then
        return "Watch"
    else
        return nil
    end
end

local function getItems(packs, player)
    local items = nil

    -- First get worn items
    local clothes = player:getWornItems()
    for i=0, clothes:size() - 1 do
        if not items then items = {} end
        local item = clothes:get(i):getItem()
        if item and not clothesFilter[(isWatch(item) or item:getBodyLocation())] then
            table.insert(items, item)
        end      
    end

    -- Add any equipped items in our hands too
    local primary = player:getPrimaryHandItem()
    local secondary = player:getSecondaryHandItem()
    if primary then
        if not items then items = {} end
        table.insert(items, primary)
    end
    if secondary and secondary ~= primary then
        if not items then items = {} end
        table.insert(items, secondary)
    end

    if items then
        -- order our clothes from head to toe
        ---- NEW: We have to handle watches a bit funny due to how this works
        ------ Mods may add bracelets or other items that go on the wrist, and we don't want those

        table.sort(items, function(a,b)
            if not clothesSort[isWatch(a) or a:getBodyLocation()] or not clothesSort[isWatch(b) or b:getBodyLocation()] then return false end
            return clothesSort[isWatch(a) or a:getBodyLocation()] < clothesSort[isWatch(b) or b:getBodyLocation()]
        end)
    end
    return items
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
        label = getText("ContextMenu_Repair") .. getItemNameFromFullType(item:getFullType()),
        texture = tooltip.texture,
        unavailable = unavailable,
        mode = 6
    }
end
-- spiff.functions = {}
-- spiff.functions.FixerStuff = fixerStuff

function SpiffUIEquipmentRadial:itemOptions(item)
    if not self.commands[self.page] then
        self.commands[self.page] = {}
    else
        table.wipe(self.commands[self.page])
    end

    if not item then return end

    -- Get Hotbar & loot
    local hotbar = getPlayerHotbar(self.playerNum)
    local loot = getPlayerLoot(self.playerNum)

    self.btmText[self.page] = SpiffUI.textwrap(item:getName(), 20) -- some names are just too long :/

    --self.btmText[self.page] = nil
    self.centerImg[self.page] = item:getTexture()

    -- Add "Inspect"
    if item:getCategory() == "Clothing" and item:getCoveredParts():size() > 0 then
        local stuff = {
            item = item,
            label = getText("IGUI_invpanel_Inspect"),
            texture = item:getTexture(),
            tooltip = item,
            mode = 0
        }
        table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
    end
        
    do -- Add "Unequip"
        local stuff = {
            item = item,
            label = getText("ContextMenu_Unequip"),
            texture = getTexture("media/ui/Icon_InventoryBasic.png"),
            tooltip = item,
            inHotbar = hotbar:isInHotbar(item) and not self.player:isEquipped(item), -- Trigger a remove from hotbar if item is not equipped
            mode = 1
        }
        table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
    end

    -- Transfer
    if spiff.config.equipShowTransfer then
        if loot.inventory:getType() ~= "floor" then
            local tex = nil
            if instanceof(loot.inventory:getContainingItem(), "InventoryContainer") then
                tex = loot.inventory:getContainingItem():getTex()
            else
                tex = ContainerButtonIcons[loot.inventory:getType()]
            end

            if not tex then
                tex = getTexture("media/ui/Container_Shelf.png")
            end

            local stuff = {
                item = item,
                label = getText("UI_radial_SpiffUI_Transfer") .. loot.title,
                texture = tex,
                inv = loot.inventory,
                tooltip = item,
                mode = 2
            }
            table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
        end
    end

    -- Add "Drop"
    if spiff.config.equipShowDrop then
        local stuff = {
            item = item,
            label = getText("ContextMenu_Drop"),
            texture = getTexture("media/ui/Container_Floor.png"),
            tooltip = item,
            mode = 3
        }
        table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
    end

    -- Add "Place"
    if spiff.config.equipShowPlace then
        -- adapted from ISInventoryPaneContextMenu
        local id3 = true
        if not item:getWorldStaticItem() and not instanceof(item, "HandWeapon") and not instanceof(item, "Clothing") or item:getType() == "CarBatteryCharger" then
            id3 = false
        end
		
        if id3 and instanceof(item, "Clothing") then
            id3 = item:canBe3DRender()
        end

        if id3 then
            local stuff = {
                item = item,
                label = getText("IGUI_PlaceObject"),
                texture = getTexture("media/spifcons/place_item.png"),
                tooltip = item,
                mode = 8
            }
            
            table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
        end
    end

    -- Watch!
    if instanceof(item, "AlarmClock") or instanceof(item, "AlarmClockClothing") then
        if item:isRinging() then
            local stuff = {
                item = item,
                label = getText("ContextMenu_StopAlarm"),
                texture = getTexture("media/ui/emotes/no.png"),
                mode = 10
            }
            table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
        end

        local stuff = {
            item = item,
            label = getText("ContextMenu_SetAlarm"),
            texture = getTexture("media/ui/ClockAssets/ClockAlarmLargeSound.png"),
            mode = 9
        }
        table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
    end

       -- Add Clothing Items Extra
    if item.getClothingItemExtraOption and item:getClothingItemExtraOption() and spiff.config.equipShowClothingActions then 
        for i=0,item:getClothingItemExtraOption():size()-1 do
            local action = item:getClothingItemExtraOption():get(i)
            local itemType = moduleDotType(item:getModule(), item:getClothingItemExtra():get(i))
            local stuff = {
                item = item,
                itype = itemType,
                label = getText("ContextMenu_" .. action),
                texture = InventoryItemFactory.CreateItem(itemType):getTexture(),
                tooltip = item,
                mode = 4
            }
            table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
        end
    end

    --Add Recipes
    if spiff.config.equipShowRecipes then
        local recs = RecipeManager.getUniqueRecipeItems(item, self.player, self.packs)
        for i = 0, recs:size() - 1 do
            local recipe = recs:get(i)
            local stuff = {
                item = item,
                recipe = recipe,
                label = recipe:getName(),
                texture = InventoryItemFactory.CreateItem(recipe:getResult():getFullType()):getTexture(),
                tooltip = {
                    recipe = recipe,
                    item = item,
                    isRecipe = true
                },
                mode = 5
            }
            
            table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
        end
    end

    -- Add Item Repairs
    if item:isBroken() or item:getCondition() < item:getConditionMax() then
        local fixingList = FixingManager.getFixes(item)
        if not fixingList:isEmpty() then
            for i=0,fixingList:size()-1 do
                local fixing = fixingList:get(i)
                for j=0,fixing:getFixers():size()-1 do
                    local fixer = fixing:getFixers():get(j)
                    local stuff = fixerStuff(item, fixing, fixer, self.player)
                    if stuff.unavailable then
                        if spiff.config.equipShowAllRepairs then
                            table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
                        end
                    else 
                        table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
                    end
                end
            end
        end
    end

    -- Guns!
    if item.isRanged and item:isRanged() then 
        local stuff = {
            item = item,
            label = getText("UI_equip_SpiffUI_FirearmRadial"),
            texture = item:getTexture(),
            tooltip = item,
            mode = 7
        }
        table.insert(self.commands[self.page], SpiffUIEquipmentItemRadialCommand:new(self, stuff))
    end    

    self:show()
end

function SpiffUIEquipmentRadial:accessories()
    self:prepareCmds()

    self.btmText[self.page] = getText("UI_radial_SpiffUI_Accessories")
    self.centerImg[self.page] = self.accTex
    self.cImgChange[self.page] = true

    for _,j in ipairs(self.items) do
        if not clothesSort[isWatch(j) or j:getBodyLocation()] or clothesSort[isWatch(j) or j:getBodyLocation()] > 100 then
            -- Add our items to page 2
            table.insert(self.commands[self.page], SpiffUIEquipmentRadialCommand:new(self, j, 0))
        end
    end

    self:show()
end

function SpiffUIEquipmentRadial:hotbar() 
    self:prepareCmds()

    self.btmText[self.page] = getText("UI_radial_SpiffUI_Hotbar")
    self.centerImg[self.page] = self.hotTex
    self.cImgChange[self.page] = true

    local hotbar = getPlayerHotbar(self.playerNum)
    for i,item in pairs(hotbar.attachedItems) do
        table.insert(self.commands[self.page], SpiffUIEquipmentRadialCommand:new(self, item, 0))
    end

    self:show()
end

function SpiffUIEquipmentRadial:start()

    self.packs = ISInventoryPaneContextMenu.getContainers(self.player)
    self.items = getItems(self.packs, self.player)

    self.page = 1
    self.maxPage = 1

    self.btmText[self.page] = getText("UI_SpiffUI_Radial_Equipment")
    self.centerImg[self.page] = getTexture("media/spifcons/inventory.png")

    local haveAccs = false
    local accTex
    local hasItems = false
    if self.items then
        -- Start at page 1
        if not self.commands[1] then
            self.commands[1] = {}
        end
        
        for _,j in ipairs(self.items) do
            if clothesSort[isWatch(j) or j:getBodyLocation()] and clothesSort[isWatch(j) or j:getBodyLocation()] < 100 then
                table.insert(self.commands[1], SpiffUIEquipmentRadialCommand:new(self, j, 0))
                hasItems = true
            else
                haveAccs = true
                if not accTex then
                    accTex = j:getTexture()
                    self.accTex = accTex
                end
            end
        end
        if haveAccs then
            local stuff = {
                label = getText("UI_radial_SpiffUI_Accessories"),
                texture = accTex
            }
            table.insert(self.commands[1], SpiffUIEquipmentRadialCommand:new(self, stuff, 1))
            hasItems = true
        end
    end

    do
        local hotbar = getPlayerHotbar(self.playerNum)
        for _,item in pairs(hotbar.attachedItems) do
            if item then 
                local stuff = {
                    label = getText("UI_radial_SpiffUI_Hotbar"),
                    texture = item:getTexture()
                }
                self.hotTex = item:getTexture()
                table.insert(self.commands[1], SpiffUIEquipmentRadialCommand:new(self, stuff, 2))
                hasItems = true
                break
            end
        end
    end

    if not hasItems then
        self.player:Say(getText("UI_character_SpiffUI_noEquip"))
    end
end

function SpiffUIEquipmentRadial:new(player, prev)
    local o = spiff.radialmenu.new(self, player, prev)
    -- If we end up back at page 1, then we're at the main menu
    o.pageReset = true
    o.cImgChange[o.page] = true
    return o
end

local function EquipDown(player)
    SpiffUI.onKeyDown(player)
    -- If showNow and we're doing an action, do it now
    if not SpiffUI.action.ready then
        if getPlayerInventory(0):getIsVisible() then
            if SpiffUI["inventory"] then
                ISInventoryPage.SpiffOnKey(player)
            else
                getPlayerInventory(0):setVisible(false)
                getPlayerLoot(0):setVisible(false)
            end
            SpiffUI.action.wasVisible = true
        end
    end
end

local function EquipHold(player)
    if SpiffUI.holdTime() then
        -- Create Menu
        local menu = SpiffUIEquipmentRadial:new(player)
        menu:display()
    end
end

local function EquipRelease(player)
    if SpiffUI.releaseTime() then
        if not SpiffUI.action.wasVisible then
            if SpiffUI["inventory"] then
                ISInventoryPage.SpiffOnKey(player)
            else
                local toggle = getPlayerInventory(0):getIsVisible()
                getPlayerInventory(0):setVisible(not toggle)
                getPlayerLoot(0):setVisible(not toggle)
            end
        end
        SpiffUI.action.wasVisible = false
    end
end

local function actionInit()
    local bind = {        
        name = 'SpiffUIEquipmentWheel',
        key = Keyboard.KEY_TAB,
        queue = false,
        Down = EquipDown,
        Hold = EquipHold,
        Up = EquipRelease
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()