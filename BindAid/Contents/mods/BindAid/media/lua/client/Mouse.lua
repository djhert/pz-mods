local conf = require('BindAidConfig')

local mouse = {
    curMouseX = 0,
    curMouseY = 0,
    prevMouseX = 0,
    prevMouseY = 0,
    hideDelta = 1,
    hiding = false,
    shouldHide = true,
    hideDelay = 10, -- seconds
    mouseButtons = 3,
    buttonState = {},
    buttonData = {}
}

mouse._onTickMouseHide = function() 
    -- Get our position
    mouse.curMouseX = mouse.getX()
    mouse.curMouseY = mouse.getY()

    -- if our position is the same as last frame
    ---- Since we want this to work on everthing; we have to check this manually
    if (mouse.curMouseX == mouse.prevMouseX and mouse.curMouseY == mouse.prevMouseY) then
        -- if we are already hiding, do
        if mouse.hiding then
            mouse.setCursorVisible(false)
        else
            -- otherwise, increment
            mouse.hideDelta = mouse.hideDelta + 1
            -- We changed hideDelay on start to be in seconds
            if mouse.hideDelta >= mouse.hideDelay then
                mouse.hiding = true
            end
        end
    else
        -- Reset
        mouse.hiding = false
        mouse.hideDelta = 1
        mouse.prevMouseX = mouse.curMouseX
        mouse.prevMouseY = mouse.curMouseY
    end
end

mouse.buttonEvents = {
    ["OnMouseMiddleDown"] = {},
    ["OnMouse4Down"] = {},
    ["OnMouse5Down"] = {},
    ["OnMouse6Down"] = {},
    ["OnMouse7Down"] = {},
    ["OnMouse8Down"] = {},
    ["OnMouse9Down"] = {},
    ["OnMouse10Down"] = {},
    ["OnMouse11Down"] = {},
    ["OnMouse12Down"] = {},

    ["OnMouseMiddleHold"] = {},
    ["OnMouse4Hold"] = {},
    ["OnMouse5Hold"] = {},
    ["OnMouse6Hold"] = {},
    ["OnMouse7Hold"] = {},
    ["OnMouse8Hold"] = {},
    ["OnMouse9Hold"] = {},
    ["OnMouse10Hold"] = {},
    ["OnMouse11Hold"] = {},
    ["OnMouse12Hold"] = {},

    ["OnMouseMiddleUp"] = {},
    ["OnMouse4Up"] = {},
    ["OnMouse5Up"] = {},
    ["OnMouse6Up"] = {},
    ["OnMouse7Up"] = {},
    ["OnMouse8Up"] = {},
    ["OnMouse9Up"] = {},
    ["OnMouse10Up"] = {},
    ["OnMouse11Up"] = {},
    ["OnMouse12Up"] = {},
}

local _mouseDownEvents = {
    -- 0
    false, --1
    "OnMouseMiddleDown",
    "OnMouse4Down",
    "OnMouse5Down",
    "OnMouse6Down",
    "OnMouse7Down",
    "OnMouse8Down",
    "OnMouse9Down",
    "OnMouse10Down",
    "OnMouse11Down",
    "OnMouse12Down"
}

local _mouseHoldEvents = {
    -- 0
    false, --1
    "OnMouseMiddleHold",
    "OnMouse4Hold",
    "OnMouse5Hold",
    "OnMouse6Hold",
    "OnMouse7Hold",
    "OnMouse8Hold",
    "OnMouse9Hold",
    "OnMouse10Hold",
    "OnMouse11Hold",
    "OnMouse12Hold"
}

local _mouseUpEvents = {
    -- 0
    false, --1
    "OnMouseMiddleUp",
    "OnMouse4Up",
    "OnMouse5Up",
    "OnMouse6Up",
    "OnMouse7Up",
    "OnMouse8Up",
    "OnMouse9Up",
    "OnMouse10Up",
    "OnMouse11Up",
    "OnMouse12Up"
}

