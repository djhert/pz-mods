-- Add module
SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

--- 1 loot/transfer button
--- 2 oven button (turn on)
--- 3 - 5 custom buttons 
function ISInventoryPage:getBestButtonX(num)
    -- idk man, people try things
    if num > 5 then
        num = 5
    end
    if num < 1 then
        num = 1
    end

    return self.buttonsX[num]
end

function ISInventoryPage:RegisterButton(extra)
    if not extra then
        return
    end
    if not self.headerButtons then
        self.headerButtons = {}
    end
    table.insert(self.headerButtons, extra)
end

function ISInventoryPage:syncButtonsLoc()
    local visible = 1
    if not self.onCharacter then
        if self.lootAll:isVisible() then
            self.lootAll:setX(self:getBestButtonX(visible))
            --print("Setting lootAll to: " .. self:getBestButtonX(visible))
            visible = visible + 1
        end
        if self.removeAll:isVisible() then
            self.removeAll:setX(self:getBestButtonX(visible))
            --print("Setting removeAll to: " .. self:getBestButtonX(visible))
            visible = visible + 1
        end
        if self.toggleStove:isVisible() then
            self.toggleStove:setX(self:getBestButtonX(visible))
            --print("Setting toggleStove to: " .. self:getBestButtonX(visible))
            visible = visible + 1
        end
    else
        if self.transferAll:isVisible() then
            self.transferAll:setX(self:getBestButtonX(visible))
            visible = visible + 1
        end
    end

    if self.headerButtons then
        for _,j in ipairs(self.headerButtons) do
            if visible > 5 then break end
            if j and j:isVisible() then
                j:setX(self:getBestButtonX(visible))
                --print("Setting extra to: " .. self:getBestButtonX(visible))
                visible = visible + 1
            end
        end
    end
end

