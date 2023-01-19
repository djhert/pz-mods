--- Various overrides for functions that need animations.

------------------
-- Unused by the base, but we will call the base anyways
local _ISLightActions_start = ISLightActions.start
function ISLightActions:start()
    _ISLightActions_start(self)
    self:setActionAnim(CharacterActionAnims.Craft)
end

------------------
-- Add the Craft animation to the upgrade
local _ISUpgradeWeapon_start = ISUpgradeWeapon.start
function ISUpgradeWeapon:start()
    -- remove the item from being attached
    local hotbar = getPlayerHotbar(self.character:getPlayerNum())
    if hotbar:isInHotbar(self.weapon) then
        hotbar.chr:removeAttachedItem(self.weapon)
    end
    self:setActionAnim(CharacterActionAnims.Craft)
    self:setOverrideHandModels(self.part, self.weapon)
    _ISUpgradeWeapon_start(self)
end

------------------
-- Add the Craft animation to the remove upgrade
local _ISRemoveWeaponUpgrade_start = ISRemoveWeaponUpgrade.start
function ISRemoveWeaponUpgrade:start()
    -- remove the item from being attached
    local hotbar = getPlayerHotbar(self.character:getPlayerNum())
    if hotbar:isInHotbar(self.weapon) then
        hotbar.chr:removeAttachedItem(self.weapon)
    end
    self:setActionAnim(CharacterActionAnims.Craft)
    self:setOverrideHandModels(nil, self.weapon)
    _ISRemoveWeaponUpgrade_start(self)
end

------------------
-- Just add the Craft animation here too.
local _ISFixAction_start = ISFixAction.start
function ISFixAction:start()
    -- remove the item from being attached
    local hotbar = getPlayerHotbar(self.character:getPlayerNum())
    if hotbar:isInHotbar(self.item) then
        hotbar.chr:removeAttachedItem(self.item)
    end
    self:setActionAnim(CharacterActionAnims.Craft)
    self:setOverrideHandModels(self.fixing:haveThisFixer(self.character, self.fixer, self.item), self.item)
    _ISFixAction_start(self)
end

------------------
-- Index all of the available animations
local WearAnims = {}
Events.OnGameStart.Add(function()
    for _,v in pairs(WearClothingAnimations) do 
        WearAnims[#WearAnims+1] = v
    end
end)

-- Adds a random animation while drying yourself
---- If this goes longer than 1 tick, then change animation
local _ISDryMyself_update = ISDryMyself.update
function ISDryMyself:update()
    -- I'll just do mine first
    if self.tick >= self.timer then
        self:setAnimVariable("WearClothingLocation", WearAnims[ZombRand(#WearAnims)+1] or "")
    end
    _ISDryMyself_update(self)
end

-- Set the Animation with a radom initial location
local _ISDryMyself_start = ISDryMyself.start
function ISDryMyself:start()
    self:setActionAnim("WearClothing")
    self:setAnimVariable("WearClothingLocation", WearAnims[ZombRand(#WearAnims)+1] or "")
    self:setOverrideHandModels(nil, nil)
    _ISDryMyself_start(self)
end

------------------
-- Set the loot animation for the Transfer
local _ISFinalizeDealAction_start = ISFinalizeDealAction.start
function ISFinalizeDealAction:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Mid")
    self.FHIgnore = true
    _ISFinalizeDealAction_start(self)
end

------------------
-- Add the Recipe animation there too
local _ISAddItemInRecipe_start = ISAddItemInRecipe.start
function ISAddItemInRecipe:start()
    local base = nil
    
    if luautils.stringStarts(self.baseItem:getType(), "GridlePan") or luautils.stringStarts(self.baseItem:getType(), "GriddlePan") then
        base = "GridlePan"
    elseif luautils.stringStarts(self.baseItem:getType(), "WaterSaucepan") or luautils.stringStarts(self.baseItem:getType(), "Saucepan") then
        base = "SaucePan"
    elseif luautils.stringStarts(self.baseItem:getType(), "WaterPot") or luautils.stringStarts(self.baseItem:getType(), "Pot") then
        base = "CookingPot"
    elseif luautils.stringStarts(self.baseItem:getType(), "RoastingPan") or luautils.stringStarts(self.baseItem:getType(), "RoastingPan") then
        base = "RoastingPan"
    else
        base = self.baseItem:getStaticModel() or "FryingPan"
    end
    self:setAnimVariable("BaseType", base)
	self:setActionAnim("AddToPan")
    self:setOverrideHandModelsString(self.usedItem:getStaticModel(), base)
    _ISAddItemInRecipe_start(self)
end

-- TODO:
--- I would like to apply the same tweak to the crafting action.
---- let the props take precedence, but also make it so more object show up in hand
---- plus i just made those animations, and putting noodles into a pot is a crafting recipe, so don't work 
---- I've been working on these animations, and trying various ways to get things working with hand models
----- i'm just kinda done with that for now. lmao

local _ISEmptyRainBarrelAction_start = ISEmptyRainBarrelAction.start
function ISEmptyRainBarrelAction:start()
    self:setActionAnim(CharacterActionAnims.Pour)
	self:setAnimVariable("FoodType", "Pot")
    self:setOverrideHandModels(nil, nil)
    _ISEmptyRainBarrelAction_start(self)
end

local _ISStopAlarmClockAction_start = ISStopAlarmClockAction.start
function ISStopAlarmClockAction:start()
    self:setActionAnim("EquipItem")
    if not self.character:isEquipped(self.alarm) then
        self:setOverrideHandModels(nil, self.alarm)
    end
    self.FHIgnore = true
    _ISStopAlarmClockAction_start(self)
end

local _ISConsolidateDrainable_start = ISConsolidateDrainable.start
function ISConsolidateDrainable:start()
    self:setActionAnim("EquipItem")
    self:setOverrideHandModels(self.drainable, self.intoItem)
    _ISConsolidateDrainable_start(self)
end

local _ISConsolidateDrainableAll_start = ISConsolidateDrainableAll.start
function ISConsolidateDrainableAll:start()
    self:setActionAnim("EquipItem")
    local item
    for _,i in pairs(self.consolidateList) do
        item = i
        break
    end
    self:setOverrideHandModels(item, self.drainable)
    _ISConsolidateDrainableAll_start(self)
end

--- Lets make some better pour animations sometime

local _ISBBQLightFromKindle_start = ISBBQLightFromKindle.start
function ISBBQLightFromKindle:start()
    self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Mid")
    self.FHIgnore = true
    _ISBBQLightFromKindle_start(self)
end

local _ISFireplaceLightFromKindle_start = ISFireplaceLightFromKindle.start
function ISFireplaceLightFromKindle:start()
    self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Low")
    self.FHIgnore = true
    _ISFireplaceLightFromKindle_start(self)
end

-- I have included the following fixes in 3 mods now. lmao
--- I will make this the definitive fix for this, and other mods will defer to this
local _ISClothingExtraAction_new = ISClothingExtraAction.new
function ISClothingExtraAction:new(...)
	local o = _ISClothingExtraAction_new(self, ...)
	o.stopOnAim = false
    o.stopOnWalk = false
    o.stopOnRun = true
	o.maxTime = 25
    o.useProgressBar = true
	if o.character:isTimedActionInstant() then
		o.maxTime = 1
	end
	return o
end

-- Not a hand tweak, but since i'm fixing stuff may as well
local _ISWearClothing_new = ISWearClothing.new
function ISWearClothing:new(...)
    local o = _ISWearClothing_new(self, ...)
    
    o.stopOnAim = false
    o.stopOnWalk = false
    o.stopOnRun = true

    return o
end
