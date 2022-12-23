------------------------------------------
-- Fancy Handwork Detach Hotbar Action
---
------------------------------------------

local _ISDetachItemHotbar_start = ISDetachItemHotbar.start
function ISDetachItemHotbar:start()
    -- Run the base, then override
    _ISDetachItemHotbar_start(self)

    self.mdata = {}
	if isClient() then
		local md = ModData.getOrCreate("animapi")
		if not md[self.character:getOnlineID()] then
			md[self.character:getOnlineID()] = {}
		end
		self.mdata = md[self.character:getOnlineID()]
	end

    if self.item == self.character:getPrimaryHandItem() then
        self.character:clearVariable("FHAnimHand")
        self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())
        self.mdata["FHAnimHand"] = nil
    elseif self.item == self.character:getSecondaryHandItem() then
        self.character:setVariable("FHAnimHand", "left")
        self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
        self.mdata["FHAnimHand"] = "left"
    else
        if ZombRand(3) == 1 then
            self.character:setVariable("FHAnimHand", "left")
            self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
            self.mdata["FHAnimHand"] = "left"
        else
            self.character:clearVariable("FHAnimHand")
            self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())
            self.mdata["FHAnimHand"] = nil
        end
    end

    local hotbar = getPlayerHotbar(self.character:getPlayerNum())
    hotbar.chr:removeAttachedItem(self.item)

    if isClient() then
		ModData.transmit("animapi")
	end
end

local _ISDetachItemHotbar_animEvent = ISDetachItemHotbar.animEvent
function ISDetachItemHotbar:animEvent(event, parameter)
    -- Run the base, then override
    _ISDetachItemHotbar_animEvent(self, event, parameter)
    -- Fix the models
    if event == 'detachConnect' then
        -- Fix updating the inventory
        self.character:getInventory():setDrawDirty(true)
        getPlayerData(self.character:getPlayerNum()).playerInventory:refreshBackpacks()
        --self.character:getInventory():refreshBackpacks()

        if self.character:getPrimaryHandItem() == self.character:getSecondaryHandItem() then -- special case if 2handed
            if self.animHand == "left" then
                self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
            else
                self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem()) 
            end
        else
            if self.animHand == "left" then
                self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
            else
                self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem()) 
            end
        end
    end

    self.character:clearVariable("FHAnimHand")
    self.mdata["FHAnimHand"] = nil
    if isClient() then
        ModData.transmit("animapi")
    end
end