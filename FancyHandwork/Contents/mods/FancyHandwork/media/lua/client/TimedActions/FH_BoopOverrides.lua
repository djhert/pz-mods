-- These just add the "boop!"
----
-- Why do these on "perform?"
----
--- The perform function is the only function to be guaranteed to run on success
--- it is not run when the action is canceled, so we don't do our bit
local _ISToggleStoveActione_perform = ISToggleStoveAction.perform
function ISToggleStoveAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.object, extra = 0 }))
    _ISToggleStoveActione_perform(self)
end

local _ISToggleLightAction_perform = ISToggleLightAction.perform
function ISToggleLightAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.object, extra = 0 }))
    _ISToggleLightAction_perform(self)
end

local _ISToggleLightSourceAction_perform = ISToggleLightSourceAction.perform
function ISToggleLightSourceAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.lightSource, extra = 0 }))
    _ISToggleLightSourceAction_perform(self)
end

local _ISToggleComboWasherDryer_perform = ISToggleComboWasherDryer.perform
function ISToggleComboWasherDryer:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.object, extra = 0 }))
    _ISToggleComboWasherDryer_perform(self)
end

local _ISToggleClothingWasher_perform = ISToggleClothingWasher.perform
function ISToggleClothingWasher:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.object, extra = 0 }))
    _ISToggleClothingWasher_perform(self)
end

local _ISToggleClothingDryer_perform = ISToggleClothingDryer.perform
function ISToggleClothingDryer:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.object, extra = 0 }))
    _ISToggleClothingDryer_perform(self)
end

local _ISSetComboWasherDryerMode_perform = ISSetComboWasherDryerMode.perform
function ISSetComboWasherDryerMode:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.object, extra = 0 }))
    _ISSetComboWasherDryerMode_perform(self)
end

local _ISOvenUITimedAction_perform = ISOvenUITimedAction.perform
function ISOvenUITimedAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.object, extra = 0 }))
    _ISOvenUITimedAction_perform(self)
end

local _ISOpenCloseDoor_perform = ISOpenCloseDoor.perform
function ISOpenCloseDoor:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, FancyHands.checkDoor(self.item, self.character, true)))
    _ISOpenCloseDoor_perform(self)
end

local _ISLockDoor_perform = ISLockDoor.perform
function ISLockDoor:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, FancyHands.checkDoor(self.door, self.character, true)))
    _ISLockDoor_perform(self)
end

local _ISOpenCloseCurtain_perform = ISOpenCloseCurtain.perform
function ISOpenCloseCurtain:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character,FancyHands.checkDoor(self.item, self.character, true)))
    _ISOpenCloseCurtain_perform(self)
end

local _ISPadlockAction_perform = ISPadlockAction.perform
function ISPadlockAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.thump, extra = 1 }))
    _ISPadlockAction_perform(self)
end

local _ISBBQInfoAction_perform = ISBBQInfoAction.perform
function ISBBQInfoAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.bbq, extra = 1 }))
    _ISBBQInfoAction_perform(self)
end

local _ISCampingInfoAction_perform = ISCampingInfoAction.perform
function ISCampingInfoAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.campfire, extra = 1 }))
    _ISCampingInfoAction_perform(self)
end

local _ISFireplaceInfoAction_perform = ISFireplaceInfoAction.perform
function ISFireplaceInfoAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.fireplace, extra = -1 }))
    _ISFireplaceInfoAction_perform(self)
end

local _ISGeneratorInfoAction_perform = ISGeneratorInfoAction.perform
function ISGeneratorInfoAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.object, extra = -1 }))
    _ISGeneratorInfoAction_perform(self)
end

local _ISInventoryPage_toggleStove = ISInventoryPage.toggleStove
function ISInventoryPage:toggleStove()
    _ISInventoryPage_toggleStove(self)
    if UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
		return
	end
    ISTimedActionQueue.add(FHBoopAction:new(getSpecificPlayer(self.player), { item = self.inventoryPane.inventory:getParent(), extra = 0 }))
end

local _ISRadioAction_perform = ISRadioAction.perform

function ISRadioAction:perform()
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.device, extra = 0 }))
    _ISRadioAction_perform(self)
end