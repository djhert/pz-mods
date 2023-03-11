-- Only load in Single Player or if a Multiplayer client
if not (isClient() or not isServer()) then return end

-- Storage module for defining keybinds used in the game.
local keyman = {
    -- -- keys = {
    --     [key] = {
    --         ["OnKeyPressed"] = {}
    --         ["OnKeyStartPressed"] = {},

    --     },
    -- }
    keys = {},
    -- Functions, indexed by their keybinds
    funcs = {},
    addKeys = {}
}

local conf

local addTo = function(key, data, input)
    local o = data[key] or {}
    o[#o+1] = input
    data[key] = o
    return data
end

-- Add a function to the map by event
--- @param keyName string
--- @param events table
---- events should be a table of functions, indexed by event | { ["event"]=function, ["event"]=function }
---- valid events are "OnKeyStartPressed", "OnModKeyStartPressed", "OnKeyKeepPressed", "OnModKeyKeepPressed", "OnKeyPressed", "OnModKeyPressed"
keyman.addKeyEvents = function(keyName, events)
    keyman.funcs = addTo(keyName, keyman.funcs, events)
end

-- Add a function to the map by event
--- @param section string
--- @param keyName string
--- @param default integer
--- @param events table
---- events should be a table of functions, indexed by event | { ["event"]=function, ["event"]=function }
---- valid events are "OnKeyStartPressed", "OnModKeyStartPressed", "OnKeyKeepPressed", "OnModKeyKeepPressed", "OnKeyPressed", "OnModKeyPressed"
keyman.addKeybind = function(section, keyName, default, events)
    keyman.addKeys = addTo(section, keyman.addKeys, {value=keyName, key=default or 0})
    if events then
        keyman.addKeyEvents(keyName, events)
    end
end

local isMKdown = false

-- Returns if the Modkey is down
--- @return boolean
keyman.isModkeyDown = function()
    return isMKdown
end

-- Prints keys in the `funcs` table, pre-cache
--- Used for Debug
keyman.PrintFuncs = function()
    print("Functions: ")
    for i,v in pairs(keyman.funcs) do
        print("Key: " .. i)
        for j,k in ipairs(v) do
            print(" Index: " .. tostring(j))
            for name,func in pairs(k) do
                print("  Has Event: " .. name .. " | Function: " .. tostring(func))
            end
        end
    end
end

-- Prints keys in the `keys` table, the cache
--- Used for Debug, only available in game
keyman.PrintKeys = function()
    print("Keys: ")
    for i,v in pairs(keyman.keys) do
        print("Key: " .. i)
        for j,event in pairs(v) do
            print(" Event: " .. tostring(j) .. " | Total: " .. tostring(event and #event))
            for index,func in ipairs(event) do
                print("  Index: " .. index .. " | Function: " .. tostring(func))
            end
        end
    end
end

local handleInput = function(key, mevent, event)
    local temp = keyman.keys[key] and (keyman.keys[key][mevent] or keyman.keys[key][event])
    if not temp then return end
    for i=1, #temp do
        temp[i](key)
    end
end

local _onKeyPressed = function(key)
    handleInput(key, (isMKdown and "OnModKeyPressed"), "OnKeyPressed")
end

local _onKeyStartPressed = function(key)
    handleInput(key, (isMKdown and "OnModKeyStartPressed"), "OnKeyStartPressed")
end

local _onKeyKeepPressed = function(key)
    handleInput(key, (isMKdown and "OnModKeyKeepPressed"), "OnKeyKeepPressed")
end

local _onCustomUIKey = function(key)
    handleInput(key, (isMKdown and "OnCustomUIModKey"), "OnCustomUIKey")
end

-- Check if our given function has been already added to the current key/event
---- this could be better, but most of the time this should be a relatively small check
local checkIfExists = function(obj, data)
    if not obj then return false end
    for _,v in ipairs(obj) do
        if v == data then 
            return true 
        end 
    end
    return false
end

keyman.buildKeymap = function()
    keyman.keys = {}
    for i,v in pairs(keyman.funcs) do
        -- get the key for the bind we have stored
        local key = getCore():getKey(i)
        -- check if we didn't get a key for some reason...
        if key then
            -- get the index for this key in our object
            local obj = keyman.keys[key] or {}
            for _,k in ipairs(v) do
                for event, func in pairs(k) do
                    if not checkIfExists(obj[event], func) then
                        obj = addTo(event, obj, func)
                    end
                end
            end
            -- reassign
            keyman.keys[key] = obj
        end
    end
    --keyman.PrintKeys()
end

local _isKeyDown = isKeyDown
local function modkey(key)
    isMKdown = _isKeyDown(key)
end

-- this is for when we disable the event, need to prevent those modkeys from being added; they're not events
local modkeyevents = {
    ["OnModKeyPressed"] = true,
    ["OnModKeyStartPressed"] = true,
    ["OnModKeyKeepPressed"] = true,
    ["OnCustomUIModKey"] = true,
}

-- Build our Keymap and setup our events
keyman._onStart = function()
    keyman.addKeyEvents('Bindaid_Modkey', {
        ["OnKeyStartPressed"] = modkey,
        ["OnKeyPressed"] = modkey,
    })

    if conf.Local.keyinputOptimize then
        keyman.buildKeymap()
        Events.OnKeyPressed.Add(_onKeyPressed)
        Events.OnKeyStartPressed.Add(_onKeyStartPressed)
        Events.OnKeyKeepPressed.Add(_onKeyKeepPressed)
        Events.OnCustomUIKey.Add(_onCustomUIKey)
    else
        -- If the keyinput optimizer is disabled, this will only contain functions added by other mods
        ---- Add those keys to the event stack
        for _,v in pairs(keyman.funcs) do
            for _,k in ipairs(v) do
                for event, func in pairs(k) do
                    -- skip modkey events
                    if not modkeyevents[event] then
                        Events[event].Add(func)
                    end
                end
            end
        end
    end
end

local postBoot = function()
    conf = require('BindAidConfig')

    local keys = {}
    local headers = {}
    local index
    -- index the current keyBinding variable
    for _,v in ipairs(keyBinding) do
        if luautils.stringStarts(v.value, "[") then 
            index = v.value
            keys[index] = {}
            headers[#headers+1] = v.value
        else
            keys[index][#keys[index]+1] = v
        end
    end
    -- Add our functions to the appropriate section
    for section,binds in pairs(keyman.addKeys) do
        --print("Section: " .. tostring(section))
        if not keys[section] then
            headers[#headers+1] = section
            keys[section] = {}
        end
        for _,k in ipairs(binds) do 
            --print("  Key: " .. tostring(k.value) .. " = " .. tostring(k.key))
            keys[section][#keys[section]+1] = k
        end
    end
    -- re-add our bindings back into the keyBinding variable
    keyBinding = {}
    for _,v in ipairs(headers) do
        --print("Index: " .. tostring(i) .. " | Header: " .. v)
        keyBinding[#keyBinding+1] = {value = v, key = nil} -- header
        for _,k in ipairs(keys[v]) do
            --print("  Value: " .. k.value .. " | Key: " .. k.key)
            keyBinding[#keyBinding+1] = {value = k.value, key = k.key} -- let's make a deep copy
        end
    end
end

keyman._onBoot = function()
    Events.OnGameBoot.Add(postBoot)
end

return keyman