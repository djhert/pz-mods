------------------------------------------
-- Fancy Handwork Init
------------------------------------------

FancyHands = FancyHands or {}

------------------------------------------
-- Fancy Handwork Configuration
------------------------------------------

FancyHands.config = {
    applyRotationL = true
}

------------------------------------------
-- Fancy Handwork Utilities
------------------------------------------

function isFHModKeyDown()
    return isKeyDown(getCore():getKey('FHModifier'))
end

local count = 0

local FH_OnTick = function()
    if not FancyHands.config.applyRotationL then return end
    -- Control to not get spammed
    count = count + 1
    if count % 30 ~= 0 then return end
    count = 0

    -- First figure out the local player's stuff
    local player = getSpecificPlayer(0)
    if not player:getModData().FancyHandwork then
        player:getModData().FancyHandwork = {}
    end
    for vari, val in pairs(player:getModData().FancyHandwork) do
        player:setVariable(vari, val)
    end
    if isClient() then
        ModData.request("animapi")
        local md = ModData.getOrCreate("animapi")
        for id, obj in pairs(md) do
            local p = getPlayerByOnlineID(id)

            if p and p ~= player then
                for vari, val in pairs(obj) do
                    if val == "nil" then
                        p:clearVariable(vari)
                    else
                        p:setVariable(vari, val)
                    end
                end
            end
        end    
    end
end

local FH_OnCreatePlayer = function(playerNum, playerObj)
    if isClient() then
        ModData.request("animapi")
		if not ModData.getOrCreate("animapi")[playerObj:getOnlineID()] then
			ModData.getOrCreate("animapi")[playerObj:getOnlineID()]= {}
		end
        ModData.transmit("animapi")
    end
    if not playerObj:getModData().FancyHandwork then
        playerObj:getModData().FancyHandwork = {}
    end
end

local FHswapItems = function(character)
    local primary = character:getPrimaryHandItem()
    local secondary = character:getSecondaryHandItem()
    if (primary or secondary) and (primary ~= secondary) then
        ISTimedActionQueue.add(FHSwapHandsAction:new(character, primary, secondary, 10))
    end
end

local FHswapItemsMod = function(character)
    if isFHModKeyDown() then
        FHswapItems(character)
    end
end

local FHDebugKey = function(character)
    if isFHModKeyDown() then
        character:Say("I'm not sure what to do with my hands.")
        --ISTimedActionQueue.add(FHHamboneAction:new(character))
    end
   
end

local FHcreateBindings = function()
    local FHbindings = {
        {
            value = '[FancyHandwork]'
        },
        {
            value = 'FHModifier',
            key = Keyboard.KEY_LCONTROL,
        },
        {
            value = 'FHSwapKey',
            action = FHswapItems,
            key = 0,
        },
        {
            value = 'FHSwapKeyMod',
            action = FHswapItemsMod,
            key = Keyboard.KEY_E,
        },
        -- {
        --     value = 'FHDebugKey',
        --     action = FHDebugKey,
        --     key = Keyboard.KEY_Y,
        -- }
    }

    for _, bind in ipairs(FHbindings) do
        if bind.key or not bind.action then
            table.insert(keyBinding, { value = bind.value, key = bind.key })
        end
    end

    local FHhandleKeybinds = function(key)
        local player = getSpecificPlayer(0)
        local action
        for _,bind in ipairs(FHbindings) do
            if key == getCore():getKey(bind.value) then
                action = bind.action
                break
            end
        end
    
        if not action or isGamePaused() or not player or player:isDead() then
            return 
        end
    
        action(player)
    end

    Events.OnGameStart.Add(function()
        Events.OnKeyPressed.Add(FHhandleKeybinds)
    end)
    
end

local function FancyHandwork()
    FHcreateBindings()

    if ModOptions and ModOptions.getInstance then
        local function apply(data)
            local values = data.settings.options
            FancyHands.config.applyRotationL = values.applyRotationL
        end

        local FHCONFIG = {
            options_data = {
                applyRotationL = {
                    default = true,
                    name = getText("UI_ModOptions_FHfixLHandRotation"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply
                }
            },
            mod_id = "FancyHandwork",
            mod_shortname = "FH",
            mod_fullname = getText("UI_optionscreen_binding_FancyHandwork"),
            mod_version = "1.0"
        }
    
        local optionsInstance = ModOptions:getInstance(FHCONFIG)
        ModOptions:loadFile()
        
        Events.OnGameStart.Add(function()
            apply({settings = FHCONFIG})
        end)
    end

    Events.OnCreatePlayer.Add(FH_OnCreatePlayer)
    Events.OnTick.Add(FH_OnTick)
    
    print(getText("UI_Init_FancyHandwork"))
end

FancyHandwork()