local _ISInventoryPage_prerender = ISInventoryPage.prerender
function ISInventoryPage:prerender()

    if not spiff.config.enabled then
        _ISInventoryPage_prerender(self)
        return
    end

    local titleBarHeight = self:titleBarHeight()
    local height = self:getHeight()-titleBarHeight
    if self.isCollapsed then
        height = titleBarHeight
    end

    if not self.isCollapsed then
        -- Draw the main background
        self:drawRect(0, titleBarHeight, self:getWidth(), height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
        
        -- Draw backpack area
        self:drawRect(self:getWidth()-self.buttonSize, titleBarHeight, self.buttonSize, height,  self.sbackgroundColor.a, self.sbackgroundColor.r, self.sbackgroundColor.g, self.sbackgroundColor.b)
    end

    if ISInventoryPage.renderDirty then
        ISInventoryPage.renderDirty = false;
        ISInventoryPage.dirtyUI();
    end   

    -- self.closeButton:setVisible(false)
    -- self.infoButton:setVisible(false)
    -- self.collapseButton:setVisible(false)
    -- self.pinButton:setVisible(false)
    -- self.resizeWidget:setVisible(false)

    -- Draw Titlebar
    self:drawRect(0, 0, self:getWidth(), titleBarHeight, self.hbackgroundColor.a, self.hbackgroundColor.r, self.hbackgroundColor.g, self.hbackgroundColor.b)
    -- Draw Titlebar border
    self:drawRectBorder(0, 0, self:getWidth(), titleBarHeight, self.hborderColor.a, self.hborderColor.r, self.hborderColor.g, self.hborderColor.b)
    
    -- Draw the title on the left
    if self.title then
        self:drawText(self.title, self.titleLoc, 0, 1,1,1,1)
    end

    -- load the current weight of the container
    self.totalWeight = ISInventoryPage.loadWeight(self.inventoryPane.inventory)
    local roundedWeight = round(self.totalWeight, 2)
    local textLoc = self.width - titleBarHeight - 3
    if self.capacity then
        if self.inventoryPane.inventory == getSpecificPlayer(self.player):getInventory() then
            self:drawTextRight(roundedWeight .. " / " .. getSpecificPlayer(self.player):getMaxWeight(), textLoc, 0, 1,1,1,1)
        else
            self:drawTextRight(roundedWeight .. " / " .. self.capacity, textLoc, 0, 1,1,1,1)
        end
    else
        self:drawTextRight(roundedWeight .. "", self.width - 20, 0, 1,1,1,1)
    end 

    self:setStencilRect(0,0,self.width, height)

    self:syncButtonsLoc()
end

------------------------------------------
-- ISInventoryPage:createChildren
local _ISInventoryPage_createChildren = ISInventoryPage.createChildren
function ISInventoryPage:createChildren()
    _ISInventoryPage_createChildren(self)

    self.headerButtons = nil
        
    -- Buttons
    self.buttonsX = {}

    -- assign button locations
    for i=1, 5 do
        if i == 1 then
            local textWid = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_invpage_Transfer_all"))
            local weightWid = getTextManager():MeasureStringX(UIFont.Small, "99.99 / 99.99")
            self.buttonsX[i] = (self:getWidth() - self:titleBarHeight() - 3 - math.max(90, weightWid + 10) - textWid)
        else
            self.buttonsX[i] = (self.buttonsX[i-1] - self.transferAll:getWidth()) - 16
        end
        --print("ButtonsX[" .. i .. "]: " .. self.buttonsX[i])
    end

    self.theme = spiff.GetTheme()
    self.borderColor  = spiff.GetColor(self.theme.Border.Primary)
    self.hborderColor = spiff.GetColor(self.theme.Border.Header)
    self.sborderColor = spiff.GetColor(self.theme.Border.Secondary)
    self.oborderColor = spiff.GetColor(self.theme.Border.Option)

    self.hbackgroundColor = spiff.GetColor(self.theme.Background.Header)
    self.backgroundColor  = spiff.GetColor(self.theme.Background.Primary)
    self.sbackgroundColor = spiff.GetColor(self.theme.Background.Secondary)
    self.obackgroundColor = spiff.GetColor(self.theme.Background.Option)

    self.htextColor = spiff.GetColor(self.theme.Text.Header)
    self.textColor  = spiff.GetColor(self.theme.Text.Primary)
    self.stextColor = spiff.GetColor(self.theme.Text.Secondary)

    self.titleLoc = self.infoButton:getX() + self.infoButton:getWidth() + 4
end

local _ISInventoryPage_render = ISInventoryPage.render
function ISInventoryPage:render()
    if not spiff.config.enabled then
        _ISInventoryPage_render(self)
        return
    end

    local titleBarHeight = self:titleBarHeight()
    local height = self:getHeight() - titleBarHeight
    if self.isCollapsed then
        height = titleBarHeight
    end

    if not self.isCollapsed then
        -- Draw Main Frame
        --self:drawRectBorder(0, titleBarHeight, self:getWidth(), height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
        
        -- Draw backpack Frame
        self:drawRectBorder(self:getWidth()-self.buttonSize, titleBarHeight, self.buttonSize, height, self.sborderColor.a, self.sborderColor.r, self.sborderColor.g, self.sborderColor.b)
    end

    self:clearStencilRect()

    if not self.isCollapsed then
        -- Draw Main Frame
        self:drawRectBorder(0, titleBarHeight-1, self:getWidth(), height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

        local yBottom = self:getHeight() - self.resizeWidget2:getHeight() --titleBarHeight
        -- Draw BottomBar
        self:drawRect(0, yBottom, self:getWidth(), self.resizeWidget2:getHeight(), self.obackgroundColor.a, self.obackgroundColor.r, self.obackgroundColor.g, self.obackgroundColor.b)
        -- Draw BottomBar border
        self:drawRectBorder(0, yBottom, self:getWidth(), self.resizeWidget2:getHeight(), self.oborderColor.a, self.oborderColor.r, self.oborderColor.g, self.oborderColor.b)
    end

    if self.joyfocus then
        self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
        self:drawRectBorder(1, 1, self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
    end

    if self.render3DItems and #self.render3DItems > 0 then
        self:render3DItemPreview();
    end
end