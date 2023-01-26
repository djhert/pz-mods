------------------------------------------
-- SpiffUI Inventory
------------------------------------------

-- Add module
SpiffUI = SpiffUI or {}

-- Register our inventory
local spiff = SpiffUI:Register("inventory")

------------------------------------------
-- on game start, we take over the Inventory
local function spiffInit(id)
    -- We still setup our stuff, but if not enabled nothing happens
    local player = getSpecificPlayer(id)
    local isMouse = (id == 0) and (not JoypadState.players[1])

    local inv = getPlayerInventory(id)
    local loot = getPlayerLoot(id)

    if spiff.config.enabled then
        -- Set the inventories to be closed on start
        --local isVis = inv:getIsVisible()
        inv:InitSUI()
        loot:InitSUI()
    end

    -- Make them Friends!
    inv.friend = loot
    loot.friend = inv

    if isMouse then
        -- Start collapsed tho
        inv:Collapse(true, "Start")
        loot:Collapse(true, "Start")
    end

    -- Sometimes we just have to re-run this, nbd
    SpiffUI:updateEquippedItem()
end

-- Reset our inventory to the default location
---- This only occurs for user "0" as this is the only user that uses mouse/keys
local function spiffReset()
    local isMouse = (not JoypadState.players[1])
    if isMouse then
        getPlayerInventory(0):SUIReset()
        getPlayerLoot(0):SUIReset()
    end
end

spiff.CreatePlayer = spiffInit
spiff.Reset = spiffReset
spiff.resetDesc = " <LINE> Inventory Panel Location & Size "

------------------------------------------
-- Mingler
------------------------------------------
local mingler = require("SUI/SUI_mingler")

spiff.Start = function()
    Events.OnRefreshInventoryWindowContainers.Add(mingler.OnRefreshInventoryWindowContainers)
end

------------------------------------------
-- ADDITIONS
------------------------------------------
function ISInventoryPage:isMouseInBuffer()
    if self.resizeWidget2.resizing then return true end

    -- So the inventory disappearing isn't so sensitive
    local buffer = 32
    local boX = buffer * (-1)
    local boY = 0 -- can't really go further up at the top
    local boW = self:getWidth() + buffer
    local boH = self:getHeight() + buffer

    local x = self:getMouseX()
    local y = self:getMouseY()

    return (x >= boX and x <= boW) and (y >= boY and y <= boH)
end

function ISInventoryPage:isMouseIn()
    if self.resizeWidget2.resizing then return true end

    -- So the inventory disappearing isn't so sensitive
    local boX = 0
    local boY = 0 -- can't really go further up at the top
    local boW = self:getWidth()
    local boH = self:getHeight()

    local x = self:getMouseX()
    local y = self:getMouseY()

    return (x >= boX and x <= boW) and (y >= boY and y <= boH)
end

function ISInventoryPage:isMouseInTop() 
    -- So the inventory disappearing isn't so sensitive
    local buffer = 32
    local boX = buffer * (-1)
    local boY = 0 -- can't really go further up at the top
    local boW = self:getWidth() + buffer
    local boH = self:titleBarHeight() + buffer

    local x = self:getMouseX()
    local y = self:getMouseY()

    return (x >= boX and x <= boW) and (y >= boY and y <= boH)
end

function ISInventoryPage:InitSUI()
    -- Cache our player
    self.playerObj = getSpecificPlayer(self.player)

    -- If player is on a controller
    self.isMouse = (self.player == 0) and (not JoypadState.players[1])

    -- If force visible
    self.fVisible = false
    -- autohide is used on mouse-over only
    self.autoHide = false
    -- Used to toggle Autohide until interaction with window
    self.holdOpen = false
    -- If being dragged to
    self.toDrag = false
    -- If dragged from here
    self.fromDrag = false
    -- If was opened from drag
    self.wasDrag = false

    self.wasVisible = false
    --self.mouseHide = spiff.config.mouseHide
end

function ISInventoryPage:SUIReset()
    local x = getPlayerScreenLeft(self.player)
    local y = getPlayerScreenTop(self.player)
    local w = getPlayerScreenWidth(self.player)
    local h = getPlayerScreenHeight(self.player)

    local divhei = 0
    local divwid = 0
    divhei = h / 3;

    if w < h then
        divhei = h / 4;
    end

    divwid = round(w / 3)
    if divwid < 256 + 32 then
        -- min width of ISInventoryPage
        divwid = 256 + 32
    end

    if self.onCharacter then
        self:setX(x + w / 2 - divwid)
    else
        self:setX(x + w / 2)
    end
    self:setY(y)
    self:setWidth(divwid)
    self:setHeight(divhei)

    -- Set the column sizes too!
    local column2 = 48
    local column3 = (self.width - column2) / 4
    local column3 = math.ceil(column3*self.inventoryPane.zoom)
	local column3 = (column3) + 100

    self.inventoryPane.column2 = column2
    self.inventoryPane.column3 = column3

    self.inventoryPane.nameHeader:setX(column2)
    self.inventoryPane.nameHeader:setWidth((column3 - column2))

    self.inventoryPane.typeHeader:setX(column3-1)
    self.inventoryPane.typeHeader:setWidth(self.width - column3 + 1)