local addTo = function(key, data, input)
    local o = data[key] or {}
    o[#o+1] = input
    data[key] = o
    return data
end

mouse.Add = function(data)
    for i,v in pairs(data) do
        mouse.buttonEvents = addTo(i, mouse.buttonEvents, v)
    end
end


local _event -- cache
local mouseEvent = function(button, go)
    _event = mouse.buttonData[button]
    if not _event then return end
    if _event.press then
        if go then
            _event = mouse.buttonEvents[_mouseHoldEvents[button]]
            for i=1, #_event do
                _event[i](mouse.getX(), mouse.getY())
            end
        else
            _event.press = false
            _event = mouse.buttonEvents[_mouseUpEvents[button]]
            for i=1, #_event do
                _event[i](mouse.getX(), mouse.getY())
            end
        end
    else
        if go then
            _event.press = true
            _event = mouse.buttonEvents[_mouseDownEvents[button]]
            for i=1, #_event do
                _event[i](mouse.getX(), mouse.getY())
            end
        end
    end
end

local mouseEmulate = function(button, go)
    _event = mouse.buttonData[button]
    if not _event then return end
    if _event.press then
        if go then
            -- hold
            triggerEvent("OnKeyKeepPressed", _event.key)
        else
            -- up
            triggerEvent("OnKeyPressed", _event.key)
            _event.press = false
        end
    else
        if go then
            -- down
            triggerEvent("OnKeyStartPressed", _event.key)
            _event.press = true
        end
    end
end

local mouseBoth = function(button, go)
    _event = mouse.buttonData[button]
    if not _event then return end
    if _event.press then
        if go then
            -- hold
            triggerEvent("OnKeyKeepPressed", _event.key)
            _event = mouse.buttonEvents[_mouseHoldEvents[button]]
            for i=1, #_event do
                _event[i](mouse.getX(), mouse.getY())
            end
        else
            -- up
            triggerEvent("OnKeyPressed", _event.key)
            _event.press = false
            _event = mouse.buttonEvents[_mouseUpEvents[button]]
            for i=1, #_event do
                _event[i](mouse.getX(), mouse.getY())
            end
        end
    else
        if go then
            -- down
            triggerEvent("OnKeyStartPressed", _event.key)
            _event.press = true
            _event = mouse.buttonEvents[_mouseDownEvents[button]]
            for i=1, #_event do
                _event[i](mouse.getX(), mouse.getY())
            end
        end
    end
end

mouse.buildButtonData = function()
    mouse.buttonData = {}
    local buttons = { false, } -- 1
    for _,v in ipairs(keyBinding) do
        if luautils.stringStarts(v.value, "Bindaid_MouseKey") then
            buttons[#buttons+1] = getCore():getKey(v.value)
        end
    end
    for i=2, mouse.mouseButtons do
        local key = (buttons[i] and buttons[i] ~= 0 and buttons[i]) or nil
        mouse.buttonData[i] = { 
            func = (key and conf.Conf.emulateAndEvent and mouseBoth) or (key and mouseEmulate) or mouseEvent, 
            key = key
        }
    end
end

mouse._onClickButtonHandler = function()
    for i=2, mouse.mouseButtons do
        mouse.buttonData[i].func(i, mouse.isButtonDown(i))
    end    
end

mouse._onStart = function()
    mouse.buildButtonData()
    if conf.Local.mouseButtonSupport then
        Events.OnTick.Add(mouse._onClickButtonHandler)
    end
end

mouse._onBoot = function()
    -- Since these are static functions, let's cache them
    mouse.getX = Mouse.getX
    mouse.getY = Mouse.getY
    mouse.setCursorVisible = Mouse.setCursorVisible
    mouse.isButtonDown = Mouse.isButtonDown
    mouse.isButtonDownUICheck = Mouse.isButtonDownUICheck
end

return mouse