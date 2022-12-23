------------------------------------------
-- SpiffUI Main Library
------------------------------------------
-- Authors: 
---- @dhert (2022)
------------------------------------------
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
------------------------------------------

------------------------------------------
-- Set the SpiffUI lib version 
local SPIFFUI_VERSION = 3 --<<< DO NOT CHANGE UNLESS YOU KNOW WHAT YOU'RE DOING
if SpiffUI then 
    if SpiffUI.Version >= SPIFFUI_VERSION then
        return -- Don't do anything else
    else
        -- We only want the newest version, and this is it
        Events.OnGameBoot.Remove(SpiffUI.firstBoot)
        SpiffUI = nil
    end
end

------------------------------------------
-- Start SpiffUI
SpiffUI = {}
SpiffUI.Version = SPIFFUI_VERSION

------------------------------------------
-- Register Module
function SpiffUI:Register(name)
    if not SpiffUI[name] then
        -- Add Key for our module
        table.insert(SpiffUI, name)

        -- Add module
        SpiffUI[name] = {}
    end
    return SpiffUI[name]
end

------------------------------------------
-- Overrides for already-defined keys
SpiffUI.KeyDefaults = {}

-- Add a new Key Default
function SpiffUI:AddKeyDefault(name, key)
    SpiffUI.KeyDefaults[name] = tonumber(key)
end

-- Add an array of keys
---- Expected: 
---- binds { 
----    ["Name"] = key,
---- }
function SpiffUI:AddKeyDefaults(binds)
    for i,j in pairs(binds) do
        self:AddKeyDefault(i,j)
    end
end

------------------------------------------
-- Keys that will be removed from the binds
SpiffUI.KeyDisables = {}

-- Add a new Key Disable
function SpiffUI:AddKeyDisable(name)
    -- We do it where the name is the index to avoid dupes
    SpiffUI.KeyDisables[name] = true
end

-- Add an array of keys
---- Expected: 
---- binds { 
----    ["Name"] = true,
---- }
function SpiffUI:AddKeyDisables(binds)
    for i,_ in pairs(binds) do
        self:AddKeyDisable(i)
    end
end

------------------------------------------
-- New Keys to Add
SpiffUI.KeyBinds = {
    {
        name = '[SpiffUI]', -- Title
    }
}

-- Add a new Key Bind
---- Expected:
---- bind = { 
----    name = 'KeyBind',    -- Name of Key
----    key = Keyboard.KEY,  -- Key
----    qBlock = true,       -- Don't perform key action with queue
----    Down = actionDown,   -- Action on Down -- Receives playerObj  -- Optional
----    Hold = actionHold,   -- Action on Hold -- Receives playerObj  -- Optional
----    Up = actionUp        -- Action on Up   -- Receives playerObj  -- Optional
---- }
function SpiffUI:AddKeyBind(bind)
    --SpiffUI.KeyDefaults[name] = tonumber(key)
    table.insert(SpiffUI.KeyBinds, bind)
end

-- Add an array of keys
---- Expected: 
---- binds = { 
----     { 
----        name = 'KeyBind',    -- Name of Key
----        key = Keyboard.KEY,  -- Key
----        qBlock = true,        -- Don't perform key action with queue
----        Down = actionDown,   -- Action on Down -- Receives playerObj  -- Optional
----        Hold = actionHold,   -- Action on Hold -- Receives playerObj  -- Optional
----        Up = actionUp        -- Action on Up   -- Receives playerObj  -- Optional
----    },
---- }
function SpiffUI:AddKeyBinds(binds)
    for _,j in ipairs(binds) do
        self:AddKeyBind(j)
    end
end

------------------------------------------
-- Key Handlers
-- Common things to check for when checking a key
---- Returns the player object if successful
SpiffUI.preCheck = function()
    local player = getSpecificPlayer(0)

    if not player or player:isDead() or player:isAsleep() then
        return nil
    end

    return player
end

