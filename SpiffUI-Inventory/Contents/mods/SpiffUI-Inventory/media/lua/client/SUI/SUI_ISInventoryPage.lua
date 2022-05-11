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

local _ISInventoryPage_update = ISInventoryPage.update
function ISInventoryPage:update()
    if not spiff.config.enabled then
        _ISInventoryPage_update(self)
        return
    end

    if not self.isMouse then
        _ISInventoryPage_update(self)
        ------------------------------------------
        self.closeButton:setVisible(false)
        self.infoButton:setVisible(false)
        self.pinButton:setVisible(false)
        self.collapseButton:setVisible(false)
        self.resizeWidget:setVisible(false)
        return
    end

    if not self.onCharacter then
        if self.coloredInv and (self.inventory ~= self.coloredInv or self.isCollapsed) then
            if self.coloredInv:getParent() then
                self.coloredInv:getParent():setHighlighted(false)
            end
            self.coloredInv = nil;
        end

        if not self.isCollapsed and self.inventory:getParent() and (instanceof(self.inventory:getParent(), "IsoObject") or instanceof(self.inventory:getParent(), "IsoDeadBody")) then
            self.inventory:getParent():setHighlighted(true, false);
            self.inventory:getParent():setHighlightColor(getCore():getObjectHighlitedColor());
            self.coloredInv = self.inventory;
        end
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
        -- When we stop dragging, set panel to close after next mouseout or click, or set to tie with our friend
        if not self.fVisible and (not ISMouseDrag.dragging or #ISMouseDrag.dragging == 0) and self.fromDrag then
            self.fromDrag = false
            self.autoHide = true
            self.wasDrag = self.friend.mouseOver
            self.holdOpen = not self.wasDrag
        end

        -- If we're not dragging anything and we're not moused over and not from where we started, close
        if not self.fVisible and (not ISMouseDrag.dragging or #ISMouseDrag.dragging == 0) and self.toDrag and not self.mouseOver then
            self.toDrag = false
            self.autoHide = true
        end

        -- If we have dragged items, but we're not in our window
        if not self.fVisible and (ISMouseDrag.dragging and #ISMouseDrag.dragging > 0) and self.toDrag and not self:isMouseInBuffer() then
            self.toDrag = false
            self.autoHide = true
        end

        -- If we're no longer dragging items, but we're still on our window
        if not self.fVisible and (not ISMouseDrag.dragging or #ISMouseDrag.dragging == 0) and self.toDrag and self:isMouseInBuffer() then
            self.toDrag = false
        end

        -- If we should autohide
        --- prevmouse is to not have this happen immediately, we need a tick for other logic to kick in on state change
        --- holdOpen should prevent the window from closing if we click on an object
        --- We do this here so we can check the mouse location with our buffer
        if not self.fVisible and not spiff.config.mouseHide and self.autoHide and not self.prevMouse and not self.holdOpen and not self.fromDrag and not self.toDrag and not self.wasDrag and not self:isMouseInBuffer() then
            self:Collapse(true, "Autohide")
        end

    else
        
        -- If we are dragging items from the other inventory to our window
        if not self.fVisible and (ISMouseDrag.dragging and #ISMouseDrag.dragging > 0) and not self.fromDrag and self:isMouseInBuffer() then
            self:Collapse(false, "From Drag!")
            self.toDrag = true
            self.autoHide = true
        end

        -- If mouse is at the top of the screen, show
        if not self.fVisible and not self.toDrag and not self.fromDrag and not isMouseButtonDown(1) then
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

        if self.fVisible then
            self:Collapse(false, "force visible")
        end
    end

------------------------------------------
    if not self.onCharacter then
        -- add "remove all" button for trash can/bins
        self.removeAll:setVisible(self:isRemoveButtonVisible())

        local playerObj = getSpecificPlayer(self.player)
        if self.lastDir ~= playerObj:getDir() then
            self.lastDir = playerObj:getDir()
            self:refreshBackpacks()
        elseif self.lastSquare ~= playerObj:getCurrentSquare() then
            self.lastSquare = playerObj:getCurrentSquare()
            self:refreshBackpacks()
        end

        -- If the currently-selected container is locked to the player, select another container.
        local object = self.inventory and self.inventory:getParent() or nil
        if #self.backpacks > 1 and instanceof(object, "IsoThumpable") and object:isLockedToCharacter(playerObj) then
            local currentIndex = self:getCurrentBackpackIndex()
            local unlockedIndex = self:prevUnlockedContainer(currentIndex, false)
            if unlockedIndex == -1 then
                unlockedIndex = self:nextUnlockedContainer(currentIndex, false)
            end
            if unlockedIndex ~= -1 then
                self:selectContainer(self.backpacks[unlockedIndex])
                if playerObj:getJoypadBind() ~= -1 then
                    self.backpackChoice = unlockedIndex
                end
            end
        end
    end

	self:syncToggleStove()
------------------------------------------
    self.closeButton:setVisible(false)
    self.infoButton:setVisible(false)
    self.pinButton:setVisible(false)
    self.collapseButton:setVisible(false)
    self.resizeWidget:setVisible(false)
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
    if self.isCollapsed and isMouseButtonDown(1)  then
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
                _ISInventoryPage_setVisible(self, false)
                _ISInventoryPage_setVisible(self.friend, false)
            end
        end
    else
        if isClient() and not self.onCharacter then
            self.inventoryPane.inventory:requestSync()
        end
        self:clearMaxDrawHeight()
        self.collapseCounter = 0
        if spiff.config.enabled then
            _ISInventoryPage_setVisible(self, true)
            _ISInventoryPage_setVisible(self.friend, true)
        end
    end
end

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
    local state = not player.isCollapsed

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