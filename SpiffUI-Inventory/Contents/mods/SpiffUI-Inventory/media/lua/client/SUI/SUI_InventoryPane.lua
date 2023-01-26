------------------------------------------
-- SpiffUI Inventory
------------------------------------------

-- Add module
SpiffUI = SpiffUI or {}

-- Register our inventory
local spiff = SpiffUI:Register("inventory")

local _ISInventoryPane_doButtons = ISInventoryPane.doButtons
-- Override so that the character minlger has no inventory options
function ISInventoryPane:doButtons(y)
    if self.parent.onCharacter then
        local mnglr = self.parent:getMingler(self.inventory:getType())
        if not mnglr then
            return _ISInventoryPane_doButtons(self,y)
        elseif mnglr.spiffI == -1 then
            --return _ISInventoryPane_doButtons(self,y)
        end
    else
        local playerInv = getPlayerInventory(self.player)
        if not playerInv:getMingler(playerInv.inventory:getType()) then
            return _ISInventoryPane_doButtons(self,y)
        end
    end
    self.contextButton1:setVisible(false)
    self.contextButton2:setVisible(false)
    self.contextButton3:setVisible(false)
end

------------------------------------------
-- Don't allow to drag items into the active Mingle container
local _ISInventoryPane_canPutIn = ISInventoryPane.canPutIn
function ISInventoryPane:canPutIn()
    local mnglr = self.parent:getMingler(self.inventory:getType())
    if mnglr then
        if mnglr.spiffI == 1 then
            return (self.parent.CM.bodies:canPutIn() ~= nil)
        elseif mnglr.spiffI == 2 then
            return (self.parent.CM.container:canPutIn() ~= nil)
        end
        return false
    end
    return _ISInventoryPane_canPutIn(self)
end

local _ISInventoryPane_transferItemsByWeight = ISInventoryPane.transferItemsByWeight
function ISInventoryPane:transferItemsByWeight(items, container)
    local mnglr = self.parent:getMingler(container:getType())
    print("What up from mingler")
    if mnglr then
        if mnglr.spiffI > 0 then
            container = mnglr:canPutIn()
            if container then print("Have a container") end
            if not container then return end
        else
            return
        end
    end
    _ISInventoryPane_transferItemsByWeight(self, items, container)
end

local _ISInventoryPane_onMouseDoubleClick =  ISInventoryPane.onMouseDoubleClick
function ISInventoryPane:onMouseDoubleClick(x, y)
    -- if this is the inventory, always do the double click action
    if self.parent.onCharacter then
        if self.parent:getMingler(self.inventory:getType()) then
            if self.items and self.mouseOverOption and self.previousMouseUp == self.mouseOverOption then
                local item = self.items[self.mouseOverOption]
                if item and item.items then
                    for k, v in ipairs(item.items) do
                        if k ~= 1 then
                            self:doContextualDblClick(v)
                        end
                    end
                    return
                end
            end
        else
            return _ISInventoryPane_onMouseDoubleClick(self, x, y)
        end
    else
        -- Otherwise, don't do the double-click if the inventory mingler is open
        local playerInv = getPlayerInventory(self.player)
        local mnglr = playerInv:getMingler(playerInv.inventory:getType())
        if not mnglr then
            _ISInventoryPane_onMouseDoubleClick(self, x, y)
        end
    end
end

-- local equipSort = require("SUI/SUI_InventorySorter")

-- function ISInventoryPane:toggleEquipSort()
--     if self.equipSort then
--         self.equipSort = nil
--     else
--         self.equipSort = equipSort.itemsList
--     end
--     self:refreshContainer()
-- end

-- -- local _ISInventoryPane_onFilterMenu =  ISInventoryPane.onFilterMenu
-- -- function ISInventoryPane:onFilterMenu(button)
-- --     _ISInventoryPane_onFilterMenu(self, button)
-- --     if not self.parent.onCharacter and getSpecificPlayer(self.player):isAsleep() then
-- --         return
-- --     end
-- --     local mnglr = self.parent:getMingler(self.parent.inventory:getType())
-- --     if mnglr and mnglr.spiffI == -1 then
-- --         getPlayerContextMenu(self.player):addOption("What Up", self, ISInventoryPane.toggleEquipSort)
-- --     end
-- -- end

