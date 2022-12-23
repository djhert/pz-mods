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
	if self.character:getPrimaryHandItem() or self.character:getSecondaryHandItem() then
		return true
	else
		return false
	end
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
    if self.itemL then
	    self.itemL:setJobType(getText("ContextMenu_Equip_Primary") .. " " .. self.itemL:getName())
	    self.itemL:setJobDelta(0.0)
        sound = self.itemL:getUnequipSound()
    end
    if self.itemR then
        self.itemR:setJobType(getText("ContextMenu_Equip_Secondary") .. " " .. self.itemR:getName())
	    self.itemR:setJobDelta(0.0)
        if not sound then
            sound = self.itemR:getUnequipSound()
        end
    end
	self:setActionAnim("EquipItem")
    self:setOverrideHandModels(self.itemR, self.itemL)

	if sound then
		self.sound = self.character:getEmitter():playSound(sound)
	end
end

function FHSwapHandsAction:stop()
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
	end
    if self.itemL then
        self.itemL:setJobDelta(0.0)
    end
    if self.itemR then
        self.itemR:setJobDelta(0.0)
    end
    ISBaseTimedAction.stop(self);
end

function FHSwapHandsAction:perform()
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
	end

    if self.itemL then
        self.itemL:getContainer():setDrawDirty(true)
        self.itemL:setJobDelta(0.0)
    end
    if self.itemR then
        self.itemR:getContainer():setDrawDirty(true)
        self.itemR:setJobDelta(0.0)
    end

	self.character:setPrimaryHandItem(nil)
	self.character:setSecondaryHandItem(nil)

	self.mdata = {}
	if isClient() then
		local md = ModData.getOrCreate("animapi")
		if not md[self.character:getOnlineID()] then
			md[self.character:getOnlineID()] = {}
		end
		self.mdata = md[self.character:getOnlineID()]
	end

	if self.itemL then
		self.character:setPrimaryHandItem(self.itemL)
	end

	if self.itemR and FancyHands.config.applyRotationL then
		self.character:setSecondaryHandItem(self.itemR)
		if self.itemR:isRanged() then
			self.character:setVariable("LeftHandMask", "holdinghgunleft")
			self.mdata["LeftHandMask"] = "holdinghgunleft"
			self.character:getModData().FancyHandwork["LeftHandMask"] = "holdinghgunleft"
		else
			self.character:setVariable("LeftHandMask", "holdingitemleft")
			self.mdata["LeftHandMask"] = "holdingitemleft"
			self.character:getModData().FancyHandwork["LeftHandMask"] = "holdingitemleft"
		end
	else
		self.mdata["LeftHandMask"] = "nil"
		self.character:getModData().FancyHandwork["LeftHandMask"] = nil
	end

	if isClient() then
		ModData.transmit("animapi")
	end

	getPlayerInventory(self.character:getPlayerNum()):refreshBackpacks()

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
