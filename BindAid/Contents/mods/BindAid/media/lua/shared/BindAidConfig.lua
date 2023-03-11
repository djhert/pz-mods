-- Configuration Manager
---- Made by dhert, use this however you want. :)
-- NOTE: GIVE THIS FILE A UNIQUE SANDNAME IN YOUR MOD TO NOT OVERWRITE OTHER USES OF THIS SCRIPT!

---------------------
-- Edit the "options_data" array for your settings using Mod Options syntax.
--- Comment out the OPTIONS table in full to disable ModOptions support
--- Do not change the OPTIONS, options_data, mod_id, mod_shortname, and mod_fullname variable names, but fill them in with your own values
--- The options OnApplyMainMenu and OnApplyInGame will be added/overwritten later, do not use them.

local OPTIONS = {
    options_data = {
        autohideMouse = {
            name = "UI_ModOptions_Bindaid_autohideMouse",
            default = true,
        },
        autohideMouseTime = {
            "1", "2", "5", "10", "30", "60",

            name = "UI_ModOptions_Bindaid_autohideMouseTime",
            default = 4,
        },
        mouseButtonSupport = {
            name = "UI_ModOptions_Bindaid_mouseButtonSupport",
            default = true,
        },
        mouseButtonCount = {
            "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",

            name = "UI_ModOptions_Bindaid_mouseButtonCount",
            default = 3
        },
        emulateAndEvent = {
            name = "UI_ModOptions_Bindaid_emulateAndEvent",
            default = false,
        },
        keyinputOptimize = {
            name = "UI_ModOptions_Bindaid_keyinputOptimize",
            default = true,
        },
    },
    mod_id = "BindAid",
    mod_shortname = "BindAid",
    mod_fullname = getText("UI_optionscreen_binding_Bindaid")
}

-- Controls whether ModOptions will overwrite Sandbox Options with the same name by default.
--- To allow Server Owners to control this, keep this as "TRUE" add the IgnoreLocalOptions option to your Sandbox Namespace (see above) 
local OVERWRITE = true

-- Set the name of your SandboxVariable Namespace.  
--- The "Namespace" is the group of Sandbox Variables for your mod: "SanboxVars.Namespace.Variable"
--- You build Sanbox Variables as: "option Namespace.Variable"
---- If you have only one Namespace:
----- local SANDNAME = "Namespace"
---- If you have more than one, then build a table:
----- local SANDNAME = {"One", "Two", "etc"}
----- Comment out to disable Sandbox Support
--local SANDNAME = "Bindaid"

---------------------
-- Additional Documentation
---------------------
-- This module can be used as a cache for your Sandbox Options and ModOptions
--- Simply modify the variables above to setup your mod's Config cache.
--- This can be placed anywhere; client, server, or shared
--- Include this in your mod and use as:
---- local config = require('YourConfigManagerFileNameName') -- no .lua at the end
---- Can use this as:
----- if config.Get("Option") then
-----     -- do something
----- end
---- 
---- You also have access to the raw data using:
---- config.Conf["Option"] OR config.Conf.Option
---
--- Defined ModOptions are made available in the config.Conf table.
---- ModOptions that have the same name as a Sandbox options will overwrite.
----- In your Sandbox namespace, add the option 'IgnoreLocalOptions' to allow server owners to force sync options
----- Example:
------ option Namespace.IgnoreLocalOptions
------ {
------         type = boolean, default = false,
------         page = Namespace,
------         translation = Namespace_IgnoreLocalOptions,
------ }
----- Alternatively, set the OVERWRITE option to false to only sync ModOptions and not overwrite Sandbox options
---------------------
----------- Don't edit below here, unless you know what you're doing. :)
---------------------
local Conf = {
    -- This is our main object for configuration; read from this.
    Conf = {},
    -- This is the user's configuration, only defined if Mod Options exists. Used internally, not intended to be used but left here; already synced with Conf.
    Local = nil,
    -- A function that can be defined to run when Sandbox Settings are read
    OnSandboxConfig = nil,
    -- A function that can be defined to run when settings are applied. Called ANY time that Mod Options are changed
    OnApplyOptions = nil,
    -- A function that can be defined to run when settings are applied in game
    OnApplyOptionsInGame = nil
}

-- Print the available Configuration
--- Useful for debugging
Conf.Print = function()
    for i,v in pairs(Conf.Conf) do 
        print("  " .. tostring(i) .. " = " .. tostring(v))
    end
end

-- Sync Sandbox Configuration from given Namespace
local syncSandboxConfig = function(nmspce)
    local vars = SandboxVars[nmspce]
    if not vars then 
        print("Unable to find namespace: " .. nmspce)
        return false 
    end
    for i,v in pairs(vars) do
        Conf.Conf[i] = v
    end

end

-- Sync Sandbox Configuration from Multiple Namespaces
local syncSandboxConfigMulti = function(nmspces)
    for _,n in ipairs(nmspces) do 
        syncSandboxConfig(n)
    end
end