local _ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
    _ISInventoryPane_refreshContainer(self)
    
    local newlist = {}
    self.equiplist = {}
    self.hotlist = {}
    local i,j,h = 1,1,1
    for k, v in ipairs(self.itemslist) do
        if v then
            if v.equipped or v.inHotbar then
                self.equiplist[j] = self.itemslist[k]
                j = j+1
                
            else
                newlist[i] = self.itemslist[k]
                i = i+1
            end
        end
    end
    if spiff.config.hideEquipped then
        self.itemslist = newlist
    end

    if self.equipSort then
        table.sort(self.equiplist, self.equipSort)
    end
end

------------------------------------------
-- Visually show no dragging
local allowed = {
    ["SpiffBodies"] = true,
    ["SpiffContainer"] = true,
    ["SpiffPack"] = false,
    ["SpiffEquip"] = false
}
local _DraggedItems_update = ISInventoryPaneDraggedItems.update
function ISInventoryPaneDraggedItems:update()
    self.playerNum = self.inventoryPane.player
    local playerInv = getPlayerInventory(self.playerNum)
    if self.mouseOverContainer then
        if allowed[self.mouseOverContainer:getType()] then
            if getPlayerLoot(self.playerNum):getMingler(self.mouseOverContainer:getType()):canPutIn() == nil then
                self.itemNotOK = {}
                self.validItems = {}
                for _,v in pairs(self.items) do
                    self.itemNotOK[v] = true
                end
            end
        elseif allowed[self.mouseOverContainer:getType()] == false then
            self.itemNotOK = {}
            self.validItems = {}
            for _,v in pairs(self.items) do
                self.itemNotOK[v] = true
            end
        end
       -- end
    end
    _DraggedItems_update(self)
end

ISInventoryPaneContextMenu.onGrabItems = function(items, player)
	local playerInv = getPlayerInventory(player)
    local mnglr = playerInv:getMingler(playerInv.inventory:getType())
    if not mnglr then
	    ISInventoryPaneContextMenu.transferItems(items, playerInv.inventory, player)
    end
end

local _ISInventoryPaneContextMenu_onGrabOneItems = ISInventoryPaneContextMenu.onGrabOneItems
ISInventoryPaneContextMenu.onGrabOneItems = function(items, player)
    local playerInv = getPlayerInventory(player)
    local mnglr = playerInv:getMingler(playerInv.inventory:getType())
    if not mnglr then
        _ISInventoryPaneContextMenu_onGrabOneItems(items, player)
    end
end

local _ISInventoryPaneContextMenu_doGrabMenu = ISInventoryPaneContextMenu.doGrabMenu
function ISInventoryPaneContextMenu.doGrabMenu(context, items, player)
    local playerInv = getPlayerInventory(player)
    local mnglr = playerInv:getMingler(playerInv.inventory:getType())
    if not mnglr then
	    _ISInventoryPaneContextMenu_doGrabMenu(context, items, player)
    end
end

local _ISInventoryPaneContextMenu_isAnyAllowed = ISInventoryPaneContextMenu.isAnyAllowed
function ISInventoryPaneContextMenu.isAnyAllowed(container, items)
    if allowed[container:getType()] or allowed[container:getType()] == nil then
        return _ISInventoryPaneContextMenu_isAnyAllowed(container, items)
    end
    return false
end


