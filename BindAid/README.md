Supports B41+ and Multiplayer.

A new save is not required.

# BindAid

Input Binding Manager for Project Zomboid which provides optimizations for keyboard input events and additional Mouse button support with optional keybaord emulation.

# Features
- Keyboard Input Optimization
- Modkey Support
- Additional Mouse Button Support
- Mouse Button Keyboard Emulation
- Autohide the Mouse Cursor
- Easy API for Modders!

## Mod Options

Mod Options is **REQUIRED** to configure this mod; however, it is not a requirement for its operation.  When your first install this mod, please take some time to set up its configuration based on your own needs using Mod Options.  Further information on the available options is available below.

When Mod Options is **NOT** enabled for a save, your configuration will still be read and applied.  **THIS MEANS** Server Owners can safely include this mod without also requiring Mod Options, and user configuration will still be used.

## Keyboard Input Optimization

A full breakdown is available here: BindAid's Keyboard Input Optimization - What It Be, and How It Do

In summary, there are 4 general events that are triggered for input handling, and each event will call multiple functions for each key press.
| Event      | Trigger | # of Functions |
| ----------- | ----------- | ----------- |
| OnKeyStartPressed | When a key is pressed | 10 |
| OnKeyKeepPressed  | When a key is held, every frame | 9 |
| OnKeyPressed | When a key is released | 26 | 
| OnCustomUIKey | When a key is released | 1 |

This occurs for **ALL** key presses, whether they have actions bound or not.  Multiple key presses multiply the number of functions called per frame.  This is not an issue for most people, but I have organized and optimized how this is handled so only 1 function is called during the event, which then calls the key press if applicable.

This feature can be disabled in the Mod Options configuration.  If changed while in-game, a restart is required.

### Compatibility 

I have created this in a way that should have maximum compatibility.  If you have any issues with a vanilla key not being triggered, I would recommend disabling this optimization and letting me know.  I cannot fix all mod compatibility, and some may require changes by the Modders. For Modders, please see: BindAid - Modder's Resource

- Mods that add their own **NEW** keys are not affected.
- Mods that modify vanilla functions for key presses will be compatible as long as their changes are made no later than OnGameStart, and any modifications are forwarded.

## Mouse Buttons

That's right, BindAid provides support for additional Mouse Buttons!  Currently supports up to 10 additional Mouse Buttons, configurable in the Mod Options!

You will need to select the number of Mouse Buttons that you would like to have support for in the Mod Options. A restart of the game is required after you have made this change.

The Mouse Buttons have 2 different modes: Mouse Button Events (default) and Keyboard Emulation.  An option is available to enable both methods to run as well.

### Mouse Button Events

When Mouse Button Events are in use, the additional Mouse Buttons are handled similarly to key bind events.  Modders can hook into these events to allow additional actions to be done on a Mouse Button Press/Hold/Release.  Please see: BindAid - Modder's Resource

**THIS MEANS, BY DEFAULT, MOUSE BUTTONS PERFORM NO NEW ACTIONS! MODDERS MUST ADD SUPPORT FOR THIS!** 

### Keyboard Emulation

New in the "Keybinds" Options Tab will be the Mouse Buttons that are supported under the "BindAid" section, each set to a key bind of "None".  Setting a Key here on a Mouse Button will instead cause an emulated key press to be done instead of the Mouse Event!  For example, you can bind "Reload" to the Middle Mouse Button.

**NOTE!!!** The Emulated key press is ONLY done in Lua, so it will not trigger functions defined in Java.  This means you cannot assign a key to "Move Forward" or something like that; it won't work.  Actions such as Reloading, Shout/Emote, and many others are available, as well as new key binds added by other mods (the main target). 

# BindAid's Keyboard Input Optimization - What It Be, and How It Do

There are 4 general events that are triggered for input handling, and each event will call multiple functions for each key press.
| Event      | Trigger | # of Functions |
| ----------- | ----------- | ----------- |
| OnKeyStartPressed | When a key is pressed | 10 |
| OnKeyKeepPressed  | When a key is held, every frame | 9 |
| OnKeyPressed | When a key is released | 26 | 
| OnCustomUIKey | When a key is released | 1 |

