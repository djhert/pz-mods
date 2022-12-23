------------------------------------------
-- SpiffUI Radials
---- Add tooltip to Radial
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our module
local spiff = SpiffUI:Register("radials")

local SpiffUIRadialRecipeTooltip = ISRecipeTooltip:derive("SpiffUIRadialRecipeTooltip")

function SpiffUIRadialRecipeTooltip:new()
    return ISRecipeTooltip.new(self)
end

-- Taken from the base game's ISInventoryPaneContextMenu.lua
---- CraftTooltip:layoutContents(x, y)
----- This fixes the lag spike by limiting the number of sources we parse
------ We also force-add our item if missing to ensure it shows :)
function SpiffUIRadialRecipeTooltip:layoutContents(x, y)
	if self.contents then
		return self.contentsWidth, self.contentsHeight
	end

	self:getContainers()
	self:getAvailableItemsType()
	
    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
    local IMAGE_SIZE = 20

	self.contents = {}
	local marginLeft = 20
	local marginTop = 10
	local marginBottom = 10
	local y1 = y + marginTop
	local lineHeight = math.max(FONT_HGT_SMALL, 20 + 2)
	local textDY = (lineHeight - FONT_HGT_SMALL) / 2
	local imageDY = (lineHeight - IMAGE_SIZE) / 2
	local singleSources = {}
	local multiSources = {}
	local allSources = {}

	for j=0,self.recipe:getSource():size()-1 do
		local source = self.recipe:getSource():get(j)
		if source:getItems():size() == 1 then
			table.insert(singleSources, source)
		else
			table.insert(multiSources, source)
		end
	end

	-- Display singleSources before multiSources
	for _,source in ipairs(singleSources) do
		table.insert(allSources, source)
	end

	for _,source in ipairs(multiSources) do
		table.insert(allSources, source)
	end

	local maxSingleSourceLabelWidth = 0
	for _,source in ipairs(singleSources) do
		local txt = self:getSingleSourceText(source)
		local width = getTextManager():MeasureStringX(UIFont.Small, txt)
		maxSingleSourceLabelWidth = math.max(maxSingleSourceLabelWidth, width)
	end

	for scount,source in ipairs(allSources) do
		local txt = ""
		local x1 = x + marginLeft
		if source:getItems():size() > 1 then
			if source:isDestroy() then
				txt = getText("IGUI_CraftUI_SourceDestroyOneOf")
			elseif source:isKeep() then
				txt = getText("IGUI_CraftUI_SourceKeepOneOf")
			else
				txt = getText("IGUI_CraftUI_SourceUseOneOf")
			end
			self:addText(x1, y1 + textDY, txt)
			y1 = y1 + lineHeight
		else
			txt = self:getSingleSourceText(source)
			self:addText(x1, y1 + textDY, txt)
			x1 = x1 + maxSingleSourceLabelWidth + 10
		end

		local itemDataList = {}

		local searching = {}

		-- Get 10 more items from our item's recipe
		---- This should cover all of the required items
		----- And give us some candy for the UI. :) 
		------ Why 10? The UI stops at 10 sooooooooo.......
		local loopLength = 10
		if source:getItems():size() < loopLength then
			loopLength = source:getItems():size()
		end

		-- on our first run
		---- The first iteration will be the item itself ("use one item", etc)
		if scount == 1 then
			local found = false
			-- We first need to check if our item is part of the 10
			for s=0,loopLength - 1  do
				found = (source:getItems():get(s) == self.item:getFullType())
			end
			-- if our item was not part of the 10 then we add it first
			if not found  then
				searching[self.item:getFullType()] = true
			end
		end

		-- Add our items
		for s=0,loopLength - 1  do
			searching[source:getItems():get(s)] = true
		end

		for fType,_ in pairs(searching) do
			local itemData = {}
			itemData.fullType = fType
			itemData.available = true
			local item = nil
			if itemData.fullType == "Water" then
				item = ISInventoryPaneContextMenu.getItemInstance("Base.WaterDrop")
			else
				if instanceof(self.recipe, "MovableRecipe") and (itemData.fullType == "Base."..self.recipe:getWorldSprite()) then
					item = ISInventoryPaneContextMenu.getItemInstance("Moveables.Moveable")
				else
					item = ISInventoryPaneContextMenu.getItemInstance(itemData.fullType)
				end
                --this reads the worldsprite so the generated item will have correct icon
                if instanceof(item, "Moveable") and instanceof(self.recipe, "MovableRecipe") then
                    item:ReadFromWorldSprite(self.recipe:getWorldSprite());
                end
			end
			itemData.texture = ""
			if item then
				itemData.texture = item:getTex():getName()
				if itemData.fullType == "Water" then
					if source:getCount() == 1 then
						itemData.name = getText("IGUI_CraftUI_CountOneUnit", getText("ContextMenu_WaterName"))
					else
						itemData.name = getText("IGUI_CraftUI_CountUnits", getText("ContextMenu_WaterName"), source:getCount())
					end
				elseif source:getItems():size() > 1 then -- no units
					itemData.name = item:getDisplayName()
				elseif not source:isDestroy() and item:IsDrainable() then
					if source:getCount() == 1 then
						itemData.name = getText("IGUI_CraftUI_CountOneUnit", item:getDisplayName())
					else
						itemData.name = getText("IGUI_CraftUI_CountUnits", item:getDisplayName(), source:getCount())
					end
				elseif not source:isDestroy() and source:getUse() > 0 then -- food
					if source:getUse() == 1 then
						itemData.name = getText("IGUI_CraftUI_CountOneUnit", item:getDisplayName())
					else
						itemData.name = getText("IGUI_CraftUI_CountUnits", item:getDisplayName(), source:getUse())
					end
				elseif source:getCount() > 1 then
					itemData.name = getText("IGUI_CraftUI_CountNumber", item:getDisplayName(), source:getCount())
				else
					itemData.name = item:getDisplayName()
				end
			else
				itemData.name = itemData.fullType
			end
			local countAvailable = self.typesAvailable[itemData.fullType] or 0
			if countAvailable < source:getCount() and itemData.fullType ~= self.item:getFullType() then
				itemData.available = false
				itemData.r = 0.54
				itemData.g = 0.54
				itemData.b = 0.54
			end
			table.insert(itemDataList, itemData)
		end

		-- Hack for "Dismantle Digital Watch" and similar recipes.
		-- Recipe sources include both left-hand and right-hand versions of the same item.
		-- We only want to display one of them.
		for j=1,#itemDataList do
			local item = itemDataList[j]
			for k=#itemDataList,j+1,-1 do
				local item2 = itemDataList[k]
				if self:isExtraClothingItemOf(item, item2) then
					table.remove(itemDataList, k)
				end
			end
		end

		for i,itemData in ipairs(itemDataList) do
			local x2 = x1
			if source:getItems():size() > 1 then
				x2 = x2 + 20
                if source:getCount() > 1 then
                    itemData.name = getText("IGUI_CraftUI_CountNumber", itemData.name, source:getCount())
                end
			end
			if itemData.texture ~= "" then
				self:addImage(x2, y1 + imageDY, itemData.texture)
				x2 = x2 + IMAGE_SIZE + 6
			end
			self:addText(x2, y1 + textDY, itemData.name, itemData.r, itemData.g, itemData.b)
			y1 = y1 + lineHeight

			if i == 10 and i < source:getItems():size() then
				self:addText(x2, y1 + textDY, getText("Tooltip_AndNMore", source:getItems():size() - i))
				y1 = y1 + lineHeight
				break
			end
		end
	end

	if self.recipe:getTooltip() then
		local x1 = x + marginLeft
		local tooltip = getText(self.recipe:getTooltip())
		self:addText(x1, y1 + 8, tooltip)
	end

	self.contentsX = x
	self.contentsY = y
	self.contentsWidth = 0
	self.contentsHeight = 0
	for _,v in ipairs(self.contents) do
		self.contentsWidth = math.max(self.contentsWidth, v.x + v.width - x)
		self.contentsHeight = math.max(self.contentsHeight, v.y + v.height + marginBottom - y)
	end
	return self.contentsWidth, self.contentsHeight
