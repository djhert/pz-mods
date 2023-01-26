-----
-- Project Zomboid Clothes Sort
-- Includes categories from mods
-----

local clothesSort = {
    ["Equip"] = 0,
    ["Hat"] = 1,
    ["Head"] = 2,
    ["FullHat"] = 3,
    ["FullHelmet"] = 4,
    ["Wig"] = 5,
    ["FullSuit"] = 6,
    ["FullSuitHead"] = 7,
    ["FullTop"] = 8,
    ["JacketHat"] = 9,
    ["JacketHat_Bulky"] = 10,
    ["SweaterHat"] = 11,
    ["Ears"] = 512,
    ["EarTop"] = 513,
    ["Eyes"] = 14,
    ["Pupils"] = 515,
    ["MakeUp_Eyes"] = 516,
    ["MakeUp_EyesShadow"] = 517,
    ["MaskEyes"] = 518,
    ["RightEye"] = 519,
    ["LeftEye"] = 520,
    ["Nose"] = 521,
    ["SMUICosmeticOne"] = 522,
    ["SMUICosmeticTwo"] = 523,
    ["MakeUp_Lips"] = 524,
    ["MakeUp_FullFace"] = 525,
    ["Mask"] = 26,
    ["MaskFull"] = 27,
    ["SpecialMask"] = 28,
    ["Neck"] = 529,
    ["Necklace"] = 530,
    ["Necklace_Long"] = 531,
    ["Scarf"] = 32,
    ["BellyButton"] = 533,
    ["TankTop"] = 34,
    ["Shirt"] = 35,
    ["Tshirt"] = 36,
    ["ShortSleeveShirt"] = 37,
    ["Sweater"] = 38,
    ["Dress"] = 39,
    ["BathRobe"] = 40,
    ["Torso1Legs1"] = 41,
    ["Jacket"] = 42,
    ["JacketSuit"] = 43,
    ["Jacket_Bulky"] = 44,
    ["Jacket_Down"] = 45,
    ["TorsoExtra"] = 46,
    ["TorsoExtraPlus1"] = 47,
    ["TorsoExtraVest"] = 48,
    ["SMUIJumpsuitPlus"] = 49,
    ["SMUITorsoRigPlus"] = 50,
    ["SMUIWebbingPlus"] = 51,
    ["Boilersuit"] = 52,
    ["EHEPilotVest"] = 53,
    ["TorsoRig"] = 54,
    ["TorsoRig2"] = 55,
    ["TorsoRigPlus2"] = 56,
    ["Back"] = 57,
    ["RifleSling"] = 58,
    ["AmmoStrap"] = 59,
    ["Pauldrons"] = 60,
    ["UpperArmRight"] = 61,
    ["UpperArmLeft"] = 62,
    ["RightArmArmor"] = 63,
    ["LeftArmArmor"] = 64,
    ["HandPlateRight"] = 65,
    ["HandPlateLeft"] = 66,
    ["SMUIRightArmPlus"] = 67,
    ["SMUILeftArmPlus"] = 68,
    ["Hands"] = 69,
    ["SMUIGlovesPlus"] = 70,
    ["RightWrist"] = 571,
    ["LeftWrist"] = 572,
    ["Right_MiddleFinger"] = 573,
    ["Right_RingFinger"] = 574,
    ["Left_MiddleFinger"] = 575,
    ["Left_RingFinger"] = 576,
    ["Belt"] = 77,
    ["Belt419"] = 78,
    ["Belt420"] = 79,
    ["BeltExtra"] = 80,
    ["BeltExtraHL"] = 81,
    ["SpecialBelt"] = 82,
    ["FannyPackBack"] = 83,
    ["FannyPackFront"] = 84,
    ["waistbags"] = 85,
    ["waistbagsComplete"] = 86,
    ["waistbagsf"] = 87,
    ["Tail"] = 588,
    ["Underwear"] = 89,
    ["UnderwearBottom"] = 90,
    ["UnderwearExtra1"] = 91,
    ["UnderwearExtra2"] = 92,
    ["UnderwearInner"] = 93,
    ["UnderwearTop"] = 94,
    ["LowerBody"] = 95,
    ["Legs1"] = 96,
    ["Pants"] = 97,
    ["Skirt"] = 98,
    ["ThighRight"] = 99,
    ["ThighLeft"] = 100,
    ["Kneepads"] = 101,
    ["ShinPlateRight"] = 102,
    ["ShinPlateLeft"] = 103,
    ["Socks"] = 104,
    ["Shoes"] = 105,
    ["SMUIBootsPlus"] = 106,
    [""] = 200
}

-- special lets us define an action for certain items
local special = function(item) 
    
    if instanceof(item, "AlarmClock") or instanceof(item, "AlarmClockClothing") then
        -- We don't want the Watch to be grouped with Jewelry
        return "Hands"
    elseif instanceof(item, "InventoryContainer") and item:getBodyLocation() == "" then
        return (item.canBeEquipped and item:canBeEquipped()) or "Back"
    elseif instanceof(item, "HandWeapon") and item:getBodyLocation() == "" then 
        return "Equip"
    elseif item:getCategory() == "Light Source" and item:getBodyLocation() == "" then
        return "Equip"
    else
        return nil
    end
end

local Sorter = {}

Sorter.itemsList = function(a,b)
	if a.inHotbar and not b.inHotbar then return true end
	if b.inHotbar and not a.inHotbar then return false end
    --if a.inHotbar and b.inHotbar then end
    local j = a.items[1]
    local k = b.items[1]
    if not clothesSort[special(j) or j:getBodyLocation()] or not clothesSort[special(k) or k:getBodyLocation()] then return false end
    return clothesSort[special(j) or j:getBodyLocation()] < clothesSort[special(k) or k:getBodyLocation()]
end

return Sorter