This occurs for **ALL** key presses, whether they have actions bound or not.  Multiple key presses multiply the number of functions called per frame.

Most of the time, this has minimal impact on performance for keyboard input in Project Zomboid as most of the functions called will immediately check for their key first and end. However, there are some that do not and may also perform additional checks; this is redundant when there is no action to perform on a key press and unnecessary overhead.  On low-end machines, or when the game/device is undergoing stress, this can can cause be brief input delays.

Instead, the key binds, events, and functions that are being called have been organized into an array with the key and event as its index.  All vanilla events are then removed from the event stack, and a single event is added for each to trigger the appropriate key and function per event given.  This reduces the overhead for each of the Events to only call ONE function, and if the key is not found in the array then no further action is done.

## How it works

The key bind/event cache is built last during the `OnGameStart` event, so any other mods should have already made their changes at this point.  I also have not experienced any mods that change key binds after `OnGameStart`, and am not sure why you would do this anyway.  The cache is rebuilt when settings are updated.

The cache is built in the following manner:
```lua
cache[key] = {
    ["OnKeyStartPressed"] = { func1, func2 },
    ["OnKeyKeepPressed"] = { func1 }
}
```

The `key` is the numerical value of all key binds.  When a key is pressed it is used to access the list of events, if any, bound to the key.  The event then contains an indexed array of functions to run on this key press.

```lua
local handleInput = function(key, event)
    local temp = cache[key] and cache[key][event]
    if not temp then return end
    for i=1, #temp do
        temp[i](key)
    end
end
```

## Why do this?

Most games engines I have found handles key presses in this way: where operations are indexed or there is some sort of additional control to prevent all functions from being run like this.  While this may provide limited improvements, it is an improvement nonetheless. 

## Benchmark

NOTE: This requires a change to the Lua in the base game by adding a new file, and may produce a lot of noise in your log.  I don't recommend doing this unless you're curious, and if you do, you should be sure to delete this file or verify your game's files with Steam.

### Disclaimer

To be completely honest, we're not looking at substantial improvements for most players.  The Event functions are already optimized, in that most simply end when the key doesn't match. In my testing, the current key bind input event stack takes on average 1 Millisecond (Ms) to complete; any delays come from the action being performed by the key and not from the number of functions being run.  When there was a lot onscreen, and in a dedicated server, I could receive occasional delays of up to about 10Ms. 

With this mod enabled, I consistently receive no more than 1Ms for each Event loop; unless an action is performed on the key, such as opening the crafting window.

Let's take the following code as our benchmark.  In the base game folder, create the following file: `media/lua/shared/!a_KeyTimer.lua`
```lua
-- control for time. 
--- this is reset on each call of the keystack for each key
local time = 0

-- event start functions, store the times
local onKeyDownStart = function(key)
    time = getTimestampMs()
end

local onKeyHoldStart = function(key)
    time = getTimestampMs()
end

local onKeyUpStart = function(key)
    time = getTimestampMs()
end

-- Add our Events to the stack.  
--- Due to how Project Zomboid loads files, this will be first on the Lua-side
Events.OnKeyStartPressed.Add(onKeyDownStart)
Events.OnKeyKeepPressed.Add(onKeyHoldStart)
Events.OnKeyPressed.Add(onKeyUpStart)

-- event end functions. subtract the current from the start, and print if greater than 1
local onKeyDownEnd = function(key)
    time = getTimestampMs() - time
    if time > 1 then
        print("onKeyDownEnd: " .. tostring(key) .. " | Time: " .. tostring(time))
    end
end

local onKeyHoldEnd = function(key)
    time = getTimestampMs() - time
    if time > 1 then
        print("onKeyHoldEnd: " .. tostring(key) .. " | Time: " .. tostring(time))
    end
end

local onKeyUpEnd = function(key)
    time = getTimestampMs() - time
    if time > 1 then
        print("onKeyUpEnd: " .. tostring(key) .. " | Time: " .. tostring(time))
    end
end

-- Add our key events when creating the player; most key events should be assigned by now.
local postStart = function()
    Events.OnKeyStartPressed.Add(onKeyDownEnd)
    Events.OnKeyKeepPressed.Add(onKeyHoldEnd)
    Events.OnKeyPressed.Add(onKeyUpEnd)
end

Events.OnCreatePlayer.Add(postStart)
```