local function keyDown(key)
    --print("Pressed: " .. getKeyName(key) .. " | " .. key)
    local player = SpiffUI.preCheck(key)
    if not player then return end

    for _,bind in ipairs(SpiffUI.KeyBinds) do
        if key == getCore():getKey(bind.name) then
            if bind.Down then
                local queue = ISTimedActionQueue.queues[player]
                if bind.qBlock and queue and #queue.queue > 0 then
                    return
                end
                if bind.allowPause or not (UIManager.getSpeedControls() and (UIManager.getSpeedControls():getCurrentGameSpeed() == 0)) then
                    bind.Down(player)
                end
            end
            break
        end
    end
end

local function keyHold(key)
    local player = SpiffUI.preCheck(key)
    if not player then return end

    for _,bind in ipairs(SpiffUI.KeyBinds) do
        if key == getCore():getKey(bind.name) then
            if bind.Hold then
                local queue = ISTimedActionQueue.queues[player]
                if bind.qBlock and queue and #queue.queue > 0 then
                    return
                end
                if bind.allowPause or not (UIManager.getSpeedControls() and (UIManager.getSpeedControls():getCurrentGameSpeed() == 0)) then
                    bind.Hold(player)
                end
            end
            break
        end
    end
end

local function keyRelease(key)
    local player = SpiffUI.preCheck(key)
    if not player then return end

    for _,bind in ipairs(SpiffUI.KeyBinds) do
        if key == getCore():getKey(bind.name) then
            if bind.Up then
                local queue = ISTimedActionQueue.queues[player]
                if bind.qBlock and queue and #queue.queue > 0 then
                    return
                end
                if bind.allowPause or not (UIManager.getSpeedControls() and (UIManager.getSpeedControls():getCurrentGameSpeed() == 0)) then
                    bind.Up(player)
                end
            end
            break
        end
    end
end

------------------------------------------
-- Key Action Handlers
---- used mostly for radials
SpiffUI.action = {
    ticks = 0,
    delay = 500,
    ready = true,
    wasVisible = false
}

-- onKeyDown starts an action
SpiffUI.onKeyDown = function(player)
    -- The radial menu will also close without updating me
    ---- So we need to catch this
    local radialMenu = getPlayerRadialMenu(0)
    if SpiffUI.action.ready and (not radialMenu:isReallyVisible() and SpiffUI.action.wasVisible) then
        SpiffUI.action.ready = true
    end

    -- True means we're not doing another action
    if SpiffUI.action.ready then
        -- Hide Radial Menu on Press if applicable
        if radialMenu:isReallyVisible() and getCore():getOptionRadialMenuKeyToggle() then
            radialMenu:undisplay()
            setJoypadFocus(player:getPlayerNum(), nil)
            SpiffUI.action.wasVisible = false
            SpiffUI.action.ready = true
            return
        end
        SpiffUI.action.ticks = getTimestampMs()
        SpiffUI.action.ready = false
        SpiffUI.action.wasVisible = false
    end
end

-- We check here and set our state if true on hold
SpiffUI.holdTime = function()
    if SpiffUI.action.ready then return false end
    SpiffUI.action.ready = (getTimestampMs() - SpiffUI.action.ticks) >= SpiffUI.action.delay
    return SpiffUI.action.ready
end

-- We check here and set our state if true on release
SpiffUI.releaseTime = function()
    if SpiffUI.action.ready then return false end
    SpiffUI.action.ready = (getTimestampMs() - SpiffUI.action.ticks) < SpiffUI.action.delay
    return SpiffUI.action.ready
end

SpiffUI.resetKey = function()
    SpiffUI.action.ready = true
end

------------------------------------------
-- ISEquippedItem Buttons
SpiffUI.equippedItem = {
    ["Inventory"] = true,
    ["Health"] = true,
    ["QOLEquip"] = true,
    ["Craft"] = true,
    ["Movable"] = true,
    ["Search"] = true,
    ["Map"] = true,
    ["MiniMap"] = true,
    ["Debug"] = true,
    ["Client"] = true,
    ["Admin"] = true
}

