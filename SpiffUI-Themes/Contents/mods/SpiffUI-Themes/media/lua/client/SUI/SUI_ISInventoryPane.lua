-- Add module
SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISInventoryPane_renderdetails = ISInventoryPane.renderdetails
function ISInventoryPane:renderdetails2(doDragged)
    if not spiff.config.enabled then
        _ISInventoryPane_renderdetails(self, doDragged)
        return
    end

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

    local catW = (self.column2/5)
    local xoff2 = (catW/2)
    

    -- First set the background color
    if not doDragged then
		-- background of item icon
        self:drawRectStatic(0, 0, self.column2, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
        self:drawRectStatic(0, 0, catW, self.height, self.obackgroundColor.a, self.obackgroundColor.r, self.obackgroundColor.g, self.obackgroundColor.b);
        --self:drawRectBorder(0, 0, self.column2, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    end

    local y = 0;
    local alt = false;
    if self.itemslist == nil then
        self:refreshContainer();
    end
    local MOUSEX = self:getMouseX()
    local MOUSEY = self:getMouseY()
    local YSCROLL = self:getYScroll()
    local HEIGHT = self:getHeight()
    local equippedLine = false
    local all3D = true;

    local yoff = 0

    local idivX = (self.column4/4) - (self.column4/8)
    local idivW = idivX + (self.column4/2)
--    self.inventoryPage.render3DItems = {};
    -- Go through all the stacks of items.
    for k, v in ipairs(self.itemslist) do
        local count = 1;
        -- Go through each item in stack..
        for k2, v2 in ipairs(v.items) do
           -- --print("trace:a");
            local item = v2;
            local doIt = true;
            local xoff = 0;
            yoff = 0;
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
           -- --print("trace:b");
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
           -- --print("trace:c");
            if doIt == true then
               -- --print("trace:cc");
        --        --print(count);
                if count == 1 then
					-- rect over the whole item line
                    --self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth(), 1, 0.3, 0.0, 0.0, 0.8);
                end
               -- --print("trace:d");

                -- do controller selection.
                if self.joyselection ~= nil and self.doController then
--                    if self.joyselection < 0 then self.joyselection = (#self.itemslist) - 1; end
--                    if self.joyselection >= #self.itemslist then self.joyselection = 0; end
                    if self.joyselection == y then
                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.2, 0.2, 1.0, 1.0);
                    end
                end
               -- --print("trace:e");
                -- only do icon if header or dragging sub items without header.
                local tex = item:getTex();
                if tex ~= nil then
					local texDY = 1
					local texWH = math.min(self.itemHgt-2,32)
					local auxDXY = math.ceil(20 * self.texScale)
                    if count == 1  then
						self:drawTextureScaledAspect(tex, 10+xoff+xoff2, (y*self.itemHgt)+self.headerHgt+texDY+yoff, texWH, texWH, 1, item:getR(), item:getG(), item:getB());
						if player:isEquipped(item) then
							self:drawTexture(self.equippedItemIcon, (10+auxDXY+xoff+xoff2), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
						end
						if not self.hotbar then
							self.hotbar = getPlayerHotbar(self.player);
						end
						if not player:isEquipped(item) and self.hotbar and self.hotbar:isInHotbar(item) then
							self:drawTexture(self.equippedInHotbar, (10+auxDXY+xoff+xoff2), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
						end
                        if item:isBroken() then
                            self:drawTexture(self.brokenItemIcon, (10+auxDXY+xoff+xoff2), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if instanceof(item, "Food") and item:isFrozen() then
                            self:drawTexture(self.frozenItemIcon, (10+auxDXY+xoff+xoff2), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if item:isTaintedWater() or player:isKnownPoison(item) then
                            self:drawTexture(self.poisonIcon, (10+auxDXY+xoff+xoff2), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if item:isFavorite() then
                            self:drawTexture(self.favoriteStar, (13+auxDXY+xoff+xoff2), (y*self.itemHgt)+self.headerHgt-1+yoff, 1, 1, 1, 1);
                        end

                        if not doDragged then
                            -- local catCol = item:getDisplayCategory() or item:getCategory()
                            -- if self.catColors[catCol] then
                            --     self:drawRect(0, (y*self.itemHgt)+self.headerHgt, catW, texWH+2, self.catColors[catCol].a, self.catColors[catCol].r, self.catColors[catCol].g, self.catColors[catCol].b);
                            --     --self:drawRectBorder(0, (y*self.itemHgt)+self.headerHgt, (self.column2/5), texWH+2, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
                            -- end
                            if not self.collapsed[v.name] then
                                self:drawTexture( self.treeexpicon, 2, (y*self.itemHgt)+self.headerHgt+5+yoff, 1, 1, 1, 1);
                            else
                                self:drawTexture( self.treecolicon, 2, (y*self.itemHgt)+self.headerHgt+5+yoff, 1, 1, 1, 1);
                            end
                        end
                    elseif v.count > 2 or (doDragged and count > 1 and self.selected[(y+1) - (count-1)] == nil) then
                        --self:drawRect(0, (y*self.itemHgt)+self.headerHgt, self.column2-1, texWH, self.borderColor.a, 0, 1, 0);

                        self:drawTextureScaledAspect(tex, 10+16+xoff, (y*self.itemHgt)+self.headerHgt+texDY+yoff, texWH, texWH, 0.3, item:getR(), item:getG(), item:getB());
						if player:isEquipped(item) then
							self:drawTexture(self.equippedItemIcon, (10+auxDXY+16+xoff+xoff2), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
                        end
                        if item:isBroken() then
                            self:drawTexture(self.brokenItemIcon, (10+auxDXY+16+xoff+xoff2), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if instanceof(item, "Food") and item:isFrozen() then
                            self:drawTexture(self.frozenItemIcon, (10+auxDXY+16+xoff+xoff2), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if item:isFavorite() then
                            self:drawTexture(self.favoriteStar, (13+auxDXY+16+xoff+xoff2), (y*self.itemHgt)+self.headerHgt-1+yoff, 1, 1, 1, 1);
                        end
                    end

                    -- -- Put a smaller category color here too
                    -- if v.count > 2 and not doDragged then
                    --     local catCol = item:getDisplayCategory() or item:getCategory()
                    --     if self.catColors[catCol] then
                    --         self:drawRect(0, (y*self.itemHgt)+self.headerHgt, xoff2, texWH+2, self.catColors[catCol].a, self.catColors[catCol].r, self.catColors[catCol].g, self.catColors[catCol].b);
                    --         --self:drawRectBorder(0, (y*self.itemHgt)+self.headerHgt, (self.column2/5), texWH+2, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
                    --     end
                    -- end

                end

               -- --print("trace:g");
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
                            if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() ~= 1) or item:getItemHeat() ~= 1) then
                                if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() > 1) or item:getItemHeat() > 1) then
                                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.15, math.abs(item:getInvHeat()), 0.0, 0.0)
                                else
                                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.15, 0.0, 0.0, math.abs(item:getInvHeat()))
                                end
                            end

                        end
                    else
                        if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() ~= 1) or item:getItemHeat() ~= 1) then
                            if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() > 1) or item:getItemHeat() > 1) then
								self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.2, math.abs(item:getInvHeat()), 0.0, 0.0);
							else
								self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.2, 0.0, 0.0, math.abs(item:getInvHeat()));
							end
						else
							self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.4, 0.0, 0.0, 0.0);
						end
                    end
                end
               -- --print("trace:h");

                -- divider between equipped and unequipped items
                if k > 1 then 
                    if v.equipped then
                        if not doDragged and not equippedLine and y > 0 then
                            self:drawTextureScaled(self.lineTex, idivX, ((y+1)*self.itemHgt)+self.headerHgt-2-self.itemHgt, idivW, 2, self.oborderColor.a, self.oborderColor.r, self.oborderColor.g, self.oborderColor.b)
                            --self:drawRect(1, ((y+1)*self.itemHgt)+self.headerHgt-1-self.itemHgt, self.column4, 2, 0.2, 1, 1, 1);
                        else 
                            self:drawTextureScaled(self.lineTex, idivX, ((y+1)*self.itemHgt)+self.headerHgt-self.itemHgt, idivW, 1, self.sborderColor.a, self.sborderColor.r, self.sborderColor.g, self.sborderColor.b)
                        end
                        equippedLine = true
                    else
                        self:drawTextureScaled(self.lineTex, idivX, ((y+1)*self.itemHgt)+self.headerHgt-self.itemHgt, idivW, 1, self.sborderColor.a, self.sborderColor.r, self.sborderColor.g, self.sborderColor.b)
                    end
                end

                if item:getJobDelta() > 0 and (count > 1 or self.collapsed[v.name]) then
                    local scrollBarWid = self:isVScrollBarVisible() and 13 or 0
                    local displayWid = self.column4 - scrollBarWid - catW
                    self:drawRect(1+xoff+catW, (y*self.itemHgt)+self.headerHgt+yoff, displayWid * item:getJobDelta(), self.itemHgt, 0.2, 0.4, 1.0, 0.3);
                end
               -- --print("trace:i");

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
               -- --print("trace:j");

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
            if count == 51 then
                break
            end
            count = count + 1;
           -- --print("trace:zz");
        end
	end

    self:setScrollHeight(((y+1)*self.itemHgt)-self.parent:titleBarHeight()+2);
	self:setScrollWidth(0);

	-- if self.draggingMarquis then
	-- 	local w = self:getMouseX() - self.draggingMarquisX;
	-- 	local h = self:getMouseY() - self.draggingMarquisY;
	-- 	self:drawRectBorder(self.draggingMarquisX, self.draggingMarquisY, w, h, 0.4, 0.9, 0.9, 1);
    -- end


    if not doDragged then
		self:drawRectStatic(1, 0, self.width-2, self.headerHgt, self.obackgroundColor.a, self.obackgroundColor.r, self.obackgroundColor.g, self.obackgroundColor.b);
    end
