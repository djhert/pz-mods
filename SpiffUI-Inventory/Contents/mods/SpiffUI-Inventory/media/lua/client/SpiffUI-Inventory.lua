------------------------------------------
-- SpiffUI Inventory Module
------------------------------------------
SpiffUI = SpiffUI or {}

-- Register our inventory
local spiff = SpiffUI:Register("inventory")

spiff.config = {
    enabled = true,
    mouseHide = false
}

local function SpiffUIBoot() 
    if ModOptions and ModOptions.getInstance then
        local function apply(data)
            local options = data.settings.options
            -- Set options
            spiff.config.enabled = options.enableInv
            spiff.config.mouseHide = options.mouseHide
            SpiffUI.equippedItem["Inventory"] = not options.hideInv
        end

        local function applyGame(data)
            apply(data)
            local options = data.settings.options
            SpiffUI:updateEquippedItem()
        end

        local INVCONFIG = {
            options_data = {
                enableInv = {
                    name = "UI_ModOptions_SpiffUI_Inv_enable",
                    default = true,
                    tooltip = "UI_ModOptions_SpiffUI_Inv_tooltip_enable",
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                hideInv = {
                    name = "UI_ModOptions_SpiffUI_Inv_hideInv",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = applyGame,
                },
                mouseHide = {
                    name = "UI_ModOptions_SpiffUI_Inv_mouseHide",
                    default = false,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
            },
            mod_id = "SpiffUI - Inventory",
            mod_shortname = "SpiffUI-Inv",
            mod_fullname = getText("UI_Name_SpiffUI_Inv")
        }

        local optionsInstance = ModOptions:getInstance(INVCONFIG)
        ModOptions:loadFile()

        Events.OnPreMapLoad.Add(function()
            apply({settings = INVCONFIG})
        end)

    end    

    local defKeys = {
        ["Toggle mode"] = Keyboard.KEY_I,
        ["Toggle Moveable Panel Mode"] = 0
    }
    SpiffUI:AddKeyDefaults(defKeys)

    local keyBind = {
        name = 'SpiffUI_Inv',
        key = Keyboard.KEY_TAB,
        qBlock = false,
        Down = ISInventoryPage.SpiffOnKey
    }
    SpiffUI:AddKeyBind(keyBind)

    SpiffUI:AddKeyDisable("Toggle Inventory")

    -- Hello :)
    print(getText("UI_Hello_SpiffUI_Inv"))
end

spiff.Boot = SpiffUIBoot