------------------------------------------
-- Fancy Handwork Hotbar
---
------------------------------------------

-- Override on GameStart
local function doOverride()
    -- SwapIt support was merged! :D Use that if installed
    if getActivatedMods():contains('SwapIt') then return end

    local _ISHotbar_equipItem = ISHotbar.equipItem

    function ISHotbar:equipItem(item)
        -- Get Modifier
        local mod = isFHModBindDown(self.chr)
        local primary = self.chr:getPrimaryHandItem()
        local secondary = self.chr:getSecondaryHandItem()
        local equip = true

        ISInventoryPaneContextMenu.transferIfNeeded(self.chr, item)

            -- If we already have the item equipped
        if (primary and primary == item) or (secondary and secondary == item) then
            ISTimedActionQueue.add(ISUnequipAction:new(self.chr, item, 20))
            equip = false
        end

        -- If we didn't just do something
        if equip then
            -- Handle holding big objects
            if primary and isForceDropHeavyItem(primary) then
                ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 50))
    ----- treat "equip" as if we have something equipped from here down
                equip = false  
            end
            if mod then
                -- If we still have something equipped in secondary, unequip
                if secondary and equip then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, secondary, 20))
                end
                ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))
            else
                -- If we still have something equipped in primary, unequip
                if primary and equip then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 20))
                end
                -- Equip Primary
                ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))
            end
        end

        self.chr:getInventory():setDrawDirty(true)
        getPlayerData(self.chr:getPlayerNum()).playerInventory:refreshBackpacks()
    end
end
Events.OnGameStart.Add(doOverride)