function SpiffUI:updateEquippedItem()
    -- Redo the ISEquippedItem tree based on what we set
    local player = getPlayerData(0)
    local y = player.equipped.invBtn:getY()
    -- Add support for the QOL Equipment mod's icon
    SpiffUI.equippedItem["QOLEquip"] = (SETTINGS_QOLMT and SETTINGS_QOLMT.options and SETTINGS_QOLMT.options.useIcon) or false
    for i,v in pairs(SpiffUI.equippedItem) do
        if i == "Inventory" then
            player.equipped.invBtn:setVisible(v)
            if v then
                y = player.equipped.invBtn:getY() + player.equipped.inventoryTexture:getHeightOrig() + 5
            end
        elseif i == "Health" then
            player.equipped.healthBtn:setVisible(v)
            player.equipped.healthBtn:setY(y)
            if v then
                y = player.equipped.healthBtn:getY() + player.equipped.heartIcon:getHeightOrig() + 5
            end
        -- Add support for the QOL Equipment mod's icon
        elseif i == "QOLEquip" and player.equipped.equipButton then
            player.equipped.equipButton:setVisible(v)
            player.equipped.equipButton:setY(y)
            if v then
                y = player.equipped.equipButton:getY() + player.equipped.equipmentIconOFF:getHeightOrig() + 5
            end
        elseif i == "Craft" then
            player.equipped.craftingBtn:setVisible(v)
            player.equipped.craftingBtn:setY(y)
            if v then
                y = player.equipped.craftingBtn:getY() + player.equipped.craftingIcon:getHeightOrig() + 5
            end
        elseif i == "Movable" then
            player.equipped.movableBtn:setVisible(v)
            player.equipped.movableBtn:setY(y)
            player.equipped.movableTooltip:setY(y)
            player.equipped.movablePopup:setY(y)
            if v then
                y = player.equipped.movableBtn:getBottom() + 5
            end
        elseif i == "Search" then
            player.equipped.searchBtn:setVisible(v)
            player.equipped.searchBtn:setY(y)
            if v then
                y = player.equipped.searchBtn:getY() + player.equipped.searchIconOff:getHeightOrig() + 5
            end
        elseif i == "Map" then
            if ISWorldMap.IsAllowed() then
                player.equipped.mapBtn:setVisible(v)
                player.equipped.mapBtn:setY(y)
                
                if ISMiniMap.IsAllowed() then
                    player.equipped.mapPopup:setY(10 + y)
                end

                if v then
                    y = player.equipped.mapBtn:getBottom() + 5
                end
            end
        elseif i == "Debug" then
            if getCore():getDebug() or (ISDebugMenu.forceEnable and not isClient()) then
                player.equipped.debugBtn:setVisible(v)
                player.equipped.debugBtn:setY(y)
                if v then
                    y = player.equipped.debugBtn:getY() + player.equipped.debugIcon:getHeightOrig() + 5
                end
            end
        elseif i == "Client" then
            if isClient() then
                player.equipped.clientBtn:setVisible(v)
                player.equipped.clientBtn:setY(y)
                if v then
                    y = player.equipped.clientBtn:getY() + player.equipped.clientIcon:getHeightOrig() + 5
                end
            end
        elseif i == "Admin" then
            if isClient() then
                player.equipped.adminBtn:setVisible(v)
                player.equipped.adminBtn:setY(y)
            end
        end
    end
end

------------------------------------------

function SpiffUI:OnGameStart()
    for _,j in ipairs(SpiffUI) do
        local mod = SpiffUI[j]
        if mod and mod.Start then
            mod.Start()
        end
    end

    Events.OnKeyStartPressed.Add(keyDown)
    Events.OnKeyKeepPressed.Add(keyHold)
    Events.OnKeyPressed.Add(keyRelease)

    self:updateEquippedItem()
