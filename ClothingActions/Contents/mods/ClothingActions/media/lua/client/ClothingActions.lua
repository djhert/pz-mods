------------------------------------------
-- Clothing Actions
------------------------------------------

local CARM = require("ClothingActionsRadialMenu")

local spiff
if getActivatedMods():contains('SpiffUI-Rads') then
    -- Register our Radials
    spiff = SpiffUI:Register("radials")
    if not spiff.radials then spiff.radials = {} end
end

CARMconfig = {
    filter = false,
    delay = false,
    spiff = true
}

local function ClothingActions() 
    
    local CARMbindings = {
        {
            name = '[ClothingActionsRM]'
        },
        {
            name = 'CARM',
            key = Keyboard.KEY_Z
        }
    }

    for _, bind in ipairs(CARMbindings) do
        if (bind.key or not bind.action)  then
            table.insert(keyBinding, { value = bind.name, key = bind.key })
        end
    end

    if ModOptions and ModOptions.getInstance then
        local function apply(data)
            local player = getSpecificPlayer(0)
            local values = data.settings.options
            
            CARMconfig.filter = values.filter
            CARMconfig.delay = values.delay
            CARMconfig.spiff = values.spiff

            -- Register our Radial to SpiffUI
            if spiff then
                if CARMconfig.spiff then
                    spiff.radials[9] = CARM
                else
                    spiff.radials[9] = nil
                end
            end
        end

        local CARMCONFIG = {
            options_data = {
                filter = {
                    default = false,
                    name = getText("UI_ModOptions_CARMfilter"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply
                },
                delay = {
                    default = false,
                    name = getText("UI_ModOptions_CARMdelay"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply
                }
            },
            mod_id = "ClothingActionsRadialMenu",
            mod_shortname = "CARM",
            mod_fullname = getText("UI_optionscreen_binding_ClothingActionsRM")
        }

        if spiff then
            CARMCONFIG.options_data.spiff = {
                default = true,
                name = getText("UI_ModOptions_CARMtoSpiff"),
                OnApplyMainMenu = apply,
                OnApplyInGame = apply
            }
        end

        local optionsInstance = ModOptions:getInstance(CARMCONFIG)
        ModOptions:loadFile()
        
        Events.OnGameStart.Add(function()
            apply({settings = CARMCONFIG})
        end)
    end
    
    Events.OnGameBoot.Add(function()
        print("Clothing Actions Boot!")
    end)

    print(getText("UI_Init_ClothingActionsRM"))
end



ClothingActions() 