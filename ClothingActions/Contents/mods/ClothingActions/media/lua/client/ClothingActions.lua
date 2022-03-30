------------------------------------------
-- Clothing Actions
------------------------------------------

CARMconfig = {
    filter = false,
    delay = false
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

    if ModKey then
        local CARMMODbindings = {
            name = 'CARMMK',
            key = 0
        }
        ModKey:AddBinding(CARMMODbindings)
    end

    if ModOptions and ModOptions.getInstance then
        local function apply(data)
            local player = getSpecificPlayer(0)
            local values = data.settings.options
            
            CARMconfig.filter = values.filter
            CARMconfig.delay = values.delay
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

        local optionsInstance = ModOptions:getInstance(CARMCONFIG)
        ModOptions:loadFile()
        
        Events.OnGameStart.Add(function()
            apply({settings = CARMCONFIG})
        end)
    end

    print(getText("UI_Init_ClothingActionsRM"))
end

ClothingActions() 