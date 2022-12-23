------------------------------------------
-- Fancy Handwork Unequip Action
---
------------------------------------------
local _ISUnequipAction_start = ISUnequipAction.start
function ISUnequipAction:start()
    -- Run the base, then override
	_ISUnequipAction_start(self)

    self.mdata = {}
	if isClient() then
		local md = ModData.getOrCreate("animapi")
		if not md[self.character:getOnlineID()] then
			md[self.character:getOnlineID()] = {}
		end
		self.mdata = md[self.character:getOnlineID()]
	end

    -- Check for second hand item that's not 2-handed, use left hand
    -- else use right
    if self.item == self.character:getSecondaryHandItem() and self.character:getPrimaryHandItem() ~= self.character:getSecondaryHandItem() then
        self.character:setVariable("FHAnimHand", "left")
        self.mdata["FHAnimHand"] = "left"

		if self.fromHotbar then
			self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
		end
        self.character:clearVariable("LeftHandMask")
        self.mdata["LeftHandMask"] = "nil"
		self.character:getModData().FancyHandwork["LeftHandMask"] = nil
    else
        self.character:clearVariable("FHAnimHand")
        self.mdata["FHAnimHand"] = "nil"
		if self.fromHotbar and self.character:getPrimaryHandItem() ~= self.character:getSecondaryHandItem() then
			self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())
		end
    end

    if isClient() then
		ModData.transmit("animapi")
	end
end