This will save the current Millisecond timestamp in the `time` variable at the start of each event.  The `OnCreatePlayer` function adds our other functions to the end of the Event stacks, and so at the end of the Event the current Millisecond timestamp is subtracted from the start's to give us our delta time.  If this takes over 1Ms, then it will print the key and the delta time.

This most commonly will begin to give results after there are a bunch of zombies on screen, and mostly during `onKeyUpEnd()` due to the number of functions called. 

As mentioned previously, I always get good performance on my machine. I would love to hear any reports (positive or negative) if you tried this yourself!

# BindAid - Modder's Resource

Do you or a loved one want to add your own input events, or be sure to not conflict with BindAid? Then look no further!

BindAid does require that it be supported by modders. I cannot create a solution that would make this work for everything.  As long as nothing too weird is being done, there should already be compatibility.  But to take advantage of the new input handling method, support must be added.

The good news is, this can be done easily and in a way that doesn't make BindAid a hard requirement!

## Keyboard Compatibility

**DO:**
Feel free to make changes to Vanilla functions during `OnGameStart` or before, and be sure to forward your changes!
```lua
    local _ItemBindingHandler_onKeyPressed = ItemBindingHandler.onKeyPressed
    ItemBindingHandler.onKeyPressed = function(key)
        _ItemBindingHandler_onKeyPressed(key)
    end
```
Here, I have replaced the `ItemBindingHandler.onKeyPressed` with my own version of the function, and my change is now forwarded as the new `ItemBindingHandler.onKeyPressed` going forward.

**DON'T:** Make changes to Vanilla functions locally, and not forward your changes.
```lua
    local _ItemBindingHandler_onKeyPressed = ItemBindingHandler.onKeyPressed
    Events.OnKeyPressed.Remove(ItemBindingHandler.onKeyPressed)
    local myNewCoolFunc = function(key)
        _ItemBindingHandler_onKeyPressed(key)
    end
    Events.OnKeyPressed.Add(myNewCoolFunc)
```
This also prevents other functions from accessing any of your changes, as they will only get the vanilla version of the function and also would not be used at all.  This is a sure-fire way to introduce incompatibilities!

The Key Event cache is built at the END of `OnGameStart`, so make any changes that you need before then!

That's basically it as far as compatibility: just make sure you forward your changes made to vanilla functions and be sure to make your changes when it makes sense to, and you're all set!

## Mod Load Order

There seems to be some confusion on this topic, likely due to how other games handle mods.  But to be clear: Mod Load Order will never change the order that Lua files are loaded.  If there is a code conflict, changing the Mod Load Order will not resolve this.  

# How to use

Support for this mod can be added with just a few additional lines of code!  First: get the module, if available.  These will be referenced later.

- For Keyboard Input:
```lua
local keyman = (getActivatedMods():contains("BindAid") and require("KeybindManager"))
```
- For Mouse Input:
```lua
local mouse = (getActivatedMods():contains("BindAid") and require("Mouse"))
```

## Adding a New Key

You can add a new key to the game with the following function:
```lua
keyman.addKeybind("[SECTION]", "Key_Name", 0)
```
`[SECTION]` can be any of the available sections, or a new one!  This will add the key to the appropriate section on the Keybind Options Tab. 

At this point, even if you have already added the key another way, you would typically add a function to an Event to handle your key as well.  Instead, we're going to add our key this way:
```lua
keyman.addKeyEvents("Key_Name", {
    ["OnKeyStartPressed"] = myDownFunction,
    ["OnKeyKeepPressed"] = myHoldFunction,
    ["OnKeyPressed"] = myUpFunction,
})
```
You **ONLY** need to add the events that you intend to support!