end

ISInventoryPage.SpiffOnKey = function(playerObj)
    local player = getPlayerInventory(0)
    local loot = getPlayerLoot(0)
    local state = not player.isCollapsed and not loot.isCollapsed

    if not spiff.config.enabled then
        state = not player:getIsVisible()
        player:setVisible(state)
        loot:setVisible(state)
        return
    end

    -- if dragging and tab is pressed, don't do the toggle. it resets the state
    if (not ISMouseDrag.dragging or #ISMouseDrag.dragging == 0) then
        player:Collapse(state, "Toggle")
        loot:Collapse(state, "Toggle")
    end

    -- still set this tho
    player.fVisible = not state
    loot.fVisible = not state
end

------------------------------------------
-- ISInventoryPage:setVisible
local _ISInventoryPage_setVisible = ISInventoryPage.setVisible
function ISInventoryPage:setVisible(vis)
    if not spiff.config.enabled or not self.isMouse then
        _ISInventoryPage_setVisible(self, vis)
        return
    end

    -- This gets called at the start of the game before init, so just don't do anything yet.
    if not self.friend then return end

    self:Collapse(not vis, "setVisible")

    if vis then
        --- This is really only called when the world interacts now
        --- So let's treat it as such
        self.holdOpen = true
        self.autoHide = true
    end
end

function ISInventoryPage:setVisibleReal(vis)
    _ISInventoryPage_setVisible(self, vis)
end

------------------------------------------
-- ISInventoryPage:getIsVisible
local _ISInventoryPage_getIsVisible = ISInventoryPage.getIsVisible
function ISInventoryPage:getIsVisible()
    if not spiff.config.enabled or not self.isMouse then
        return _ISInventoryPage_getIsVisible(self)
    end
    return not self.isCollapsed
end

------------------------------------------
-- ISInventoryPage:onMouseMove
local _ISInventoryPage_onMouseMove = ISInventoryPage.onMouseMove
function ISInventoryPage:onMouseMove(...)
    if not spiff.config.enabled or not self.isMouse then
        _ISInventoryPage_onMouseMove(self, ...)
        return
    end
    -- Disable this
    self.collapseCounter = 0

    if isGamePaused() then
        return
    end

    -- if we're collapsed and pressing right mouse, we're probably aiming
    --- this shouldn't trigger the inventory
    if self.isCollapsed and getSpecificPlayer(self.player):isAiming() then
        return
    end

    self.mouseOver = true

    -- Disable inventory window moving
    if self.moving then
        self.moving = false
    end

    -- camera panning
    local panCameraKey = getCore():getKey("PanCamera")
    if self.isCollapsed and panCameraKey ~= 0 and isKeyDown(panCameraKey) then
        return
    end

    self.fromDrag = false
    -- If we are dragging items from this inventory
    if (ISMouseDrag.dragging and #ISMouseDrag.dragging > 0) and not self.toDrag and not self.fromDrag then
        self.fromDrag = true
    end

    -- First we touch the window, then close
    if self.holdOpen then
        self.holdOpen = false
    end

    self.prevMouse = self.mouseOver
end

------------------------------------------
-- ISInventoryPage:onMouseMoveOutside
local _ISInventoryPage_onMouseMoveOutside = ISInventoryPage.onMouseMoveOutside
function ISInventoryPage:onMouseMoveOutside(...)
    if not spiff.config.enabled or not self.isMouse then
        _ISInventoryPage_onMouseMoveOutside(self, ...)
        return
    end

    if isGamePaused() then
        return
    end
	self.mouseOver = false;

	if self.moving then
		self.moving = false
    end

    if self.wasDrag then
        self.wasDrag = self.friend.mouseOver
    end

    self.prevMouse = self.mouseOver
end

------------------------------------------
-- ISInventoryPage:onMouseDownOutside
local _ISInventoryPage_onMouseDownOutside = ISInventoryPage.onMouseDownOutside
function ISInventoryPage:onMouseDownOutside(...)
    if not spiff.config.enabled or not self.isMouse then
        _ISInventoryPage_onMouseDownOutside(self, ...)
        return
    end

    if not self.fVisible and not self.isCollapsed and not self:isMouseInBuffer() and not self.fromDrag and not self.toDrag and not self.wasDrag then
        self:Collapse(true, "onMouseDownOutside")
    end
end

------------------------------------------
-- ISInventoryPage:onRightMouseDownOutside
local _ISInventoryPage_onRightMouseDownOutside = ISInventoryPage.onRightMouseDownOutside
function ISInventoryPage:onRightMouseDownOutside(...)
    if not spiff.config.enabled or not self.isMouse then
        _ISInventoryPage_onRightMouseDownOutside(self, ...)
        return
    end

    if not self.fVisible and not self.isCollapsed and not self:isMouseInBuffer() and not self.fromDrag and not self.toDrag and not self.wasDrag then
        self:Collapse(true, "onRightMouseDownOutside")
    end
end

-- this is a hack to catch when the vanilla expand is done, we add a parameter to run it or logic to undo it
function ISInventoryPage:clearMaxDrawHeight(extra)
    if not self.isMouse or extra or self.fVisible then 
        ISUIElement.clearMaxDrawHeight(self)
        return
    end

    if not self.autoHide and not self.fromDrag and not self.toDrag and not self.wasDrag and not self.holdOpen then
        self.isCollapsed = true     
    else
        ISUIElement.clearMaxDrawHeight(self)   
    end
end

local equipSort = require("SUI/SUI_InventorySorter")

------------------------------------------
-- ISInventoryPage:createChildren
local _ISInventoryPage_createChildren = ISInventoryPage.createChildren
function ISInventoryPage:createChildren()
    _ISInventoryPage_createChildren(self)

    if spiff.config.enabled and self.isMouse then
        self.closeButton:setVisible(false)
        self.infoButton:setVisible(false)
        self.pinButton:setVisible(false)
        self.collapseButton:setVisible(false)
        self.resizeWidget:setVisible(false)

        self.infoButton:setX(self.closeButton:getX())

        self.minimumHeight = getPlayerScreenHeight(self.player) / 4
    end

    -- render stuff
    -- self.resizeWidget2:setHeight(self:titleBarHeight())
    -- self.resizeWidget2:setY(self:getHeight()-self:titleBarHeight())

    -- We add our inventory containers to the loot panel itself
    self.CM = {}

    if not self.onCharacter then
        self.CM.container = mingler:new(self.player, getText("UI_SpiffUI_Inv_containers"), "SpiffContainer", "media/spifficons/spiffcontainers.png") -- "media/ui/Inventory2_On.png"
        self.CM.bodies = mingler:new(self.player, getText("UI_SpiffUI_Inv_bodies"), "SpiffBodies", "media/spifficons/spiffbodies.png" ) -- "media/ui/Container_DeadPerson_MaleZombie.png"
        self.coloredInvs = {}
        self.keptButtons = nil
    else
        local playerObj = getSpecificPlayer(self.player)
        self.CM.container = mingler:new(self.player, getText("UI_SpffUI_Inv_selfpack", playerObj:getDescriptor():getForename(), playerObj:getDescriptor():getSurname()), "SpiffPack", "media/spifficons/spiffpack.png" ) -- "media/ui/Inventory2_On.png"
        self.CM.bodies = mingler:new(self.player, getText("UI_SpffUI_Inv_equippack", playerObj:getDescriptor():getForename(), playerObj:getDescriptor():getSurname()), "SpiffEquip", "media/spifficons/spiffequip.png")
        self.inventoryPane.equipSort = equipSort.itemsList
    end

    self.titleLoc = self.infoButton:getX() + self.infoButton:getWidth() + 4
end

-- Don't allow to drag items into a Mingle button
local _ISInventoryPage_canPutIn = ISInventoryPage.canPutIn
function ISInventoryPage:canPutIn()
    local container = self.mouseOverButton and self.mouseOverButton.inventory or nil
    if not container then
        return false
    end
    local mnglr = self:getMingler(self.mouseOverButton.inventory:getType())
    if mnglr then
        if mnglr.spiffI > 0 then
            return (mnglr:canPutIn() ~= nil)
        end
        return false
    end 
    return _ISInventoryPage_canPutIn(self)
end

local _ISInventoryPage_onBackpackRightMouseDown = ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage:onBackpackRightMouseDown(x, y)
    if mingler.types[self.inventory:getType()] ~= nil then return end
    _ISInventoryPage_onBackpackRightMouseDown(self,x,y)
end

function ISInventoryPage:Collapse(collapse, why)
    --if self.isCollapsed == collapse then return end

    -- local label
    -- if self.onCharacter then
    --     label = "Player"
    -- else
    --     label = "Loot"
    -- end
    
    -- if collapse then
    --     print("Collapsing: " .. label .. " | " .. why)
    -- else
    --     print("Showing: " .. label .. " | " .. why)
    -- end

    -- If we get here and there's no friend, re-run the init
    if not self.friend then
        spiffInit(self.player)
    end

    self.isCollapsed = collapse
    if self.isCollapsed then
        self:setMaxDrawHeight(self:titleBarHeight())
        self.holdOpen = false
        if spiff.config.enabled then
            if self.friend.isCollapsed then
                _ISInventoryPage_setVisible(self, spiff.config.invVisible)
                _ISInventoryPage_setVisible(self.friend, spiff.config.invVisible)
            end
            self.autoHide = false
            self.holdOpen = false
            self.toDrag = false
            self.fromDrag = false
            self.wasDrag = false
            self.collapsing = true
        end
    else
        if isClient() and not self.onCharacter then
            self.inventoryPane.inventory:requestSync()
        end
        self:clearMaxDrawHeight(true)
        self.collapseCounter = 0
        if spiff.config.enabled then
            _ISInventoryPage_setVisible(self, true)
            _ISInventoryPage_setVisible(self.friend, true)
        end
    end
end

local mings = {
    ["SpiffContainer"] = 1,
    ["SpiffPack"] = 1,
    ["SpiffBodies"] = 2,
    ["SpiffEquip"] = 2
}
function ISInventoryPage:getMingler(name)
    if mings[name] == 1 then
        return self.CM.container
    elseif mings[name] == 2 then
        return self.CM.bodies
    else
        return nil
    end
end

------------------------------------------
-- MISC OTHER THINGS
----- These should probably be in their own file, but eh. xD
------------------------------------------

------------------------------------------
-- We don't want the inventory to change if we are transferring from a Mingle container
local _ISInventoryTransferAction_doActionAnim = ISInventoryTransferAction.doActionAnim
function ISInventoryTransferAction:doActionAnim(cont)
    --if luautils.stringStarts(getPlayerLoot(self.character:getPlayerNum()).inventory:getType(), "Spiff") then
    local loot = getPlayerLoot(self.character:getPlayerNum())
    local mingler = loot:getMingler(loot.inventory:getType())
    if mingler then
        self.selectedContainer = loot.inventory
    end

    _ISInventoryTransferAction_doActionAnim(self, cont)
end

--local keyring = {["KeyRing"] = true}
local getNextKeyRing = function(player, key) 
    local inv = getPlayerInventory(player:getPlayerNum())
    for _, v in ipairs(inv.backpacks) do
        if mingler.keyring[v.inventory:getType()] then --and v.inventory:canPutIn(key) then
            return v.inventory
        end
    end
    return nil
end

Events.OnGameStart.Add(function()
    -- This is actually unused, so lets just use this one!
    ---- Let's do this here, because I'm sure other modders have the same idea
    local _ISInventoryTransferAction_waitToStart = ISInventoryTransferAction.waitToStart
    function ISInventoryTransferAction:waitToStart()
        -- True if a container is on a character
        local char = self.destContainer:getCharacter()
        if char then
            if char == self.character then
                --Send keys to the keyring
                if instanceof(self.item, "Key") and spiff.config.handleKeys then
                    -- default to the destContainer
                    self.destContainer = getNextKeyRing(self.character, self.item) or self.destContainer
                end
                return false
            end
        end

        
        local loot = getPlayerLoot(self.character:getPlayerNum())
        local mingler = loot:getMingler(self.destContainer:getType())
        if mingler then
            -- default to the floor
            self.destContainer = mingler:canPutIn({self.item}) or ISInventoryPage.GetFloorContainer(self.character:getPlayerNum())
        end
        return _ISInventoryTransferAction_waitToStart(self)
    end
end)

------------------------------------------
-- Long OVERRIDES
------------------------------------------
Events.OnGameStart.Add(function()
    local _ISInventoryPage_update = ISInventoryPage.update
    function ISInventoryPage:update()
        _ISInventoryPage_update(self)

        ------------------------------------------
        -- Mingler
        if not self.onCharacter then
            -- Clear highlighted inventories
            for _,v in ipairs(self.coloredInvs) do
                if v:getParent() then
                    v:getParent():setHighlighted(false)
                end
            end
            table.wipe(self.coloredInvs)

            local mingle = self:getMingler(self.inventory:getType())
            if mingle then
                if not self.isCollapsed then
                    -- highlight all inventories
                    
                    for _,v in ipairs(mingle.invs) do
                        if v:getParent() and (instanceof(v:getParent(), "IsoObject") or instanceof(v:getParent(), "IsoDeadBody")) then
                            v:getParent():setHighlighted(true, false)
                            v:getParent():setHighlightColor(getCore():getObjectHighlitedColor())
                            table.insert(self.coloredInvs, v)
                        end
                    end
                end
            end
            local inv = getPlayerInventory(self.player)
            local mnglr = inv:getMingler(inv.inventory:getType())
            if mnglr then
                self.lootAll:setVisible(false)
            else
                self.lootAll:setVisible(true)
            end
        else
            local mingle = self:getMingler(self.inventory:getType())
            if mingle and mingle.spiffI == -1 then
                self.transferAll:setVisible(false)
            else
                self.transferAll:setVisible(true)
            end
        end
        ------------------------------------------

        if not spiff.config.enabled then
            return
        end

        self.closeButton:setVisible(false)
        self.infoButton:setVisible(false)
        self.pinButton:setVisible(false)
        self.collapseButton:setVisible(false)
        self.resizeWidget:setVisible(false)

        if not self.isMouse then
            return
        end
        
        ------------------------------------------
        self.collapseCounter = 0

        self.wasVisible = not self.isCollapsed

        if not self.onCharacter and not self.isCollapsed and self.inventoryPane.inventory:getType() == "floor" and self.inventoryPane.inventory:getItems():isEmpty() then
            if self.autoHide and self.holdOpen and not self.prevMouse and not spiff.config.mouseHide then
                self:Collapse(true, "No Floor Items")
            end
        end

        if not self.isCollapsed then

            if not self.fVisible then
                -- When we stop dragging, set panel to close after next mouseout or click, or set to tie with our friend
                if (not ISMouseDrag.dragging or #ISMouseDrag.dragging == 0) then
                    if self.fromDrag then
                        self.fromDrag = false
                        self.autoHide = true
                        self.wasDrag = self.friend.mouseOver
                        self.holdOpen = not self.wasDrag
                    end

                    
                    if self.toDrag then 
                        -- If we're not dragging anything and we're not moused over and not from where we started, close
                        if not self.mouseOver then
                            self.toDrag = false
                            self.autoHide = true
                        end

                        -- If we're no longer dragging items, but we're still on our window
                        if self:isMouseInBuffer() then
                            self.toDrag = false
                        end
                    end
                else
                    -- If we have dragged items, but we're not in our window
                    if  self.toDrag and not self:isMouseInBuffer() then
                        self.toDrag = false
                        self.autoHide = true
                    end
                end

            end

            -- If we should autohide
            --- prevmouse is to not have this happen immediately, we need a tick for other logic to kick in on state change
            --- holdOpen should prevent the window from closing if we click on an object
            --- We do this here so we can check the mouse location with our buffer
            if not self.fVisible and not spiff.config.mouseHide and self.autoHide 
                and not self.prevMouse and not self.holdOpen and not self.fromDrag 
                and not self.toDrag and not self.wasDrag and not self:isMouseInBuffer() 
                and not getPlayerContextMenu(self.player):isReallyVisible() then
                self:Collapse(true, "Autohide")
            end

        else
            
            -- If we are dragging items from the other inventory to our window
            if not self.fVisible then
                if (ISMouseDrag.dragging and #ISMouseDrag.dragging > 0) and not self.fromDrag and self:isMouseInBuffer() then
                    self:Collapse(false, "From Drag!")
                    self.toDrag = true
                    self.autoHide = true
                end

                -- If mouse is at the top of the screen, show. but not when esc is used, or when a context menu is visible, or right mouse button is down
                if not self.toDrag and not self.fromDrag and not getSpecificPlayer(self.player):isAiming() and not self.collapsing
                and not MainScreen.instance:isVisible() and not getPlayerContextMenu(self.player):isReallyVisible() then
                    if not self.friend.wasVisible then
                        if self:isMouseInTop() then
                            self:Collapse(false, "MouseMoveIn")
                            self.autoHide = true
                        end
                    else
                        if self:isMouseIn() then
                            self:Collapse(false, "MouseMoveInFriend")
                            self.autoHide = true
                        end
                    end
                end
            else
                self:Collapse(false, "force visible")
            end
        end

        if self.collapsing then
            self.collapsing = false
        end

        --self:syncButtonsLoc()
    end
end)