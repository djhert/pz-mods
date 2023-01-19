------------------------------------------
-- Fancy Handwork Unequip Action
---
------------------------------------------
local _ISUnequipAction_start = ISUnequipAction.start
function ISUnequipAction:start()
    -- Run the base, then override
	_ISUnequipAction_start(self)
	self.FHIgnore = true
    -- Check for second hand item that's not 2-handed, use left hand
    -- else use right
    if self.item == self.character:getSecondaryHandItem() and self.character:getPrimaryHandItem() ~= self.character:getSecondaryHandItem() then
		self:setAnimVariable("FHAnimHand", "left")

		if self.fromHotbar then
			self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
		end
    else
		if self.fromHotbar and self.character:getPrimaryHandItem() ~= self.character:getSecondaryHandItem() then
			self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())
		end
    end
end