Events.OnGameStart.Add(function()
    if not spiff.config.spiffequip then return end
    local _ISInventoryPane_renderdetails = ISInventoryPane.renderdetails
    function ISInventoryPane:renderdetails(doDragged)
    if self.inventory:getType() == "SpiffEquip" then
            self:updateScrollbars();

            if doDragged == false then
                table.wipe(self.items)
        
                if self.inventory:isDrawDirty() then
                    self:refreshContainer()
                end
            end
            
            local player = getSpecificPlayer(self.player)
        
            local checkDraggedItems = false
            if doDragged and self.dragging ~= nil and self.dragStarted then
                self.draggedItems:update()
                checkDraggedItems = true
            end
        
            if not doDragged then
                -- background of item icon
                self:drawRectStatic(0, 0, self.column2, self.height, 0.6, 0, 0, 0);
            end
            local y = 0;
            local alt = false;
            if self.equiplist == nil then
                self:refreshContainer();
            end
            local MOUSEX = self:getMouseX()
            local MOUSEY = self:getMouseY()
            local YSCROLL = self:getYScroll()
            local HEIGHT = self:getHeight()
            local equippedLine = false
            for k, v in ipairs(self.equiplist) do
                local count = 1;
                -- Go through each item in stack..
                for k2, v2 in ipairs(v.items) do
                    local item = v2;
                    local doIt = true;
                    local xoff = 0;
                    local yoff = 0;
                    if doDragged == false then
                        -- if it's the first item, then store the category, otherwise the item
                        if count == 1 then
                            table.insert(self.items, v);
                        else
                            table.insert(self.items, item);
                        end
                        if instanceof(item, 'InventoryItem') then
                            item:updateAge()
                        end
                        if instanceof(item, 'Clothing') then
                            item:updateWetness()
                        end
                    end
                -- print("trace:b");
                    local isDragging = false
                    if self.dragging ~= nil and self.selected[y+1] ~= nil and self.dragStarted then
                        xoff = MOUSEX - self.draggingX;
                        yoff = MOUSEY - self.draggingY;
                        if not doDragged then
                            doIt = false;
                        else
                            self:suspendStencil();
                            isDragging = true
                        end
                    else
                        if doDragged then
                            doIt = false;
                        end
                    end
                    local topOfItem = y * self.itemHgt + YSCROLL
                    if not isDragging and ((topOfItem + self.itemHgt < 0) or (topOfItem > HEIGHT)) then
                        doIt = false
                    end
                -- print("trace:c");
                    if doIt == true then
                    -- print("trace:cc");
                --        print(count);
                        if count == 1 then
                            -- rect over the whole item line
        --                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth(), 1, 0.3, 0.0, 0.0, 0.0);
                        end
                    -- print("trace:d");
        
                        -- do controller selection.
                        if self.joyselection ~= nil and self.doController then
        --                    if self.joyselection < 0 then self.joyselection = (#self.itemslist) - 1; end
        --                    if self.joyselection >= #self.itemslist then self.joyselection = 0; end
                            if self.joyselection == y then
                                self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.2, 0.2, 1.0, 1.0);
                            end
                        end
                    -- print("trace:e");
        
                        -- only do icon if header or dragging sub items without header.
                        local tex = item:getTex();
                        if tex ~= nil then
                            local texDY = 1
                            local texWH = math.min(self.itemHgt-2,32)
                            local auxDXY = math.ceil(20 * self.texScale)
                            if count == 1  then
                                self:drawTextureScaledAspect(tex, 10+xoff, (y*self.itemHgt)+self.headerHgt+texDY+yoff, texWH, texWH, 1, item:getR(), item:getG(), item:getB());
                                if player:isEquipped(item) then
                                    self:drawTexture(self.equippedItemIcon, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
                                end
                                if not self.hotbar then
                                    self.hotbar = getPlayerHotbar(self.player);
                                end
                                if not player:isEquipped(item) and self.hotbar and self.hotbar:isInHotbar(item) then
                                    self:drawTexture(self.equippedInHotbar, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
                                end
                                if item:isBroken() then
                                    self:drawTexture(self.brokenItemIcon, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                                end
                                if instanceof(item, "Food") and item:isFrozen() then
                                    self:drawTexture(self.frozenItemIcon, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                                end
                                if (item:isTaintedWater() and getSandboxOptions():getOptionByName("EnableTaintedWaterText"):getValue()) or player:isKnownPoison(item) then
                                    self:drawTexture(self.poisonIcon, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                                end
                                if item:isFavorite() then
                                    self:drawTexture(self.favoriteStar, (13+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt-1+yoff, 1, 1, 1, 1);
                                end
                            elseif v.count > 2 or (doDragged and count > 1 and self.selected[(y+1) - (count-1)] == nil) then
                                self:drawTextureScaledAspect(tex, 10+16+xoff, (y*self.itemHgt)+self.headerHgt+texDY+yoff, texWH, texWH, 0.3, item:getR(), item:getG(), item:getB());
                                if player:isEquipped(item) then
                                    self:drawTexture(self.equippedItemIcon, (10+auxDXY+16+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
                                end
                                if item:isBroken() then
                                    self:drawTexture(self.brokenItemIcon, (10+auxDXY+16+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                                end
                                if instanceof(item, "Food") and item:isFrozen() then
                                    self:drawTexture(self.frozenItemIcon, (10+auxDXY+16+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                                end
                                if item:isFavorite() then
                                    self:drawTexture(self.favoriteStar, (13+auxDXY+16+xoff), (y*self.itemHgt)+self.headerHgt-1+yoff, 1, 1, 1, 1);
                                end
                            end
                        end
                    -- print("trace:f");
                        if count == 1 then
                            if not doDragged then
                                if not self.collapsed[v.name] then
                                    self:drawTexture( self.treeexpicon, 2, (y*self.itemHgt)+self.headerHgt+5+yoff, 1, 1, 1, 0.8);
                        --                     self:drawText("+", 2, (y*18)+16+1+yoff, 0.7, 0.7, 0.7, 0.5);
                                else
                                    self:drawTexture( self.treecolicon, 2, (y*self.itemHgt)+self.headerHgt+5+yoff, 1, 1, 1, 0.8);
                                end
                            end
                        end
                    -- print("trace:g");
        
                        if self.selected[y+1] ~= nil and not self.highlightItem then -- clicked/dragged item
                            if checkDraggedItems and self.draggedItems:cannotDropItem(item) then
                                self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.20, 1.0, 0.0, 0.0);
                            elseif false and (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() ~= 1) or item:getItemHeat() ~= 1) then
                                if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() > 1) or item:getItemHeat() > 1) then
                                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.5, math.abs(item:getInvHeat()), 0.0, 0.0);
                                else
                                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.5, 0.0, 0.0, math.abs(item:getInvHeat()));
                                end
                            else
                                self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.20, 1.0, 1.0, 1.0);
                            end
                        elseif self.mouseOverOption == y+1 and not self.highlightItem then -- called when you mose over an element
                            if(((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() ~= 1) or item:getItemHeat() ~= 1) then
                                if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() > 1) or item:getItemHeat() > 1) then
                                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.3, math.abs(item:getInvHeat()), 0.0, 0.0);
                                else
                                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.3, 0.0, 0.0, math.abs(item:getInvHeat()));
                                end
                            else
                                self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.05, 1.0, 1.0, 1.0);
                            end
                        else
                            if count == 1 then -- normal background (no selected, no dragging..)
                                -- background of item line
                                if self.highlightItem and self.highlightItem == item:getType() then
                                    if not self.blinkAlpha then self.blinkAlpha = 0.5; end
                                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  self.blinkAlpha, 1, 1, 1);
                                    if not self.blinkAlphaIncrease then
                                        self.blinkAlpha = self.blinkAlpha - 0.05 * (UIManager.getMillisSinceLastRender() / 33.3);
                                        if self.blinkAlpha < 0 then
                                            self.blinkAlpha = 0;
                                            self.blinkAlphaIncrease = true;
                                        end
                                    else
                                        self.blinkAlpha = self.blinkAlpha + 0.05 * (UIManager.getMillisSinceLastRender() / 33.3);
                                        if self.blinkAlpha > 0.5 then
                                            self.blinkAlpha = 0.5;
                                            self.blinkAlphaIncrease = false;
                                        end
                                    end
                                else
                                    self:drawRect(self.column2+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt, 0.2, 0.0, 0.0, 0.0);
                                end
                            else
                                self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.4, 0.0, 0.0, 0.0);
                            end
                        end
                    -- print("trace:h");
        
                        -- divider between equipped and unequipped items
                        if v.equipped then
                            if not doDragged and not equippedLine and y > 0 then
                                self:drawRect(1, ((y+1)*self.itemHgt)+self.headerHgt-1-self.itemHgt, self.column4, 1, 0.2, 1, 1, 1);
                            end
                            equippedLine = true
                        end
        
                        if item:getJobDelta() > 0 and (count > 1 or self.collapsed[v.name]) then
                            local scrollBarWid = self:isVScrollBarVisible() and 13 or 0
                            local displayWid = self.column4 - scrollBarWid
                            self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, displayWid * item:getJobDelta(), self.itemHgt, 0.2, 0.4, 1.0, 0.3);
                        end
                    -- print("trace:i");
        
                        local textDY = (self.itemHgt - self.fontHgt) / 2
        
                        --~ 				local redDetail = false;
                        local itemName = item:getName();
                        if count == 1 then
        
                            -- if we're dragging something and want to put it in a container wich is full
                            if doDragged and ISMouseDrag.dragging and #ISMouseDrag.dragging > 0 then
                                local red = false;
                                if red then
                                    if v.count > 2 then
                                        self:drawText(itemName.." ("..(v.count-1)..")", self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.0, 0.0, 1.0, self.font);
                                    else
                                        self:drawText(itemName, self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.0, 0.0, 1.0, self.font);
                                    end
                                else
                                    if v.count > 2 then
                                        self:drawText(itemName.." ("..(v.count-1)..")", self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                                    else
                                        self:drawText(itemName, self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                                    end
                                end
                            else
                                local clipX = math.max(0, self.column2+xoff)
                                local clipY = math.max(0, (y*self.itemHgt)+self.headerHgt+yoff+self:getYScroll())
                                local clipX2 = math.min(clipX + self.column3-self.column2, self.width)
                                local clipY2 = math.min(clipY + self.itemHgt, self.height)
                                if clipX < clipX2 and clipY < clipY2 then
                                self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
                                if v.count > 2 then
                                    self:drawText(itemName.." ("..(v.count-1)..")", self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                                else
                                    self:drawText(itemName, self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                                end
                                self:clearStencilRect()
                                self:repaintStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
                                end
                            end
                        end
                    -- print("trace:j");
        
                        --~ 				if self.mouseOverOption == y+1 and self.dragging and not self.parent:canPutIn(item) then
                        --~ 							self:drawText(item:getName(), self.column2+8+xoff, (y*18)+16+1+yoff, 0.7, 0.0, 0.0, 1.0);
                            --~ 						else
        
                        if item:getJobDelta() > 0  then
                            if  (count > 1 or self.collapsed[v.name]) then
                                if self.dragging == count then
                                    self:drawText(item:getJobType(), self.column3+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.0, 0.0, 1.0, self.font);
                                else
                                    self:drawText(item:getJobType(), self.column3+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                                end
                            end
        
                        else
                            if count == 1 then
                                if doDragged then
                                    -- Don't draw the category when dragging
                                elseif item:getDisplayCategory() then -- display the custom category set in items.txt
                                    self:drawText(getText("IGUI_ItemCat_" .. item:getDisplayCategory()), self.column3+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.6, 0.6, 0.8, 1.0, self.font);
                                else
                                    self:drawText(getText("IGUI_ItemCat_" .. item:getCategory()), self.column3+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.6, 0.6, 0.8, 1.0, self.font);
                                end
                            else
                                local redDetail = false;
                                self:drawItemDetails(item, y, xoff, yoff, redDetail);
                            end
        
                        end
                        if self.selected ~= nil and self.selected[y+1] ~= nil then
                            self:resumeStencil();
                        end
        
                    end
                    if count == 1 then
                        if alt == nil then alt = false; end
                        alt = not alt;
                    end
        
                    y = y + 1;
        
                    if count == 1 and self.collapsed ~= nil and v.name ~= nil and self.collapsed[v.name] then
                        if instanceof(item, "Food") then
                            -- Update all food items in a collapsed stack so they separate when freshness changes.
                            for k3,v3 in ipairs(v.items) do
                                v3:updateAge()
                            end
                        end
                        break
                    end
                    if count == ISInventoryPane.MAX_ITEMS_IN_STACK_TO_RENDER + 1 then
                        break
                    end
                    count = count + 1;
                -- print("trace:zz");
                end
            end
            self:setScrollHeight((y+1)*self.itemHgt);
            self:setScrollWidth(0);
        
            if self.draggingMarquis then
                local w = self:getMouseX() - self.draggingMarquisX;
                local h = self:getMouseY() - self.draggingMarquisY;
                self:drawRectBorder(self.draggingMarquisX, self.draggingMarquisY, w, h, 0.4, 0.9, 0.9, 1);
            end
        
        
            if not doDragged then
                self:drawRectStatic(1, 0, self.width-2, self.headerHgt, 1, 0, 0, 0);
            end
        else
            _ISInventoryPane_renderdetails(self,doDragged)
        end
    end
end)