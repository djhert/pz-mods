------------------------------------------
-- Mingler
------------------------------------------
-- Add module
SpiffUI = SpiffUI or {}

-- Register our inventory
local spiff = SpiffUI:Register("inventory")

local mingler = {
    zeds = {
        ["inventorymale"] = true,
        ["inventoryfemale"] = true
    },
    types = {
        ["SpiffBodies"] = true,
        ["SpiffContainer"] = true,
        ["SpiffPack"] = false,
        ["SpiffEquip"] = false
    },
    keyring = {
        ["KeyRing"] = true
    }
}

function mingler:new(player, name, ctype, tex)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.player = player

    -- Looks like Reorder the Hotbar uses the InventoryContainer to track this, so just make a dummy one
    ---- I HAVE to create the item, because just making an InventoryContainer object doesn't give compat with Reorder
    o.invContainer = InventoryItemFactory.CreateItem("SpiffUI.Bag")
    o.invContainer:setName(name)
    o.container = o.invContainer:getInventory()
    o.button = nil
    o.name = name
    o.tex = getTexture(tex)
    o.invs = {}
    o.ctype = ctype
    o.container:setType(ctype)

    o.spiffI = 0

    if ctype == "SpiffBodies" then
        o.spiffI = 1
    elseif ctype == "SpiffContainer" then
        o.spiffI = 2
    elseif ctype == "SpiffEquip" then
        o.spiffI = -1
    end
    
    o.tWeight = 0 

    return o
end

-- Check/make button if needed
function mingler:ckButton(inv)
    if not self.button and self.container:getItems():size() > 0 then
        --self.index = #inv.backpacks
        self.button = inv:addContainerButton(self.container, self.tex, self.name, nil)
    end    
end

-- Check/make button if needed
function mingler:forceButton(inv)
    if not self.button then
        self.button = inv:addContainerButton(self.container, self.tex, self.name, nil)
    end
end

function mingler:hasInv(inv)
end

function mingler:syncItems(inv)
    if mingler.zeds[inv:getType()] then
        self.tWeight = self.tWeight + round(ISInventoryPage.loadWeight(inv), 2) + inv:getMaxWeight() -- We have to calculate this for zeds, some go over
    else
        self.tWeight = self.tWeight + inv:getMaxWeight()
    end
    self.invContainer:setCapacity(self.tWeight)

    local items = inv:getItems()
    if not items or items:size() < 1 then return end -- If the inventory is empty, skip it
    if #self.invs == 0 and inv:getType() == "floor" then -- there is only the floor, ignore
        return
    end
    table.insert(self.invs, inv)

    -- Thanks Mx! :D 
    self.container:getItems():addAll(items)
    -- for i=0,items:size() - 1 do
    --     local item = items:get(i)
    --     if not self.container:contains(item) then
    --         self.container:AddItemBlind(item)
    --     end
    -- end

end

function mingler:syncItemsPlayer(inv)
    if mingler.keyring[inv:getType()] then return end
    local playerObj = getSpecificPlayer(self.player)
    if inv == playerObj:getInventory() then
        self.tWeight = self.tWeight + round(ISInventoryPage.loadWeight(playerObj:getInventory()), 2) + playerObj:getInventory():getMaxWeight()
    else
        self.tWeight = self.tWeight + inv:getMaxWeight()
    end
    self.invContainer:setCapacity(self.tWeight)
    local items = inv:getItems()
    if not items or items:size() < 1 then return end -- If the inventory is empty, skip it
    
    table.insert(self.invs, inv)
    local hotbar = getPlayerHotbar(self.player)

    for i=0,items:size() - 1 do
        local item = items:get(i)
        -- Can't really optimize this as we want to only get items that are not equipped, in a hotbar, or a key/keyring
        if not playerObj:isEquipped(item) and not self.container:contains(item) and not mingler.keyring[item:getType()] then
            -- if instanceof(item, "InventoryContainer") then
            --     self:syncItemsPlayer(item:getInventory())
            -- end
            if not hotbar:isInHotbar(item) then
                self.container:AddItemBlind(item)
            end
        end
    end
    
end

function mingler:syncItemsEquip()
    local playerObj = getSpecificPlayer(self.player)
    self.tWeight = round(ISInventoryPage.loadWeight(playerObj:getInventory()), 2) + playerObj:getInventory():getMaxWeight()
    self.invContainer:setCapacity(self.tWeight)

    local wornItems = getPlayerHotbar(self.player).attachedItems
    for k,v in pairs(wornItems) do
        if not self.container:contains(v) then
            self.container:AddItemBlind(v)
        end
    end
    
    local hand = playerObj:getPrimaryHandItem()
    if hand and not self.container:contains(hand) then
        self.container:AddItemBlind(hand)
    end
    hand = playerObj:getSecondaryHandItem()
    if hand and not self.container:contains(hand) then
        self.container:AddItemBlind(hand)
    end

    wornItems = playerObj:getWornItems()
    for i=0,wornItems:size()-1 do
        local item = wornItems:get(i):getItem()
        if item and not self.container:contains(item) then
            self.container:AddItemBlind(item)
        end
    end
end

