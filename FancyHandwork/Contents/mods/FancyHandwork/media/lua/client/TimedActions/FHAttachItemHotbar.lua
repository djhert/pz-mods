------------------------------------------
-- Fancy Handwork Attach Hotbar Action
---
------------------------------------------
local _ISAttachItemHotbar_start = ISAttachItemHotbar.start
function ISAttachItemHotbar:start()
    _ISAttachItemHotbar_start(self)

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
        self.mdata["FHAnimHand"] = nil
        self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())
    elseif self.item == self.character:getSecondaryHandItem() then
        self.character:setVariable("FHAnimHand", "left")
        self.mdata["FHAnimHand"] = "left"
        self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
    else
        if ZombRand(3) == 1 then 
            self.character:setVariable("FHAnimHand", "left")
            self.mdata["FHAnimHand"] = "left"
            self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
        else
            self.character:clearVariable("FHAnimHand")
            self.mdata["FHAnimHand"] = nil
            self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())
        end
    end

    if isClient() then
		ModData.transmit("animapi")
	end
end

local _ISAttachItemHotbar_animEvent = ISAttachItemHotbar.animEvent
function ISAttachItemHotbar:animEvent(event, parameter)
    _ISAttachItemHotbar_animEvent(self, event, parameter)
    if event == 'attachConnect' then
        self.character:clearVariable("FHAnimHand")
        self.mdata["FHAnimHand"] = nil
        if isClient() then
            ModData.transmit("animapi")
        end
    end
end