You can do this in all one go, too!
```lua
keyman.addKeybind("[SECTION]", "Key_Name", 0, {
    ["OnKeyStartPressed"] = myDownFunction,
    ["OnKeyKeepPressed"] = myHoldFunction,
    ["OnKeyPressed"] = myUpFunction,
})
```

If you are **ADDING** a new key bind, it MUST be done during or before `OnGameBoot` to ensure that the game receives this!

**NOTE:** If a user has the Keyboard Optimize disabled, then your keys will be added as normal events.  You will need to plan for this in your function, by first checking the key pressed.

A full example:
```lua
-- Demonstrates adding Optional support for BindAid
local keyman = (getActivatedMods():contains("BindAid") and require("KeybindManager"))

local myKeyFunction = function(key)
    if key == getCore():getKey("My_Key") then
        getPlayer():Say("Test Pressed!")
    elseif key == getCore():getKey("My_Key2") then
        getPlayer():Say("Test2 Pressed!")
    end
end

local onGameBoot = function()
    -- This is just our Header for the keybinds
    table.insert(keyBinding, { value = "[Testing]" })

    if keyman then
        -- Add our very own key, in full!
        keyman.addKeybind("[Testing]", "My_Key", 82, {
            ["OnKeyPressed"] = myKeyFunction
        })
        
        -- Let's say we add our key another way...
        table.insert(keyBinding, { value = "My_Key2", key = 83 })
         -- Then we add our "Event" this way:
        keyman.addKeyEvents("My_Key2", {
            ["OnKeyPressed"] = myKeyFunction
        })
    else
        -- Add our keys and our events        
        table.insert(keyBinding, { value = "My_Key", key = 82 })
        table.insert(keyBinding, { value = "My_Key2", key = 83 })
        -- Add our Event
        Events.OnKeyPressed.Add(myKeyFunction)
    end
end

Events.OnGameBoot.Add(onGameBoot)
```

## Mouse Buttons

Mouse Button Events are still be developed, in that I am trying to make it easier to handle when a Mouse Button is not available.

For now, you have access to the following variable to tell you how many Mouse Buttons are enabled:
```lua
mouse.mouseButtons
```

Mouse Events work similarly to key bind events.

### Events
| Down | Hold | Release |
| ----------- | ----------- | ----------- |
| OnMouseMiddleDown | OnMouseMiddleHold | OnMouseMiddleUp |
| OnMouse4Down | OnMouse4Hold | OnMouse4Up |
| OnMouse5Down | OnMouse5Hold | OnMouse5Up |
| OnMouse6Down | OnMouse6Hold | OnMouse6Up |
| OnMouse7Down | OnMouse7Hold | OnMouse7Up |
| OnMouse8Down | OnMouse8Hold | OnMouse8Up |
| OnMouse9Down | OnMouse9Hold | OnMouse9Up |
| OnMouse10Down | OnMouse10Hold | OnMouse10Up |
| OnMouse11Down | OnMouse11Hold | OnMouse11Up |
| OnMouse12Down | OnMouse12Hold | OnMouse12Up |

The default Left and Right Click actions are defined in Java, and cannot be overwritten easily.  It is beyond the scope of this mod to attempt this as well.  

An example:
```lua
local mouse = (getActivatedMods():contains("BindAid") and require("Mouse"))

local myMouseButton = function(mouseX, mouseY)
    getPlayer():Say("Middle Mouse!")
end

local onGameBoot = function()
    if mouse then
        mouse.Add({
            ["OnMouseMiddleUp"] = myMouseButton,
        })
    end
end

Events.OnGameBoot.Add(onGameBoot)
```

I also would like to add support for detecting when these Mouse Buttons are clicked on a UI, but it seems the base game only performs these checks on the main Mouse Buttons.  So, stay tuned!