function mingler:canPutIn(its)
    local playerObj = getSpecificPlayer(self.player)
    its = its or ISMouseDrag.dragging
    for _,inv in ipairs(self.invs) do
        if inv == nil then
            return nil;
        end
        if inv:getType() == "floor" then
            return inv;
        end

        if inv:getParent() == playerObj then
            return inv;
        end

        local items = {}
        -- If the lightest item fits, allow the transfer.
        local minWeight = 100000
        local dragging = ISInventoryPane.getActualItems(its)
        for i,v in ipairs(dragging) do
            local itemOK = true
            if v:isFavorite() and not inv:isInCharacterInventory(playerObj) then
                itemOK = false
            end
            -- you can't put the container in itself
            if (inv:isInside(v)) then
                itemOK = false;
            end
            if inv:getType() == "floor" and v:getWorldItem() then
                itemOK = false
            end
            if v:getContainer() == inv then
                itemOK = false
            end

            if not inv:isItemAllowed(v) then
                itemOK = false;
            end
            if itemOK then
                table.insert(items, v)
            end
            if v:getUnequippedWeight() < minWeight then
                minWeight = v:getUnequippedWeight()
            end
        end
        if #items == 1 then
            if inv:hasRoomFor(playerObj, items[1]) then
                return inv
            end
        end
        if inv:hasRoomFor(playerObj, minWeight) then
            return inv
        end
    end
    return nil
end

function mingler:reset()
    self.button = nil

    self.tWeight = 0

    self.container:clear()
    table.wipe(self.invs)
end

local reorder = getActivatedMods():contains('REORDER_CONTAINERS')

mingler.OnButtonsAddedLoot = function(inv)
    if inv.keptButtons then
        table.wipe(inv.keptButtons)
    end
    for i,pButton in ipairs(inv.backpacks) do
        -- Ok, so the base game has buttons 1 pixel too high
        pButton:setY(pButton:getY() + 1)

        if spiff.config.buttonShow then
            if spiff.config.lootinv then
                inv.CM.container:forceButton(inv)
            end
            if spiff.config.sepzeds then
                inv.CM.bodies:forceButton(inv)
            end
        end
        
        if pButton.onclick then -- if this is false, then it is an inventory we can't interact with (ie locked)
            if spiff.config.sepzeds and luautils.stringStarts(pButton.inventory:getType(), "inventory") then
                inv.CM.bodies:syncItems(pButton.inventory)
                inv.CM.bodies:ckButton(inv)
                inv:removeChild(pButton)
            elseif not inv:getMingler(pButton.inventory:getType()) then
                if spiff.config.lootinv then
                    inv.CM.container:syncItems(pButton.inventory)
                    inv.CM.container:ckButton(inv)
                end
                if spiff.config.sepzeds then
                    if not inv.keptButtons then inv.keptButtons = {} end
                    table.insert(inv.keptButtons, pButton)
                end
            end
        end
    end

    local prev = inv:getMingler(inv.inventoryPane.lastinventory:getType())
    if prev then
        -- do this manually as 1 second is too long
        inv.forceSelectedContainer = prev.container
        inv.forceSelectedContainerTime = getTimestampMs() + 100
        prev:forceButton(inv)
    elseif spiff.config.sepzeds and luautils.stringStarts(inv.inventoryPane.inventory:getType(), "inventory") then
        inv.forceSelectedContainer = inv.CM.bodies.container
        inv.forceSelectedContainerTime = getTimestampMs() + 100
        inv.CM.bodies:forceButton(inv)
    end

    if spiff.config.sepzeds then
        if not reorder then
            --local floor
            local cur = 0
            -- Have to move all of the buttons to their correct locations
            for _,v in ipairs(inv.keptButtons) do
                v:setY((inv.buttonSize*cur) + (inv:titleBarHeight()))
                cur = cur + 1
                --floor = v
            end

            if inv.CM.container.button then
                --inv.CM.container.button:setY(floor:getY() + inv.buttonSize)
                inv.CM.container.button:setY((inv.buttonSize*cur) + (inv:titleBarHeight()))
                cur = cur+1
            end

            if inv.CM.bodies.button then
                inv.CM.bodies.button:setY((inv.buttonSize*cur) + (inv:titleBarHeight()))
            end 
        end 
        
    else
        if inv.keptButtons then
            table.wipe(inv.keptButtons)
            inv.keptButtons = nil
        end
    end
end

mingler.OnButtonsAddedInv = function(inv)

    for _,pButton in ipairs(inv.backpacks) do
        -- Ok, so the base game has buttons 1 pixel too high
        pButton:setY(pButton:getY() + 1)

        if spiff.config.buttonShow then
            if spiff.config.spiffpack then
                inv.CM.container:forceButton(inv)
            end
        end
        if spiff.config.spiffpack then
            --if not luautils.stringStarts(pButton.inventory:getType(), "Spiff") then
            if not inv:getMingler(pButton.inventory:getType()) then
                inv.CM.container:syncItemsPlayer(pButton.inventory)
                inv.CM.container:ckButton(inv)
            end
        end
    end

    local prev = inv:getMingler(inv.inventoryPane.lastinventory:getType())
    if prev then
        -- do this manually as 1 second is too long
        inv.forceSelectedContainer = prev.container
        inv.forceSelectedContainerTime = getTimestampMs() + 100
        prev:forceButton(inv)
    end

    table.sort(inv.CM.container.invs, function(a,b)
        return a:getCapacity() > b:getCapacity()
    end)
end

mingler.OnRefreshInventoryWindowContainers = function(inv, state)
    if not inv.CM then return end
    if not inv.onCharacter then
        if state == "begin" then
            inv.CM.bodies:reset()
            inv.CM.container:reset()
        --elseif state == "beforeFloor" then
        elseif state == "buttonsAdded" then
            mingler.OnButtonsAddedLoot(inv)
        end
    else
        if state == "begin" then
            inv.CM.container:reset()
            inv.CM.bodies:reset()
            if spiff.config.spiffequip then 
                inv.CM.bodies:forceButton(inv)
                inv.CM.bodies:syncItemsEquip()
                --inv.CM.bodies:ckButton(inv)
            end
        --elseif state == "beforeFloor" then
        elseif state == "buttonsAdded" then
            mingler.OnButtonsAddedInv(inv)
        end
    end
end

return mingler