end

function ISRadialMenu:makeToolTip() 
    local player = getSpecificPlayer(self.playerNum)

    self.toolRender = ISToolTipInv:new()
    self.toolRender:initialise()
    self.toolRender:setCharacter(player)

    self.craftRender = SpiffUIRadialRecipeTooltip:new()
    self.craftRender:initialise()
    self.craftRender.character = player
	
	self.invRender = ISToolTip:new()
	self.invRender:initialise()

	if JoypadState.players[self.playerNum+1] then
		local x = getPlayerScreenLeft(self.playerNum) + 60
		local y = getPlayerScreenTop(self.playerNum) + 60
		self.invRender.followMouse = false
		self.invRender.desiredX = x
		self.invRender.desiredY = y

		self.toolRender.followMouse = false
		self.toolRender:setX(x)
		self.toolRender:setY(y)
		
		self.craftRender.followMouse = false
		self.craftRender.desiredX = x
		self.craftRender.desiredY = y
	end
end

function ISRadialMenu:getSliceTooltipJoyPad()
	if not self.joyfocus or not self.joyfocus.id then return nil end
	
	local sliceIndex = self.javaObject:getSliceIndexFromJoypad(self.joyfocus.id)
	if sliceIndex == -1 then return nil end

	local command = self:getSliceCommand(sliceIndex + 1)

	if command and command[2] and command[2].tooltip then     
        return command[2].tooltip
    end
	return nil
