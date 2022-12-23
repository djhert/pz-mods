------------------------------------------
-- spiff -- Main
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

------------------------------------------
-- Theme Definition
------------------------------------------
---- Theme = {
----     Name = "",
----     Background = {
----         Header = 0,
----         Primary = 0,
----         Secondary = 0
----     },
----     Border = {
----         Header = 0,
----         Primary = 0,
----         Secondary = 0
----     }
---- }
------------------------------------------

spiff.config = {
    enabled = true,
    Theme = "Blue Steel"
}


spiff.Color = function(r1,g1,b1,a1)
    return { 
        r = r1,
        g = g1,
        b = b1,
        a = a1
    }
end

local Themes = {
    -- The look I'm best known for is
    ["Blue Steel"] = {
        Background = {
            Header = spiff.Color(0.17, 0.20, 0.23, 0.8),
            Primary = spiff.Color(0.11, 0.12, 0.15, 0.8),
            Secondary = spiff.Color(0.13, 0.14, 0.18, 0.8),
            Option = spiff.Color(0.21, 0.24, 0.27, 0.8)
        },
        Border = {
            Header = spiff.Color(0.21, 0.24, 0.27, 0.8),
            Primary = spiff.Color(0.07, 0.08, 0.17, 0.8),
            Secondary = spiff.Color(0.34, 0.38, 0.48, 0.6),
            Option = spiff.Color(0.26, 0.29, 0.33, 0.8)
        },
        Text = {
            Header = spiff.Color(1, 1, 1, 1),
            Primary = spiff.Color(1, 1, 1, 1),
            Secondary = spiff.Color(0.4, 0.4, 0.4, 1),
            Option = spiff.Color(0.8, 0.8, 0.8, 1)
        }
    },
    -- And then there's
    ["Ferrari"] = {
        Background = {
            Header = spiff.Color(0.14, 0.14, 0.14, 0.8),
            Primary = spiff.Color(0.11, 0.11, 0.11, 0.8),
            Secondary = spiff.Color(0.14, 0.14, 0.14, 0.8),
            Option = spiff.Color(0.17, 0.17, 0.17, 0.8)
        },
        Border = {
            Header = spiff.Color(0.2, 0.2, 0.2, 0.8),
            Primary = spiff.Color(0.08, 0.08, 0.08, 0.8),
            Secondary = spiff.Color(0.11, 0.11, 0.11, 0.6),
            Option = spiff.Color(0.14, 0.14, 0.14, 0.8)
        },
        Text = {
            Header = spiff.Color(1, 1, 1, 1),
            Primary = spiff.Color(1, 1, 1, 1),
            Secondary = spiff.Color(0.4, 0.4, 0.4, 1),
            Option = spiff.Color(0.8, 0.8, 0.8, 1)
        }
    },
    -- Le Tigre's a lot softer. It's a little bit more of a catalog look.
    --- I use it for footware sometimes...
    -- ["Le Tigre"] = {
    --     Background = {
    --         Header = spiff.Color(0.14, 0.14, 0.14, 0.8),
    --         Primary = spiff.Color(0.11, 0.11, 0.11, 0.8),
    --         Secondary = spiff.Color(0.14, 0.14, 0.14, 0.6),
    --         Option = spiff.Color(0.17, 0.17, 0.17, 0.8)
    --     },
    --     Border = {
    --         Header = spiff.Color(0.2, 0.2, 0.2, 0.8),
    --         Primary = spiff.Color(0.08, 0.08, 0.08, 0.6),
    --         Secondary = spiff.Color(0.11, 0.11, 0.11, 0.6),
    --         Option = spiff.Color(0.14, 0.14, 0.14, 0.8)
    --     },
    --     Text = {
    --         Header = spiff.Color(1, 1, 1, 1),
    --         Primary = spiff.Color(1, 1, 1, 1),
    --         Secondary = spiff.Color(0.4, 0.4, 0.4, 1),
    --         Option = spiff.Color(0.8, 0.8, 0.8, 1)
    --     }
    -- },
    -- And then the default theme for boring mode
    ["Project Zomboid"] = {
        Background = {
            Header = spiff.Color(0, 0, 0, 0.8),
            Primary = spiff.Color(0, 0, 0, 0.8),
            Secondary = spiff.Color(0, 0, 0, 0.8),
            Option = spiff.Color(0, 0, 0, 0.8)
        },
        Border = {
            Header = spiff.Color(0.4, 0.4, 0.4, 1),
            Primary = spiff.Color(0.4, 0.4, 0.4, 1),
            Secondary = spiff.Color(0.4, 0.4, 0.4, 1),
            Option = spiff.Color(0.4, 0.4, 0.4, 0.8)
        },
        Text = {
            Header = spiff.Color(1, 1, 1, 1),
            Primary = spiff.Color(1, 1, 1, 1),
            Secondary = spiff.Color(1, 1, 1, 1),
            Option = spiff.Color(1, 1, 1, 1)
        }
    }
}

spiff.GetTheme = function()
    return Themes[spiff.config.Theme]
end

spiff.AddTheme = function(name, theme)
    Themes[name] = theme
end

-- We do it this way because we have to make a copy of each subcolor to make a new table
---- If we don't, then a change to one of these colors would change ALL
spiff.GetColor = function(color)
    return { r = color.r, g = color.g, b = color.b, a = color.a }
end

spiff.GetColorMod = function(color, mod)
    return { r = color.r * mod, g = color.g * mod, b = color.b * mod, a = color.a * mod }
end

local themeCab = {}

local function spiffInit()
    local tcIndex = 1
    for n,_ in pairs(Themes) do
        themeCab[tcIndex] = n
        --table.insert(themeCab, n)
        tcIndex = tcIndex + 1
    end
    if ModOptions and ModOptions.getInstance then
        local function apply(data)
            local options = data.settings.options
            spiff.config.enabled = options.enabled
            spiff.config.Theme = themeCab[options.theme]
        end
        local SETTINGS = {
            options_data = {
                enabled = {
                    name = "UI_ModOptions_SpiffUIThemes_Enable",
                    default = true,
                    tooltip = getText("UI_ModOptions_SpiffUIThemes_ToolTip"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                theme = {
                    name = "UI_ModOptions_SpiffUIThemes_Theme",
                    default = 1,
                    tooltip = getText("UI_ModOptions_SpiffUIThemes_ToolTip"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = applyGame,
                }
            },
            mod_id = "SpiffUI-Themes",
            mod_shortname = "SpiffUI-Themes",
            mod_fullname = getText("UI_Name_SpiffUI_Themes")
        }

        for i,v in ipairs(themeCab) do
            SETTINGS.options_data.theme[i] = v
        end

        local oInstance = ModOptions:getInstance(SETTINGS)
        ModOptions:loadFile()

        apply({settings = SETTINGS})

        Events.OnPreMapLoad.Add(function()
            apply({settings = SETTINGS})
        end)
    end

    
    print(getText("UI_Init_SpiffUI_Themes"))
end

spiff.Boot = spiffInit