------------------------------------------
-- Fancy Handwork Swap Action
---
-- Mostly based on code from:
--- lua\client\TimedActions\ISUnequipAction.lua
--- lua\client\TimedActions\ISEquipWeaponAction.lua
------------------------------------------
require "TimedActions/ISBaseTimedAction"

FHSwapHandsAction = ISBaseTimedAction:derive("FHSwapHandsAction")

function FHSwapHandsAction:isValid()
	return ((self.character:getPrimaryHandItem() or self.character:getSecondaryHandItem()) ~= nil)
end

function FHSwapHandsAction:update()
    if self.itemL then
	    self.itemL:setJobDelta(self:getJobDelta())
    end
    if self.itemR then
	    self.itemR:setJobDelta(self:getJobDelta())
    end
end

function FHSwapHandsAction:start()
    local sound = nil
	self.FHIgnore = true
    if self.itemL then
	    self.itemL:setJobType(getText("ContextMenu_Equip_Primary") .. " " .. self.itemL:getName())
	    self.itemL:setJobDelta(0.0)
    end
    if self.itemR then
        self.itemR:setJobType(getText("ContextMenu_Equip_Secondary") .. " " .. self.itemR:getName())
	    self.itemR:setJobDelta(0.0)
    end
	self:setActionAnim("EquipItem")
    self:setOverrideHandModels(self.itemR, self.itemL)

end

function FHSwapHandsAction:stop()
    if self.itemL then
        self.itemL:setJobDelta(0.0)
    end
    if self.itemR then
        self.itemR:setJobDelta(0.0)
    end
    ISBaseTimedAction.stop(self);
end

function FHSwapHandsAction:perform()
    if self.itemL then
        self.itemL:getContainer():setDrawDirty(true)
        self.itemL:setJobDelta(0.0)
    end
    if self.itemR then
        self.itemR:getContainer():setDrawDirty(true)
        self.itemR:setJobDelta(0.0)
    end

	self.character:setPrimaryHandItem(self.itemL)
	self.character:setSecondaryHandItem(self.itemR)

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function FHSwapHandsAction:new(character, itemR, itemL, time)
	local o = ISBaseTimedAction.new(self, character)
	o.itemR = itemR
	o.itemL = itemL

	o.stopOnAim = false
	o.stopOnWalk = false
	o.stopOnRun = false
	o.maxTime = time
	o.ignoreHandsWounds = FancyHands.config.injuries

	o.useProgressBar = false

	o.animSpeed = 1.0
	return o;
end
