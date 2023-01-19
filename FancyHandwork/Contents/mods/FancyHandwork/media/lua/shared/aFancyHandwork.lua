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

FancyHands.nomask = {
	["Base.Torch"] = true,
	["Base.HandTorch"] = true,
	["Base.UmbrellaBlack"] = true,
	["Base.UmbrellaWhite"] = true,
	["Base.UmbrellaBlue"] = true
}

FancyHands.special = {
    ["Base.Generator"] = "holdinggenerator",
    ["Base.CorpseMale"] = "holdingbody",
    ["Base.CorpseFemale"] = "holdingbody"
}

------------------------------------------
-- Fancy Handwork Utilities
------------------------------------------

function isFHModKeyDown()
    return isKeyDown(getCore():getKey('FHModifier'))
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

local FHcreateBindings = function()
    --local FHnewBinds = {}
    local FHbindings = {
        {
            name = '[FancyHandwork]'
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
            swap = true
        },
    }

    for _, bind in ipairs(FHbindings) do
        if bind.name then
            table.insert(keyBinding, { value = bind.name, key = nil })
        else
            if bind.key then
                table.insert(keyBinding, { value = bind.value, key = bind.key })
            end
        end
    end

    local FHhandleKeybinds = function(key)
        local player = getSpecificPlayer(0)
        local action
        for _,bind in ipairs(FHbindings) do
            if key == getCore():getKey(bind.value) then
                if bind.swap then
                    if isFHModKeyDown() then
                        action = bind.action
                        break
                    end
                else
                    action = bind.action
                    break
                end
            end
        end
    
        if not action or isGamePaused() or not player or player:isDead() then
            return 
        end
        action(player)
    end

    FancyHands.addKeyBind = function(keybind)
        table.insert(FHbindings, keybind)
    end

    Events.OnGameStart.Add(function()
        Events.OnKeyPressed.Add(FHhandleKeybinds)
    end)
    
end

local function calcRecentMove(player)
    player:getModData().FancyHands = player:getModData().FancyHands or {
        recentMove = false,
        recentDelta = 0
    } 
    if player:isPlayerMoving() then
        player:getModData().FancyHands.recentMove = true
        player:getModData().FancyHands.recentDelta = 0
    else
        if player:getModData().FancyHands.recentMove then
            player:getModData().FancyHands.recentDelta = player:getModData().FancyHands.recentDelta + 1
            if player:getModData().FancyHands.recentDelta >= ((SandboxVars.FancyHandwork and SandboxVars.FancyHandwork.TurnDelaySec) or 1)*getPerformance():getFramerate() then
                player:getModData().FancyHands.recentMove = false
            end
        end
    end
end



local function fancy(player)
    if not player or player:isDead() or player:isAsleep() then return end
    local primary = player:getPrimaryHandItem()
    local secondary = player:getSecondaryHandItem()

    local queue = ISTimedActionQueue.queues[player]
    if queue and #queue.queue > 0 and not queue.queue[1].FHIgnore then
        player:setVariable("FHDoingAction", true)
    else
        player:setVariable("FHDoingAction", false)
    end

    -- 2 hands
    if primary == secondary then
        if primary then
            if FancyHands.special[primary:getFullType()] then
                player:setVariable("LeftHandMask", FancyHands.special[primary:getFullType()])
                player:clearVariable("RightHandMask")    
                return
            end
            -- some other mods do have their own anim masks, so lets keep those!
            if primary:getItemReplacementPrimaryHand() then
                --player:clearVariable("LeftHandMask")
                return
            end            
        end
        player:clearVariable("LeftHandMask")
        player:clearVariable("RightHandMask")
        return
    end

    if primary then
        if not primary:getItemReplacementPrimaryHand() then
            if instanceof(primary, "HandWeapon") then
                player:setVariable("RightHandMask", (primary:isRanged() and "holdinggunright") or "holdingitemright")
                player:setVariable("FHExp", player:getPerkLevel(Perks.Aiming) >= ((SandboxVars.FancyHandwork and SandboxVars.FancyHandwork.ExperiencedAiming) or 3))
            else
                player:clearVariable("RightHandMask")
            end
        end
    else
        player:clearVariable("RightHandMask")
    end

    if secondary then
        if not secondary:getItemReplacementSecondHand() then
            if instanceof(secondary, "HandWeapon") then
                player:setVariable("LeftHandMask", (secondary:isRanged() and "holdinghgunleft") or "holdingitemleft")
            else
                player:clearVariable("LeftHandMask")
            end 
        end
    else
        player:clearVariable("LeftHandMask")
    end
end

local curPlayer = 0
local function fancyMP(player)
    if not player or player:isDead() or player:isAsleep() then return end
    
    fancy(player)
    
    -- We will do one player per tick to set their state
    ---- We do this to ensure each tick doesn't take too long
    local players = getOnlinePlayers()
    if curPlayer > (players:size()-1) then curPlayer = 0 end
    local mPlayer = players:get(curPlayer)
    if mPlayer ~= player then
        fancy(mPlayer)
    end
    curPlayer = curPlayer + 1
end

local function FancyHandwork()
    print(getText("UI_Init_FancyHandwork"))

    if isServer() then return end
    FHcreateBindings()

    Events.OnGameStart.Add(function()
        if isClient() then
            Events.OnPlayerUpdate.Add(function(player)
                fancyMP(player)
                calcRecentMove(player)
            end)
        else
            Events.OnPlayerUpdate.Add(function(player)
                fancy(player)
                calcRecentMove(player)
            end)
        end
    end)
end

FancyHandwork()