end

function SpiffUI:ModOptions()
    SpiffUI.config = {}

    if ModOptions and ModOptions.getInstance then
        local function apply(data)
            local options = data.settings.options
            -- Set options
            if isDebugEnabled() then
                SpiffUI.config.debug = options.debug
            else
                SpiffUI.config.debug = false
            end
        end

        local SPIFFCONFIG = {
            options_data = {
                applyNewKeybinds = {
                    name = "UI_ModOptions_SpiffUI_applyNewKeybinds",
                    default = false
                },
                runAllResets = {
                    name = "UI_ModOptions_SpiffUI_runAllResets",
                    default = false,
                    tooltip = "UI_ModOptions_SpiffUI_tooltip_runResets"
                }
            },
            mod_id = "SpiffUI",
            mod_shortname = "SpiffUI",
            mod_fullname = getText("UI_Name_SpiffUI")
        }

        if isDebugEnabled() then
            SPIFFCONFIG.options_data.debug = {
                name = "Enable Debug",
                default = false,
                OnApplyMainMenu = apply,
                OnApplyInGame = apply
            }
        end

        local optionsInstance = ModOptions:getInstance(SPIFFCONFIG)
        ModOptions:loadFile()

        -- Modal for our Apply Defaults key
        local applyKeys = optionsInstance:getData("applyNewKeybinds")

        function applyKeys:buildString(text,h)
            for name,key in pairs(SpiffUI.KeyDefaults) do
                text = text .. getText("UI_ModOptions_SpiffUI_Modal_aNKChild", getText("UI_optionscreen_binding_" .. name), getKeyName(key))
                h = h + 20
            end
            return text,h
        end

        function applyKeys:onUpdate(newValue)
            if newValue then
                applyKeys:set(false)
                local w,h = 350,120
                local text = getText("UI_ModOptions_SpiffUI_Modal_applyNewKeybinds")
                text,h = self:buildString(text,h)
                SpiffUI.settingsModal(w, h, text, self, applyKeys.apply)
            end
        end

        function applyKeys:apply(button)
            self.modal = nil
            if button.internal == "NO" then
                return
            end
            for name,key in pairs(SpiffUI.KeyDefaults) do
                for i,v in ipairs(MainOptions.keyText) do
                    if not v.value then
                        if v.txt:getName() == name then
                            v.keyCode = key
                            v.btn:setTitle(getKeyName(key))
                            break
                        end
                    end
                end
            end
            getCore():saveOptions()
            MainOptions.instance.gameOptions.changed = false
        end

        local runResets = optionsInstance:getData("runAllResets")

        function runResets:buildString(text,h)
            for _,j in ipairs(SpiffUI) do
                local mod = SpiffUI[j]
                if mod and mod.Reset then
                    if mod.resetDesc then
                        text = text .. mod.resetDesc
                    else
                        text = text .. " <LINE> " .. j
                    end
                    h = h + 20
                end
            end
            return text,h
        end

        function runResets:onUpdate(newValue)
            if newValue then
                runResets:set(false)
                -- quick check if we're in game
                local player = getPlayerData(0)
                if not player then return end
                local w,h = 350,120
                local text = getText("UI_ModOptions_SpiffUI_Modal_runResets")
                text,h = self:buildString(text,h)
                SpiffUI.settingsModal(w, h, text, self, runResets.apply)
            end
        end

        function runResets:apply(button)
            self.modal = nil
            if button.internal == "NO" then
                return
            end
            for _,j in ipairs(SpiffUI) do
                local mod = SpiffUI[j]
                if mod and mod.Reset then
                    mod.Reset()
                end
            end
            MainOptions.instance.gameOptions.changed = false
        end


        Events.OnPreMapLoad.Add(function()
            apply({settings = SPIFFCONFIG})
        end)

    end
end