-- Syncs Sandbox and available ModOptions
Conf.SyncConfig = function() 
    -- Reset our conf object
    Conf.Conf = {}
    if SANDNAME then
        if type(SANDNAME) == "string" then
            syncSandboxConfig(SANDNAME)
        else
            syncSandboxConfigMulti(SANDNAME)
        end
    end
    
    if not Conf.Conf.IgnoreLocalOptions and Conf.Local and OVERWRITE then
        -- Sync our Local configuration into our Conf data, overriding any Sandbox Options
        for i,v in pairs(Conf.Local) do
            Conf.Conf[i] = v
        end
    elseif Conf.Local then
        -- only sync options that do not exist
        for i, v in pairs(Conf.Local) do
            if Conf.Conf[i] == nil then
                Conf.Conf[i] = v
            end
        end
    end
end

-- Get configuration value from given `key`
-- Returns default, nil if no default given
--- @param key string
--- @param default number|boolean|string -- optional
--- @return number|boolean|string|nil
Conf.Get = function(key, default)
    return (Conf.Conf[key] == nil and default) or Conf.Conf[key]
end

-- Apply Mod Options in general, run the OnApplyOptions function if available
---- ALWAYS called when ModOptions are changed
local function applyModOptions(data)
    Conf.Local = {}
    for i,v in pairs(data.settings.options) do
        Conf.Local[i] = v
    end
    if Conf.OnApplyOptions then
        Conf.OnApplyOptions(Conf.Local)
    end
end

-- Apply Mod Options in game, run the OnApplyOptionsInGame function if available
local function applyModOptionsGame(data)
    applyModOptions(data)
    Conf.SyncConfig()
    if Conf.OnApplyOptionsInGame then
        Conf.OnApplyOptionsInGame(Conf.Conf)
    end
end

-- Function that handles ModOptions
local modOptions = function()
    -- Add our apply event functions to the settings
    for i,_ in pairs(OPTIONS.options_data) do
        if not OPTIONS.options_data[i].tooltip then
            local name = OPTIONS.options_data[i].name
            if name then
                name = name .. "_tooltip"
                local tt = getText(name)
                if tt ~= name then -- getText returns the same string if no translation exists, so just check for that
                    OPTIONS.options_data[i].tooltip = tt
                end
            end
        end
        OPTIONS.options_data[i].OnApplyMainMenu = applyModOptions
        OPTIONS.options_data[i].OnApplyInGame = applyModOptionsGame
    end

    -- Load our stuff
    ModOptions:getInstance(OPTIONS)
    ModOptions:loadFile()

    applyModOptions({settings = OPTIONS})

    -- Build our Configuration
    Events.OnInitGlobalModData.Add(function()
        applyModOptionsGame({settings = OPTIONS})
    end)
end

-- Add support for loading the ModOptions config file, even if ModOptions is not currently active
local forceModOptionsConfig = function()
    -- Set our defaults
    local config = {}
    for i,v in pairs(OPTIONS.options_data) do
        config[i] = v.default
    end

    -- Read and apply configuration from the local ini file
    local function Load()
        local file = getFileReader("mods_options.ini", false)
        local line = ""
        local found = false
        if file then
            while true do
                line = file:readLine()
                if not line then 
                    break
                end
                line = line:trim()
                if line ~= "" then
                    local next = false 
                    local k = line:match('^%[([^%[%]]+)%]$')
                    if k and k == OPTIONS.mod_id then
                        found = true
                        next = true
                    elseif k and k ~= OPTIONS.mod_id then
                        if found then break end -- we found the next one, so we're done
                    end
                    if found and not next then 
                        local i, v = line:match('^([%w|_]+)%s-=%s-(.+)$')
                        if(i and v)then
                            v = v:trim()
                            i = i:trim()
                            if(tonumber(v))then
                                v = tonumber(v)
                            elseif(v:lower() == 'true')then
                                v = true
                            elseif(v:lower() == 'false')then
                                v = false
                            else -- we only want the above
                                v = nil
                            end

                            config = config or {}
                            -- if we failed to read from config, then keep the default
                            config[i] = (v == nil and config[i]) or v
                        end
                    end
                end
            end
            file:close()
        end
    end

    Load()

    if isDebugEnabled() then
        print("Force Loading Mod Options")
        for i,v in pairs(config) do
            print("  Loaded: " .. i .. " = " .. tostring(v))
        end
    end

    -- add condition to not do this?
    Conf.Local = config

    Conf.SyncConfig()

    if Conf.OnApplyOptions then
        Conf.OnApplyOptions(Conf.Local)
    end
end

Conf._onBoot = function() 
        -- Runs on the local client, or in singleplayer
    if isClient() or not isServer() then
        -- Add ModOptions if installed, sync Sandbox and ModOptions
        if OPTIONS and ModOptions and ModOptions.getInstance then
            modOptions()
        else
            -- No ModOptions? That's fine, just sync our defined Mod Options and Sandbox options anyways
            Events.OnInitGlobalModData.Add(forceModOptionsConfig)
        end
    else
        -- If its a server, just sync our Sandbox config
        Events.OnInitGlobalModData.Add(Conf.SyncConfig)
    end
end

return Conf