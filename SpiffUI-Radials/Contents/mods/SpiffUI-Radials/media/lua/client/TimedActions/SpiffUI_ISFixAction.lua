------------------------------------------
-- SpiffUI ISFixAction
----  Adds an animation to ISFixAction
------------------------------------------

local _ISFixAction_start = ISFixAction.start
function ISFixAction:start()
	_ISFixAction_start(self)

    self:setActionAnim(CharacterActionAnims.Craft)
end