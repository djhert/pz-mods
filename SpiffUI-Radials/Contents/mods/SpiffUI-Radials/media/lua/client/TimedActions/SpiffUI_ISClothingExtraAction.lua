------------------------------------------
-- SpiffUI Clothing Extra Action override
---- Adds time to the Clothing Extra Action
------------------------------------------

-- This is included with the Clothing Actions Radial Menu already
if getActivatedMods():contains('ClothingActionsRM') then return end

-- I just want to change a few of the init things
local _ISClothingExtraAction_new = ISClothingExtraAction.new
function ISClothingExtraAction:new(...)
	local o = _ISClothingExtraAction_new(self, ...)
	o.stopOnAim = false
    o.stopOnWalk = false
    o.stopOnRun = true
	o.maxTime = 25
    o.useProgressBar = false
	if o.character:isTimedActionInstant() then
		o.maxTime = 1
	end
	return o
end
