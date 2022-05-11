------------------------------------------
-- SpiffUI ISWearClothing
----  Allows you to walk and put on clothes that makes sense
------------------------------------------

local _ISWearClothing_new = ISWearClothing.new
function ISWearClothing:new(...)
    local o = _ISWearClothing_new(self, ...)
    
    o.stopOnAim = false
    o.stopOnWalk = false
    o.stopOnRun = true

    return o
end