-- Compatibility for The Only Cure
local TOC_Compat = {}

-- Raw access, must pass valid part
--- @param player
--- @param part string
--- @return boolean
TOC_Compat.hasArmPart = function(player, part)
    if not player or not part then return false end
    local data = (player:getModData().TOC and player:getModData().TOC.Limbs) or nil
    if not data then return false end
    return not data[part] or (data[part].is_cut and data[part].is_prosthesis_equipped) or not data[part].is_cut
end

-- Check if hand is available
--- @param player
--- @param left boolean -- optional
--- @return boolean
TOC_Compat.hasHand = function(player, left)
    return TOC_Compat.hasArmPart(player, ((left and "Left_Hand") or "Right_Hand"))
end

-- Check if both hands are available
--- @param player
--- @return boolean
TOC_Compat.hasBothHands = function(player)
    return TOC_Compat.hasHand(player) and TOC_Compat.hasHand(player, true)
end

-- This returns a number for the hands that you have
----- 11 == both hands
----- 10 == left hand
----- 01 (1) == right hand
----- 00 (0) == no hands
--- @param player 
--- @return integer
TOC_Compat.getHands = function(player)
    return ((TOC_Compat.hasHand(player) and 1) or 0) + ((TOC_Compat.hasHand(player, true) and 10) or 0)
end

return TOC_Compat