------------------------------------------
-- BindAid Overrides -- Server
--- All of the override functions BindAid Supports
------------------------------------------
if not (isClient() or not isServer()) then return end

local keyman = require('KeybindManager')
local conf = require("BindAidConfig")

local overrides = {}

-- We want the LAST references to all of this
overrides.onStart = function()
    -- Don't do this if disabled
    if not conf.Local.keyinputOptimize then return end
    ------------------------------------------
    -- ItemBindingHandler
    ---- "Equip/Turn On/Off Light Source"
    ---- "ToggleVehicleHeadlights"
    ------- This one is not actually an Event, but is called by ISLightSourceRadialMenu
    ------- This is here to catch the headlights mostly
    ------------------------------------------
    -- local _ItemBindingHandler_onKeyPressed = ItemBindingHandler.onKeyPressed
    -- ItemBindingHandler.onKeyPressed = function(key)
    --     if not keyman.isModKeyDown() then
    --         _ItemBindingHandler_onKeyPressed(key)
    --     end
    -- end

    ------------------------------------------
    -- xpUpdate
    ---- "Toggle Skill Panel"
    ---- "Toggle Health Panel"
    ---- "Toggle Info Panel"
    ---- "Toggle Clothing Protection Panel"
    ------------------------------------------
    local _xpUpdate_displayCharacterInfo = xpUpdate.displayCharacterInfo

    Events.OnKeyPressed.Remove(_xpUpdate_displayCharacterInfo)

    keyman.addKeyEvents("Toggle Skill Panel", { 
        ["OnKeyPressed"] = _xpUpdate_displayCharacterInfo 
    })
    keyman.addKeyEvents("Toggle Health Panel", { 
        ["OnKeyPressed"] = _xpUpdate_displayCharacterInfo 
    })
    keyman.addKeyEvents("Toggle Info Panel", { 
        ["OnKeyPressed"] = _xpUpdate_displayCharacterInfo 
    })
    keyman.addKeyEvents("Toggle Clothing Protection Panel", { 
        ["OnKeyPressed"] = _xpUpdate_displayCharacterInfo 
    })

    ------------------------------------------
    -- ISMoveableCursor
    ---- "Run"
    ---- "Interact"
    ---- "Toggle mode"
    ------------------------------------------
    local _ISMoveableCursor_exitCursorKey = ISMoveableCursor.exitCursorKey
    local _ISMoveableCursor_changeModeKey = ISMoveableCursor.changeModeKey

    Events.OnKeyPressed.Remove(_ISMoveableCursor_exitCursorKey)
    Events.OnKeyKeepPressed.Remove(_ISMoveableCursor_exitCursorKey)

    keyman.addKeyEvents("Run", { 
        ["OnKeyPressed"] = _ISMoveableCursor_exitCursorKey,
        ["OnKeyKeepPressed"] = _ISMoveableCursor_exitCursorKey,
    })
    keyman.addKeyEvents("Interact", { 
        ["OnKeyPressed"] = _ISMoveableCursor_exitCursorKey,
        ["OnKeyKeepPressed"] = _ISMoveableCursor_exitCursorKey,
    })

    Events.OnKeyPressed.Remove(_ISMoveableCursor_changeModeKey)

    keyman.addKeyEvents("Toggle mode", { 
        ["OnKeyPressed"] = _ISMoveableCursor_changeModeKey
    })

end

return overrides