end



local _ISInventoryPane_createChildren = ISInventoryPane.createChildren
function ISInventoryPane:createChildren()
    _ISInventoryPane_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    -- self.catColors = {
    --     -- 546E7A
    --     ["Furniture"] = {r=0.32, g=0.43, b=0.47, a=0.4},
    --     ["Household"] = {r=0.32, g=0.43, b=0.47, a=0.4},
    --     ["Junk"] = {r=0.32, g=0.43, b=0.47, a=0.4},
    --     ["Item"] = {r=0.32, g=0.43, b=0.47, a=0.4},
    --     -- 757575
    --     ["Security"] = {r=0.45, g=0.45, b=0.45, a=0.4},
    --     -- 7B1FA2
    --     ["Appearance"] = {r=0.48, g=0.12, b=0.63, a=0.4},
    --     ["Accessory"] = {r=0.48, g=0.12, b=0.63, a=0.4},
    --     ["MakeUp"] = {r=0.48, g=0.12, b=0.63, a=0.4},
    --     ["Clothing"] = {r=0.48, g=0.12, b=0.63, a=0.4},
    --     ["Raccoon"] = {r=0.48, g=0.12, b=0.63, a=0.4},
    --     -- 512DA8
    --     ["Bag"] = {r=0.31, g=0.17, b=0.66, a=0.4},
    --     ["Container"] = {r=0.31, g=0.17, b=0.66, a=0.4},
    --     ["WaterContainer"] = {r=0.31, g=0.17, b=0.66, a=0.4},
    --     -- FBC02D
    --     ["Communications"] = {r=0.98, g=0.75, b=0.17, a=0.4},
    --     ["Devices"] = {r=0.98, g=0.75, b=0.17, a=0.4},
    --     ["LightSource"] = {r=0.98, g=0.75, b=0.17, a=0.4},
    --     -- D32F2F
    --     ["Bandage"] = {r=0.82, g=0.18, b=0.18, a=0.4},
    --     ["FirstAid"] = {r=0.82, g=0.18, b=0.18, a=0.4},
    --     ["Wound"] = {r=0.82, g=0.18, b=0.18, a=0.4},
    --     ["ZedDmg"] = {r=0.82, g=0.18, b=0.18, a=0.4},
    --     ["Corpse"] = {r=0.82, g=0.18, b=0.18, a=0.4},
    --     -- 0288D1
    --     ["Food"] = {r=0.01, g=0.53, b=0.82, a=0.4},
    --     ["Cooking"] = {r=0.01, g=0.53, b=0.82, a=0.4},
    --     ["Water"] = {r=0.01, g=0.53, b=0.82, a=0.4},
    --     -- 00796B
    --     ["Camping"] = {r=0.0, g=0.47, b=0.42, a=0.4},
    --     ["Fishing"] = {r=0.0, g=0.47, b=0.42, a=0.4},
    --     ["Trapping"] = {r=0.0, g=0.47, b=0.42, a=0.4},
    --     ["Gardening"] = {r=0.0, g=0.47, b=0.42, a=0.4},
    --     -- 455A64
    --     ["Ammo"] = {r=0.27, g=0.35, b=0.39, a=0.4},
    --     ["Tool"] = {r=0.27, g=0.35, b=0.39, a=0.4},
    --     ["ToolWeapon"] = {r=0.27, g=0.35, b=0.39, a=0.4},
    --     ["Sports"] = {r=0.27, g=0.35, b=0.39, a=0.4},
    --     ["Weapon"] = {r=0.27, g=0.35, b=0.39, a=0.4},
    --     ["WeaponCrafted"] = {r=0.27, g=0.35, b=0.39, a=0.4},
    --     ["Instrument"] = {r=0.27, g=0.35, b=0.39, a=0.4},
    --     -- 388E3C
    --     ["Cartography"] = {r=0.22, g=0.55, b=0.23, a=0.4},
    --     ["SkillBook"] = {r=0.22, g=0.55, b=0.23, a=0.4},
    --     ["Literature"] = {r=0.22, g=0.55, b=0.23, a=0.4},
    --     -- FFA000
    --     ["Electronics"] = {r=1.0, g=0.62, b=0, a=0.4},
    --     ["Paint"] = {r=1.0, g=0.62, b=0, a=0.4},
    --     ["Material"] = {r=1.0, g=0.62, b=0, a=0.4},
    --     ["WeaponPart"] = {r=1.0, g=0.62, b=0, a=0.4},
    --     ["VehicleMaintenance"] = {r=1.0, g=0.62, b=0, a=0.4},
    -- }

    local theme = spiff.GetTheme()
    
    --o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    --o.backgroundColor = {r=0, g=0, b=0, a=0.5};
    
    self.hborderColor = spiff.GetColor(theme.Border.Header)
    self.borderColor  = spiff.GetColor(theme.Border.Primary)
    self.sborderColor = spiff.GetColor(theme.Border.Secondary)
    self.oborderColor = spiff.GetColor(theme.Border.Option)

    self.hbackgroundColor = spiff.GetColor(theme.Background.Header)
    self.backgroundColor  = spiff.GetColor(theme.Background.Primary)
    self.sbackgroundColor = spiff.GetColor(theme.Background.Secondary)
    self.obackgroundColor = spiff.GetColor(theme.Background.Option)

    self.htextColor = spiff.GetColor(theme.Text.Header)
    self.textColor  = spiff.GetColor(theme.Text.Primary)
    self.stextColor = spiff.GetColor(theme.Text.Secondary)

    -- Reset to the theme
    ---- Since we're not doing everything anymore, gotta do it all here
    self.nameHeader.backgroundColor = spiff.GetColor(theme.Background.Option)
    self.nameHeader.backgroundColorMouseOver = spiff.GetColorMod(theme.Background.Option, 2)
    self.nameHeader.backgroundColorPressed = spiff.GetColorMod(theme.Background.Option, 0.5)
    self.nameHeader.borderColor  = spiff.GetColor(theme.Border.Option)
    self.nameHeader.textColor  = spiff.GetColor(theme.Text.Option)

    self.typeHeader.backgroundColor = spiff.GetColor(theme.Background.Option)
    self.typeHeader.backgroundColorMouseOver = spiff.GetColorMod(theme.Background.Option, 2)
    self.typeHeader.backgroundColorPressed = spiff.GetColorMod(theme.Background.Option, 0.5)
    self.typeHeader.borderColor  = spiff.GetColor(theme.Border.Option)
    self.typeHeader.textColor  = spiff.GetColor(theme.Text.Option)

    self.contextButton1.backgroundColor = spiff.GetColor(theme.Background.Option)
    self.contextButton1.backgroundColorMouseOver = spiff.GetColorMod(theme.Background.Option, 2)
    self.contextButton1.backgroundColorPressed = spiff.GetColorMod(theme.Background.Option, 0.5)
    self.contextButton1.borderColor  = spiff.GetColor(theme.Border.Option)
    self.contextButton1.textColor  = spiff.GetColor(theme.Text.Option)

    self.contextButton2.backgroundColor = spiff.GetColor(theme.Background.Option)
    self.contextButton2.backgroundColorMouseOver = spiff.GetColorMod(theme.Background.Option, 2)
    self.contextButton2.backgroundColorPressed = spiff.GetColorMod(theme.Background.Option, 0.5)
    self.contextButton2.borderColor  = spiff.GetColor(theme.Border.Option)
    self.contextButton2.textColor  = spiff.GetColor(theme.Text.Option)

    self.contextButton3.backgroundColor = spiff.GetColor(theme.Background.Option)
    self.contextButton3.backgroundColorMouseOver = spiff.GetColorMod(theme.Background.Option, 2)
    self.contextButton3.backgroundColorPressed = spiff.GetColorMod(theme.Background.Option, 0.5)
    self.contextButton3.borderColor  = spiff.GetColor(theme.Border.Option)
    self.contextButton3.textColor  = spiff.GetColor(theme.Text.Option)

    -- ScrollBar
    self.vscroll.backgroundColor = spiff.GetColor(theme.Background.Option)
    self.vscroll.borderColor = spiff.GetColor(theme.Background.Option)

    -- Fix this spacing and height, its not obvious when its all black :)
    self.expandAll:setHeight(15)
    self.collapseAll:setHeight(15)
    self.filterMenu:setHeight(15)

    self.expandAll:setX(self.expandAll:getX() + 2)
    self.collapseAll:setX(self.collapseAll:getX() + 2)
    self.filterMenu:setX(self.filterMenu:getX() + 2)

    -- self.expandAll.textureColor = spiff.GetColor(theme.Background.Primary)
    -- self.collapseAll.textureColor = spiff.GetColor(theme.Background.Primary)
    -- self.filterMenu.textureColor = spiff.GetColor(theme.Background.Primary)

    self.lineTex = getTexture("media/UI/line.png")
end