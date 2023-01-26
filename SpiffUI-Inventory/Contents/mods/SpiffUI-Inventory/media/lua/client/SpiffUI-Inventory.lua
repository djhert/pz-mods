------------------------------------------
-- SpiffUI Inventory Module
------------------------------------------
SpiffUI = SpiffUI or {}

-- Register our inventory
local spiff = SpiffUI:Register("inventory")

spiff.config = {
    enabled = true,
    mouseHide = false,
    invVisible = false,
    lootinv = true,
    sepzeds = true,
    spiffpack = true,
    buttonShow = false,
    spiffequip = true,
    hideEquipped = false,
    handleKeys = false
}

local function SpiffUIBoot() 
    if ModOptions and ModOptions.getInstance then
        local function apply(data)
            local options = data.settings.options
            -- Set options
            spiff.config.enabled = options.enableInv
            spiff.config.mouseHide = options.mouseHide
            spiff.config.invVisible = options.invVisible
            spiff.config.lootinv = options.lootinv
            spiff.config.sepzeds = options.sepzeds
            spiff.config.spiffpack = options.selfinv
            spiff.config.buttonShow = options.buttonShow
            spiff.config.spiffequip = options.spiffequip
            spiff.config.hideEquipped = options.hideEquipped
            spiff.config.handleKeys = options.handleKeys

            SpiffUI.equippedItem["Inventory"] = not options.hideInv
        end

        local function applyGame(data)
            apply(data)
            local options = data.settings.options
            SpiffUI:updateEquippedItem()

            if spiff.config.invVisible then
                getPlayerInventory(0):setVisibleReal(true)
                getPlayerLoot(0):setVisibleReal(true)
            end
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
                invVisible = {
                    name = "UI_ModOptions_SpiffUI_Inv_invVisible",
                    default = false,
                    tooltip = "UI_ModOptions_SpiffUI_Inv_invVisibleTT",
                    OnApplyMainMenu = apply,
                    OnApplyInGame = applyGame,
                },
                lootinv = {
                    name = "UI_ModOptions_SpiffUI_Inv_lootinv",
                    default = true,
                    tooltip = "UI_ModOptions_SpiffUI_Inv_lootinv_tt",
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                sepzeds = {
                    name = "UI_ModOptions_SpiffUI_Inv_sepzeds",
                    default = true,
                    tooltip = "UI_ModOptions_SpiffUI_Inv_sepzeds_tt",
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                selfinv = {
                    name = "UI_ModOptions_SpiffUI_Inv_selfinv",
                    default = true,
                    tooltip = "UI_ModOptions_SpiffUI_Inv_selfinv_tt",
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                buttonShow = {
                    name = "UI_ModOptions_SpiffUI_Inv_buttonShow",
                    default = false,
                    tooltip = "UI_ModOptions_SpiffUI_Inv_buttonShow_tt",
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                spiffequip = {
                    name = "UI_ModOptions_SpiffUI_EquipButton",
                    default = true,
                    tooltip = "UI_ModOptions_SpiffUI_EquipButton_tt",
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                hideEquipped = {
                    name = "UI_ModOptions_SpiffUI_HideEquip",
                    default = false,
                    tooltip = "UI_ModOptions_SpiffUI_HideEquip_tt",
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                handleKeys = {
                    name = "UI_ModOptions_SpiffUI_KeyRing",
                    default = false,
                    tooltip = "UI_ModOptions_SpiffUI_KeyRing_tt",
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

spiff.SpiffUIConfig = function()
    return {
        options = {
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
        name = "SpiffUI - Inventory",
        columns = 4
    }
end

spiff.Boot = SpiffUIBoot