-- Only load in Single Player or if a Multiplayer client
if not (isClient() or not isServer()) then return end

local conf = require('BindAidConfig')
local keyman = require('KeybindManager')

local mouse -- client, loaded onBoot

local localOverrides -- client, loaded onStart
local serverOverrides -- server, loaded onStart

local autoHideTimes = {
    1,2,5,10,30,60
}

local onBoot = function()
    mouse = require('Mouse')

    -- Added to Sync the options
    conf.OnApplyOptions = function()
        mouse.hideDelay = (autoHideTimes[conf.Local.autohideMouseTime] or 5) * getPerformance():getFramerate()
        mouse.mouseButtons = conf.Local.mouseButtonCount + 1

        Events.OnTickEvenPaused.Remove(mouse._onTickMouseHide)
        Events.OnFETick.Remove(mouse._onTickMouseHide)

        if conf.Local.autohideMouse then
            -- Do the game and the Pause
            Events.OnTickEvenPaused.Add(mouse._onTickMouseHide)
            -- Do the Main Menu
            Events.OnFETick.Add(mouse._onTickMouseHide)
        end
    end

    conf._onBoot()
    mouse._onBoot()
    keyman._onBoot()
    
    keyman.addKeybind("[Bindaid]", 'Bindaid_Modkey', Keyboard.KEY_LCONTROL)

    if conf.Local.mouseButtonSupport then
        for i=2, mouse.mouseButtons do 
            keyman.addKeybind("[Bindaid]", 'Bindaid_MouseKey_' .. tostring(i), 0)
        end
    end
    
end

local onSettings = function()
    if conf.Local.keyinputOptimize then
        keyman.buildKeymap()
    end
    if conf.Local.mouseButtonSupport then
        mouse.buildButtonData()
    end
end

-- The postStart is the last OnGameStart function that is called
---- Will run all of the other `starts` for keys to get the latest key events
local postStart = function()
    localOverrides.onStart()
    if serverOverrides then serverOverrides.onStart() end

    keyman._onStart()
    mouse._onStart()
end

local onStart = function()
    localOverrides = require('ClientKeys')
    serverOverrides = require('ServerKeys')
    Events.OnSettingsApply.Add(onSettings)
    -- Add the postStart function to the OnGameStart stack now
    ---- This ENSURES that it is last. :)
    Events.OnGameStart.Add(postStart)
end

local function BindAid()
    print(getText("UI_Init_Bindaid"))

    Events.OnGameBoot.Add(onBoot)
    Events.OnGameStart.Add(onStart)
end

BindAid()