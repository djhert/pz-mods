------------------------------------------
-- Clothing Actions Clothing Extra Action override
------------------------------------------

-- I just want to change a few of the init things
local _ISClothingExtraAction_new = ISClothingExtraAction.new
function ISClothingExtraAction:new(...)
	local o = _ISClothingExtraAction_new(self, ...)
	o.stopOnWalk = false
	o.maxTime = 25
    o.useProgressBar = false
	if o.character:isTimedActionInstant() then
		o.maxTime = 1
	end
	return o
end
