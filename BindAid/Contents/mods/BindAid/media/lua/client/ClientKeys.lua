local keyman = require("KeybindManager")
local conf = require("BindAidConfig")
------------------------------------------
-- ModKey Overrides -- Client
--- All of the override functions ModKey Supports
------------------------------------------

local overrides = {}

-- We want the LAST references to all of this
overrides.onStart = function()
    -- Don't do this if disabled
    if not conf.Local.keyinputOptimize then return end
    ------------------------------------------
    -- ISHotbar
    ---- "All hotbar keys"
    ------------------------------------------
    local _ISHotbar_onKeyStartPressed = ISHotbar.onKeyStartPressed
    local _ISHotbar_onKeyPressed = ISHotbar.onKeyPressed
    local _ISHotbar_onKeyKeepPressed = ISHotbar.onKeyKeepPressed

    Events.OnKeyStartPressed.Remove(_ISHotbar_onKeyStartPressed)
    Events.OnKeyKeepPressed.Remove(_ISHotbar_onKeyKeepPressed)
    Events.OnKeyPressed.Remove(_ISHotbar_onKeyPressed)

    -- we need to get all of the keys that start with "Hotbar"
    local hotbars = {}
    for _,v in ipairs(keyBinding) do
        if luautils.stringStarts(v.value, "Hotbar ") then
            hotbars[#hotbars+1] = v.value
        end
    end
    for _,v in ipairs(hotbars) do
        keyman.addKeyEvents(v, {
            ["OnKeyStartPressed"] = _ISHotbar_onKeyStartPressed, 
            ["OnKeyKeepPressed"] = _ISHotbar_onKeyKeepPressed, 
            ["OnKeyPressed"] = _ISHotbar_onKeyPressed
        })
    end
    hotbars = nil

    ------------------------------------------
    -- ISVehicleMenu
    ---- "VehicleMechanics"
    ---- "StartVehicleEngine"
    ---- "VehicleHeater"
    ---- "VehicleHorn"
    ---- "VehicleSwitchSeat"
    ------------------------------------------
    local _ISVehicleMenu_onKeyPressed = ISVehicleMenu.onKeyPressed
    local _ISVehicleMenu_onKeyStartPressed = ISVehicleMenu.onKeyStartPressed

    Events.OnKeyPressed.Remove(_ISVehicleMenu_onKeyPressed)
    Events.OnKeyStartPressed.Remove(_ISVehicleMenu_onKeyStartPressed)

    keyman.addKeyEvents("VehicleMechanics", {
        ["OnKeyPressed"] = _ISVehicleMenu_onKeyPressed
    })
    keyman.addKeyEvents("StartVehicleEngine", {
        ["OnKeyPressed"] = _ISVehicleMenu_onKeyPressed
    })
    keyman.addKeyEvents("VehicleHeater", {
        ["OnKeyPressed"] = _ISVehicleMenu_onKeyPressed
    })
    keyman.addKeyEvents("VehicleHorn", {
        ["OnKeyPressed"] = _ISVehicleMenu_onKeyPressed, 
        ["OnKeyStartPressed"] = _ISVehicleMenu_onKeyStartPressed
    })
    keyman.addKeyEvents("VehicleSwitchSeat", {
        ["OnKeyStartPressed"] = _ISVehicleMenu_onKeyStartPressed
    })

    ------------------------------------------
    -- ISWorldMap
    ---- "Map"
    ------------------------------------------
    local _ISWorldMap_onKeyStartPressed = ISWorldMap.onKeyStartPressed
    local _ISWorldMap_onKeyKeepPressed = ISWorldMap.onKeyKeepPressed
    local _ISWorldMap_onKeyReleased = ISWorldMap.onKeyReleased

    Events.OnKeyStartPressed.Remove(_ISWorldMap_onKeyStartPressed)
    Events.OnKeyKeepPressed.Remove(_ISWorldMap_onKeyKeepPressed)
    Events.OnKeyPressed.Remove(_ISWorldMap_onKeyReleased)

    keyman.addKeyEvents("Map", {
        ["OnKeyStartPressed"] = _ISWorldMap_onKeyStartPressed, 
        ["OnKeyKeepPressed"] = _ISWorldMap_onKeyKeepPressed, 
        ["OnKeyPressed"] = _ISWorldMap_onKeyReleased
    })

    ------------------------------------------
    -- ISLightSourceRadialMenu
    ---- "Equip/Turn On/Off Light Source"
    ------------------------------------------
    local _ISLightSourceRadialMenu_onKeyPressed = ISLightSourceRadialMenu.onKeyPressed
    local _ISLightSourceRadialMenu_onKeyRepeat = ISLightSourceRadialMenu.onKeyRepeat
    local _ISLightSourceRadialMenu_onKeyReleased = ISLightSourceRadialMenu.onKeyReleased

    Events.OnKeyStartPressed.Remove(_ISLightSourceRadialMenu_onKeyPressed)
    Events.OnKeyKeepPressed.Remove(_ISLightSourceRadialMenu_onKeyRepeat)
    Events.OnKeyPressed.Remove(_ISLightSourceRadialMenu_onKeyReleased)

    keyman.addKeyEvents("Equip/Turn On/Off Light Source", {
        ["OnKeyStartPressed"] = _ISLightSourceRadialMenu_onKeyPressed, 
        ["OnKeyKeepPressed"] = _ISLightSourceRadialMenu_onKeyRepeat, 
        ["OnKeyPressed"] = _ISLightSourceRadialMenu_onKeyReleased
    })

    ------------------------------------------
    -- ISInventoryPage
    ---- "Toggle Inventory"
    ------------------------------------------
    local _ISInventoryPage_onKeyPressed = ISInventoryPage.onKeyPressed

    Events.OnKeyPressed.Remove(_ISInventoryPage_onKeyPressed)

    keyman.addKeyEvents("Toggle Inventory", {
        ["OnKeyPressed"] = _ISInventoryPage_onKeyPressed
    })

    ------------------------------------------
    -- ISFPS
    ---- "Display FPS"
    ------------------------------------------
    local _ISFPS_onKeyPressed = ISFPS.onKeyPressed

    Events.OnKeyPressed.Remove(_ISFPS_onKeyPressed)

    keyman.addKeyEvents("Display FPS", {
        ["OnKeyPressed"] = _ISFPS_onKeyPressed
    })

    ------------------------------------------
    -- ISUIHandler
    ---- "VehicleRadialMenu"
    ---- "Toggle UI"
    ---- "Show Ping"
    ------------------------------------------
    local _ISUIHandler_onKeyStartPressed = ISUIHandler.onKeyStartPressed
    local _ISUIHandler_onKeyPressed = ISUIHandler.onKeyPressed

    Events.OnKeyStartPressed.Remove(_ISUIHandler_onKeyStartPressed)
    Events.OnKeyPressed.Remove(_ISUIHandler_onKeyPressed)

    keyman.addKeyEvents("Toggle UI", {
        ["OnKeyStartPressed"] = _ISUIHandler_onKeyStartPressed, 
        ["OnKeyPressed"] = _ISUIHandler_onKeyPressed
    })
    keyman.addKeyEvents("VehicleRadialMenu", {
        ["OnKeyStartPressed"] = _ISUIHandler_onKeyStartPressed, 
        ["OnKeyPressed"] = _ISUIHandler_onKeyPressed
    })

    ------------------------------------------
    -- ISCraftingUI
    ---- "Crafting UI"
    ------------------------------------------
    local _ISCraftingUI_onPressKey = ISCraftingUI.onPressKey

    Events.OnCustomUIKey.Remove(_ISCraftingUI_onPressKey)

    keyman.addKeyEvents("Crafting UI", {
        ["OnCustomUIKey"] = _ISCraftingUI_onPressKey
    })

    ------------------------------------------
    -- ISSafetyUI
    ---- "Toggle Safety"
    ------------------------------------------
    local _ISSafetyUI_onKeyPressed = ISSafetyUI.onKeyPressed

    Events.OnKeyPressed.Remove(_ISSafetyUI_onKeyPressed)

    if isClient() and getServerOptions():getBoolean("SafetySystem") then
        keyman.addKeyEvents("Toggle Safety", {
            ["OnKeyPressed"] = _ISSafetyUI_onKeyPressed
        })
    end

    ------------------------------------------
    -- ISFirearmRadialMenu
    ---- "ReloadWeapon"
    ------------------------------------------
    local _ISFirearmRadialMenu_onKeyPressed = ISFirearmRadialMenu.onKeyPressed
    local _ISFirearmRadialMenu_onKeyRepeat = ISFirearmRadialMenu.onKeyRepeat
    local _ISFirearmRadialMenu_onKeyReleased = ISFirearmRadialMenu.onKeyReleased

    Events.OnKeyStartPressed.Remove(_ISFirearmRadialMenu_onKeyPressed)
    Events.OnKeyKeepPressed.Remove(_ISFirearmRadialMenu_onKeyRepeat)
    Events.OnKeyPressed.Remove(_ISFirearmRadialMenu_onKeyReleased)

    keyman.addKeyEvents("ReloadWeapon", {
        ["OnKeyStartPressed"] = _ISFirearmRadialMenu_onKeyPressed, 
        ["OnKeyKeepPressed"] = _ISFirearmRadialMenu_onKeyRepeat, 
        ["OnKeyPressed"] = _ISFirearmRadialMenu_onKeyReleased
    })

    ------------------------------------------
    -- ISMoveableInfoWindow
    ---- "Toggle Moveable Panel Mode"
    ------------------------------------------
    local _ISMoveableInfoWindow_moveablePanelModeKey = ISMoveableInfoWindow.moveablePanelModeKey

    Events.OnKeyPressed.Remove(_ISMoveableInfoWindow_moveablePanelModeKey)

    keyman.addKeyEvents("Toggle Moveable Panel Mode", {
        ["OnKeyPressed"] = _ISMoveableInfoWindow_moveablePanelModeKey
    })

    ------------------------------------------
    -- ISEmoteRadialMenu
    ---- "Emote"
    ---- "Shout"
    ------------------------------------------
    local _ISEmoteRadialMenu_onKeyReleased = ISEmoteRadialMenu.onKeyReleased   
    local _ISEmoteRadialMenu_onKeyPressed = ISEmoteRadialMenu.onKeyPressed
    local _ISEmoteRadialMenu_onKeyRepeat = ISEmoteRadialMenu.onKeyRepeat

    Events.OnKeyStartPressed.Remove(_ISEmoteRadialMenu_onKeyPressed)
	Events.OnKeyKeepPressed.Remove(_ISEmoteRadialMenu_onKeyRepeat)
	Events.OnKeyPressed.Remove(_ISEmoteRadialMenu_onKeyReleased)

    keyman.addKeyEvents("Emote", {
        ["OnKeyStartPressed"] = _ISEmoteRadialMenu_onKeyPressed, 
        ["OnKeyKeepPressed"] = _ISEmoteRadialMenu_onKeyRepeat, 
        ["OnKeyPressed"] = _ISEmoteRadialMenu_onKeyReleased
    })
    keyman.addKeyEvents("Shout", {
        ["OnKeyStartPressed"] = _ISEmoteRadialMenu_onKeyPressed, 
        ["OnKeyKeepPressed"] = _ISEmoteRadialMenu_onKeyRepeat, 
        ["OnKeyPressed"] = _ISEmoteRadialMenu_onKeyReleased
    })

    ------------------------------------------
    -- ISSearchManager
    ---- "Toggle Search Mode"
    ------------------------------------------
    local _ISSearchManager_handleKeyPressed = ISSearchManager.handleKeyPressed

    Events.OnKeyPressed.Remove(_ISSearchManager_handleKeyPressed)

    keyman.addKeyEvents("Toggle Search Mode", {
        ["OnKeyPressed"] = _ISSearchManager_handleKeyPressed
    })

    ------------------------------------------
    -- ISChat
    ---- "Toggle chat"
    ---- "Alt toggle chat"
    ------------------------------------------
    local _ISChat_onToggleChatBox = ISChat.onToggleChatBox
    --local _ISChat_onKeyKeepPressed = ISChat.onKeyKeepPressed

    Events.OnKeyPressed.Remove(_ISChat_onToggleChatBox)

    keyman.addKeyEvents("Toggle chat", {
        ["OnKeyPressed"] = _ISChat_onToggleChatBox
    })
    keyman.addKeyEvents("Alt toggle chat", {
        ["OnKeyPressed"] = _ISChat_onToggleChatBox
    })
    keyman.addKeyEvents("Switch chat stream", {
        ["OnKeyPressed"] = _ISChat_onToggleChatBox
    })

    ------------------------------------------
    -- Escape!
    ---- "Main Menu"
    ------------------------------------------
    local _ToggleEscapeMenu = ToggleEscapeMenu

    Events.OnKeyPressed.Remove(_ToggleEscapeMenu)

    keyman.addKeyEvents("Main Menu", {
        ["OnKeyPressed"] = _ToggleEscapeMenu
    })

    ------------------------------------------
    -- SpeedControlsHandler
    ---- "Pause"
    ---- "Normal Speed"
    ---- "Fast Forward x1"
    ---- "Fast Forward x2"
    ---- "Fast Forward x3"
    ------------------------------------------
    local _SpeedControlsHandler_onKeyPressed = SpeedControlsHandler.onKeyPressed

    Events.OnKeyPressed.Remove(_SpeedControlsHandler_onKeyPressed)

    if not isClient() then
        keyman.addKeyEvents("Pause", {
            ["OnKeyPressed"] = _SpeedControlsHandler_onKeyPressed
        })
        keyman.addKeyEvents("Normal Speed", {
            ["OnKeyPressed"] = _SpeedControlsHandler_onKeyPressed
        })
        keyman.addKeyEvents("Fast Forward x1", {
            ["OnKeyPressed"] = _SpeedControlsHandler_onKeyPressed
        })
        keyman.addKeyEvents("Fast Forward x2", {
            ["OnKeyPressed"] = _SpeedControlsHandler_onKeyPressed
        })
        keyman.addKeyEvents("Fast Forward x3", {
            ["OnKeyPressed"] = _SpeedControlsHandler_onKeyPressed
        })
    end

    ------------------------------------------
    -- SurvivalGuideManager
    ---- "Toggle Survival Guide"
    ------------------------------------------
    local _SurvivalGuideManager_onKeyPressed = SurvivalGuideManager.onKeyPressed
    
    Events.OnKeyPressed.Remove(_SurvivalGuideManager_onKeyPressed)

    keyman.addKeyEvents("Toggle Survival Guide", {
        ["OnKeyPressed"] = _SurvivalGuideManager_onKeyPressed
    })

end

return overrides