end

function ISRadialMenu:getSliceTooltipMouse(x, y)
    local sliceIndex = self.javaObject:getSliceIndexFromMouse(x, y)
	local command = self:getSliceCommand(sliceIndex + 1)
    
	if command and command[2] and command[2].tooltip then     
        return command[2].tooltip
    end
	return nil
end

function ISRadialMenu:getSliceText(sliceIndex)
	if sliceIndex < 1 or sliceIndex > #self.slices then return end
	return self.slices[sliceIndex].text
end

function ISRadialMenu:getSliceTexture(sliceIndex)                                                                                                                                                                                                                                                                                                                                                                                            
	if sliceIndex < 1 or sliceIndex > #self.slices then return end                                                                                                                                                                                                                                                                                                                                                                             
	return self.slices[sliceIndex].texture                                                                                                                                                                                                                                                                                                                                                                                                     
  end 

function ISRadialMenu:showTooltip(item)
	if item and spiff.config.showTooltips then
        if self.prev == item and (self.toolRender:getIsVisible() 
								or self.craftRender:getIsVisible() 
								or self.invRender:getIsVisible()) then return end
		
		if self.toolRender:getIsVisible() then
			self.toolRender:removeFromUIManager()
			self.toolRender:setVisible(false)
		end

		if self.craftRender:getIsVisible() then
			self.craftRender:removeFromUIManager()
			self.craftRender:setVisible(false)
		end

		if self.invRender:getIsVisible() then
			self.invRender:removeFromUIManager()
			self.invRender:setVisible(false)
		end

        self.prev = item

        if instanceof(item, "InventoryItem") then

            self.toolRender:setItem(item)

            self.toolRender:setVisible(true)
            self.toolRender:addToUIManager()
            self.toolRender:bringToTop()

        elseif item.isRecipe then
			-- We have to run the reset so the recipe is updated
			self.craftRender:reset()

			-- Reset annoyingly changes this stuff..
			if JoypadState.players[self.playerNum+1] then
				self.craftRender.followMouse = false
				self.craftRender.desiredX = getPlayerScreenLeft(self.playerNum) + 60
				self.craftRender.desiredY = getPlayerScreenTop(self.playerNum) + 60
			end
            
			self.craftRender.recipe = item.recipe
			self.craftRender.item = item.item
			self.craftRender:setName(item.recipe:getName())

			if item.item:getTexture() and item.item:getTexture():getName() ~= "Question_On" then
				self.craftRender:setTexture(item.item:getTexture():getName())
			end
			
            self.craftRender:setVisible(true)
            self.craftRender:addToUIManager()
            self.craftRender:bringToTop()

		elseif item.isFix then

			self.invRender:setName(item.name)
			self.invRender.texture = item.texture
			self.invRender.description = item.description

			self.invRender:setVisible(true)
            self.invRender:addToUIManager()
            self.invRender:bringToTop()

        end
    else
        if self.toolRender and self.toolRender:getIsVisible() then
            self.toolRender:removeFromUIManager()
            self.toolRender:setVisible(false)
        end
        if self.craftRender and self.craftRender:getIsVisible() then
			self.craftRender:removeFromUIManager()
			self.craftRender:setVisible(false)
        end
		if self.invRender and self.invRender:getIsVisible() then
			self.invRender:removeFromUIManager()
			self.invRender:setVisible(false)
		end
    end