-- At first I had this run only once, but apparently when there's only 1 mod this breaks
---- So, OnPostBoot is added to run things last
SpiffUI.firstBoot = function()
    Events.OnGameBoot.Add(function()
        SpiffUI:OnPostBoot()
    end)
    --Events.OnGameBoot.Remove(SpiffUI.firstBoot)
    SpiffUI:OnGameBoot()
end

function SpiffUI:OnGameBoot()
    self:ModOptions()

    for _,j in ipairs(SpiffUI) do
        local mod = SpiffUI[j]
        if mod and mod.Boot then
            mod.Boot()
        end
    end

    -- Let's Remove some keys
    for name,_ in pairs(SpiffUI.KeyDisables) do
        local found = false
        for i = 1, #keyBinding do
            if keyBinding[i].value == name then
                table.remove(keyBinding, i)
                --print("Removed Keybind: " .. name)
                found = true
                break
            end
        end

        -- We may have a SpiffUI key we want to remove
        if not found then
            for i,bind in ipairs(SpiffUI.KeyBinds) do
                if bind.name == name then
                    table.remove(SpiffUI.KeyBinds, i)
                    --print("Removed SpiffUI Keybind: " .. name)
                    break
                end
            end
        end
    end

    -- Now let's add ours!
    for _, bind in ipairs(SpiffUI.KeyBinds) do
        table.insert(keyBinding, { value = bind.name, key = bind.key }) 
    end

    -- Events
    Events.OnGameStart.Add(function()
        SpiffUI:OnGameStart()
    end)

    Events.OnCreatePlayer.Add(function(id)
        SpiffUI:OnCreatePlayer(id)
    end)

end

function SpiffUI:OnPostBoot()
    -- Let's Remove some keys possibly added by mods
    for name,_ in pairs(SpiffUI.KeyDisables) do
        local found = false
        for i = 1, #keyBinding do
            if keyBinding[i].value == name then
                table.remove(keyBinding, i)
                --print("Removed Keybind: " .. name)
                found = true
                break
            end
        end
    end
end

function SpiffUI:OnCreatePlayer(id)
    for _,j in ipairs(SpiffUI) do
        local mod = SpiffUI[j]
        if mod and mod.CreatePlayer then
            mod.CreatePlayer(id)
        end
    end
end

------------------------------------------

SpiffUI.settingsModal = function(w, h, text, key, callback)
    key.modal = ISModalRichText:new((getCore():getScreenWidth() / 2) - w / 2,
    (getCore():getScreenHeight() / 2) - h / 2, w, h,
    text, true, MainOptions.instance, callback)
    key.modal:initialise()
    key.modal:setCapture(true)
    key.modal:setAlwaysOnTop(true)
    key.modal:addToUIManager()
    if MainOptions.joyfocus then
        MainOptions.joyfocus.focus = key.modal
        updateJoypadFocus(key.joyfocus)
    end
end

-- Adapted from: https://www.rosettacode.org/wiki/Word_wrap#Lua
SpiffUI.textwrap = function(text, linewidth)
    -- if its already wrapped, do nothing
    if text:contains("\n") then
        return text
    end
    local function splittokens(s)
        local res = {}
        for w in s:gmatch("%S+") do
            res[#res+1] = w
        end
        return res
    end

    if not linewidth then
        linewidth = 75
    end
 
    local spaceleft = linewidth
    local res = {}
    local line = {}
 
    for _, word in ipairs(splittokens(text)) do
        if #word + 1 > spaceleft then
            table.insert(res, table.concat(line, ' '))
            line = {word}
            spaceleft = linewidth - #word
        else
            table.insert(line, word)
            spaceleft = spaceleft - (#word + 1)
        end
    end
 
    table.insert(res, table.concat(line, ' '))

    return table.concat(res, '\n')
end

------------------------------------------
Events.OnGameBoot.Add(SpiffUI.firstBoot)

-- Hello SpiffUI :)
print(getText("UI_Hello_SpiffUI"))