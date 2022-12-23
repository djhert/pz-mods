------------------------------------------
-- Fancy Handwork Equip Action
---
------------------------------------------

local _ISEquipWeaponAction_start = ISEquipWeaponAction.start
function ISEquipWeaponAction:start()

	-- So, items in your other hand are unequiped if a handgun is equipped
	--- i.e. a handgun in primary hand will be unequiped if a secondary item is equipped and vice versa
	--- this should restore this feature. First, we cache the weapon if needed
	self.hgun = nil
	if instanceof(self.item, "HandWeapon") and not self.twoHands then
		if self.primary then 
			self.hgun = self.character:getSecondaryHandItem()
		else
			self.hgun = self.character:getPrimaryHandItem()
		end
	end

	-- Run the base, then override
	_ISEquipWeaponAction_start(self)

	self.mdata = {}
	if isClient() then
		local md = ModData.getOrCreate("animapi")
		if not md[self.character:getOnlineID()] then
			md[self.character:getOnlineID()] = {}
		end
		self.mdata = md[self.character:getOnlineID()]
	end
	
    -- Check if in second hand or not two handed and use left hand, default is primary hand
    if not self.primary and not self.twoHands then
        self.character:setVariable("FHAnimHand", "left")
		self.mdata["FHAnimHand"] = "left"
		self.LHand = true

		if instanceof(self.item, "HandWeapon") then
			if self.item:isRanged() then
				self.character:setVariable("LeftHandMask", "holdinghgunleft")
				self.mdata["LeftHandMask"] = "holdinghgunleft"
				self.character:getModData().FancyHandwork["LeftHandMask"] = "holdinghgunleft"
			else
				self.character:setVariable("LeftHandMask", "holdingitemleft")
				self.mdata["LeftHandMask"] = "holdingitemleft"
				self.character:getModData().FancyHandwork["LeftHandMask"] = "holdingitemleft"
			end
		else
			self.character:clearVariable("LeftHandMask")
			self.mdata["LeftHandMask"] = "nil"
			self.character:getModData().FancyHandwork["LeftHandMask"] = nil
		end

		if self.fromHotbar then
            self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
        end
    else
        self.character:clearVariable("FHAnimHand")
		self.mdata["FHAnimHand"] = "nil"
		self.character:getModData().FancyHandwork["FHAnimHand"] = nil
		
        if self.fromHotbar and not self.twoHands then
            self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem())	
        end

		if self.twoHands or not self.character:getSecondaryHandItem() then
			self.character:clearVariable("LeftHandMask")
			self.mdata["LeftHandMask"] = "nil"
			self.character:getModData().FancyHandwork["LeftHandMask"] = nil
		end
    end

	if self.fromHotbar then
		local hotbar = getPlayerHotbar(self.character:getPlayerNum())
		hotbar.chr:removeAttachedItem(self.item)
	end
	
	if isClient() then
		ModData.transmit("animapi")
	end
end

local _ISEquipWeaponAction_perform = ISEquipWeaponAction.perform
function ISEquipWeaponAction:perform()
	-- Run the base, then override
	_ISEquipWeaponAction_perform(self)

	-- Lets restore our other weapon now
	if self.hgun then
		if self.primary then
			self.character:setSecondaryHandItem(self.hgun)
		else
			self.character:setPrimaryHandItem(self.hgun)
		end
	end
	
	-- Fix the models, idk why they always blank out the secondary item. :( 
	if self.fromHotbar and not self.twoHands then
		if self.LHand then
        	self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
		else
			self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem()) 
		end
	end
end

-- Override this to set the correct hand on completion
local _ISEquipWeaponAction_animEvent = ISEquipWeaponAction.animEvent
function ISEquipWeaponAction:animEvent(event, parameter)
	-- Run the base, then override
	_ISEquipWeaponAction_animEvent(self, event, parameter)

	-- Fix the models 
	if event == 'detachConnect' and not self.twoHands then
		if self.LHand then
        	self:setOverrideHandModels(self.character:getPrimaryHandItem(), self.item)
		else
			self:setOverrideHandModels(self.item, self.character:getSecondaryHandItem()) 
		end
	end
end