end

-- Derived from ISPanelJoypad
function ISRadialMenu:onMouseMove(dx, dy)
    if self.playerNum ~= 0 then return end
    ISPanelJoypad.onMouseMove(self, dx, dy)

    local x = self:getMouseX()
	local y = self:getMouseY()

    self:showTooltip(self:getSliceTooltipMouse(x, y))
end

-- Derived from ISPanelJoypad
function ISRadialMenu:onMouseMoveOutside(dx, dy)
    if self.playerNum ~= 0 then return end
    ISPanelJoypad.onMouseMoveOutside(self, dx, dy)

	if self.toolRender and self.toolRender:getIsVisible() then
		self.toolRender:removeFromUIManager()
		self.toolRender:setVisible(false)
	end
	if self.craftRender and self.craftRender:getIsVisible() then
		self.craftRender:removeFromUIManager()
		self.craftRender:setVisible(false)
	end
	if self.invRender and self.invRender:getIsVisible() then
		self.invRender:removeFromUIManager()
		self.invRender:setVisible(false)
	end
end

local _ISRadialMenu_undisplay = ISRadialMenu.undisplay
function ISRadialMenu:undisplay()
	_ISRadialMenu_undisplay(self)

	if self.toolRender and self.toolRender:getIsVisible() then
		self.toolRender:removeFromUIManager()
		self.toolRender:setVisible(false)
	end
	if self.craftRender and self.craftRender:getIsVisible() then
		self.craftRender:removeFromUIManager()
		self.craftRender:setVisible(false)
	end
	if self.invRender and self.invRender:getIsVisible() then
		self.invRender:removeFromUIManager()
		self.invRender:setVisible(false)
	end
	if self.activeMenu then 
		self.activeMenu:undisplay()
		self.activeMenu = nil
	end
	self.clock = nil
end

local _ISRadialMenu_addSlice = ISRadialMenu.addSlice
function ISRadialMenu:addSlice(text, texture, command, arg1, arg2, arg3, arg4, arg5, arg6)
	local slice = {}
	slice.text = text
	slice.texture = texture
	slice.command = { command, arg1, arg2, arg3, arg4, arg5, arg6 }
	table.insert(self.slices, slice)
	-- we don't actually wan't to pass the string in here anymore.
	if self.javaObject then
		self.javaObject:addSlice(nil, texture)
	end
end

function ISRadialMenu:setRadialText(text)
	self.radText = text
end

function ISRadialMenu:setRadialImage(img)
	self.radImg = img
end

function ISRadialMenu:setImgChange(state)
	self.radImgChange = state
end

function ISRadialMenu:getClock()
	return self.clock
end

function ISRadialMenu:setClock(clock, clockSpiff)
	self.clock = clock
end

local SUIRadialMenuOverlay = require("SUI/SUI_RadialMenuOverlay")

local _ISRadialMenu_instantiate = ISRadialMenu.instantiate
function ISRadialMenu:instantiate()
	_ISRadialMenu_instantiate(self)
	if not self.spiff then
		self.spiff = SUIRadialMenuOverlay:new(self)
	end
end

-- Apparently, I am unable to add a child to the RadialMenu.  I think its something to do with it being part Java object?
---- So, instead here is a little hack to bring that parent/child relationship
function ISRadialMenu:addToUIManager()
	ISUIElement.addToUIManager(self)
	if self.spiff then
		self.spiff:display()
	end
end

function ISRadialMenu:removeFromUIManager()
	ISUIElement.removeFromUIManager(self)

	self.radText = nil
	self.radImg = nil
	self.radImgChange = true

	if self.spiff then
		self.spiff:undisplay()
	end
end

local _ISRadialMenu_new = ISRadialMenu.new
function ISRadialMenu:new(...)
	local o = _ISRadialMenu_new(self, ...)
	o:makeToolTip()

	o.radText = nil
	o.radImg = nil
	o.radImgChange = true

	return o
end