------------------------------------------
-- Fancy Handwork Detach Hotbar Action
---
------------------------------------------

local _ISDetachItemHotbar_start = ISDetachItemHotbar.start
function ISDetachItemHotbar:start()
    -- Run the base, then override
    _ISDetachItemHotbar_start(self)
    self.FHIgnore = true
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

    local hotbar = getPlayerHotbar(self.character:getPlayerNum())
    hotbar.chr:removeAttachedItem(self.item)

end

local _ISDetachItemHotbar_animEvent = ISDetachItemHotbar.animEvent
function ISDetachItemHotbar:animEvent(event, parameter)
    -- Run the base, then override
    _ISDetachItemHotbar_animEvent(self, event, parameter)
    -- Fix the models
    if event == 'detachConnect' then
        -- Fix updating the inventory
        --self.character:getInventory():setDrawDirty(true)
        getPlayerData(self.character:getPlayerNum()).playerInventory:refreshBackpacks()

        if self.animHand == "left" then
            self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
        else
            self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem()) 
        end
    end
end