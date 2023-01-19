------------------------------------------
-- Fancy Handwork Attach Hotbar Action
---
------------------------------------------
local _ISAttachItemHotbar_start = ISAttachItemHotbar.start
function ISAttachItemHotbar:start()
    _ISAttachItemHotbar_start(self)
    self.FHIgnore = true
    self:setActionAnim("AttachItem")
    if self.item == self.character:getPrimaryHandItem() then
        self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())
    elseif self.item == self.character:getSecondaryHandItem() then
        self:setAnimVariable("FHAnimHand", "left")
        self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
    else
        if ZombRand(3) == 1 then 
            self:setAnimVariable("FHAnimHand", "left")
            self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
        else
            self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())
        end
    end
end