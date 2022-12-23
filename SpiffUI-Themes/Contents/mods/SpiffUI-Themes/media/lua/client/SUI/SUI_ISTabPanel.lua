SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISTabPanel_createChildren = ISTabPanel.createChildren
function ISTabPanel:createChildren()
    _ISTabPanel_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    local theme = spiff.GetTheme()
    
	self.backgroundColor = spiff.GetColor(theme.Background.Secondary)
    self.borderColor  = spiff.GetColor(theme.Border.Secondary)
    self.textColor  = spiff.GetColor(theme.Text.Primary)

    self.selBackgroundColor = spiff.GetColor(theme.Background.Option)
    self.selBorderColor  = spiff.GetColor(theme.Border.Option)

	if spiff.config.Theme == "Project Zomboid" then
		self.selBackgroundColor = {r=0.3, g=0.3, b=0.3, a=1.0}
	end

    --self.
end

function ISTabPanel:render()
	local newViewList = {};
	local tabDragSelected = -1;
	if self.draggingTab and not self.isDragging and ISTabPanel.xMouse > -1 and ISTabPanel.xMouse ~= self:getMouseX() then -- do we move the mouse since we have let the left button down ?
		self.isDragging = self.allowDraggingTabs;
	end
	local tabWidth = self.maxLength
	local inset = 1 -- assumes a 1-pixel window border on the left to avoid
	local gap = 1 -- gap between tabs
	if self.isDragging and not ISTabPanel.mouseOut then
		-- we fetch all our view to remove the tab of the view we're dragging
		for i,viewObject in ipairs(self.viewList) do
			if i ~= (self.draggingTab + 1) then
				table.insert(newViewList, viewObject);
			else
				ISTabPanel.viewDragging = viewObject;
			end
		end
		-- in wich tab slot are we dragging our tab
		tabDragSelected = self:getTabIndexAtX(self:getMouseX()) - 1;
		tabDragSelected = math.min(#self.viewList - 1, math.max(tabDragSelected, 0))
		-- we draw a white rectangle to show where our tab is going to be
		self:drawRectBorder(inset + (tabDragSelected * (tabWidth + gap)), 0, tabWidth, self.tabHeight - 1, 1,1,1,1);
	else -- no dragging, we display all our tabs
		newViewList = self.viewList;
	end

	-- our principal rect, wich display our different view
    ---- I don't think this is ever used, and really it shouldn't be. its an overlay that gets put on top of the child panel. most things i see set this to 0 alpha
	--self:drawRect(0, self.tabHeight, self.width, self.height - self.tabHeight, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	--self:drawRectBorder(0, self.tabHeight, self.width, self.height - self.tabHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	local x = inset;
	if self.centerTabs and (self:getWidth() >= self:getWidthOfAllTabs()) then
		x = (self:getWidth() - self:getWidthOfAllTabs()) / 2
	else
		x = x + self.scrollX
	end
	local widthOfAllTabs = self:getWidthOfAllTabs()
	local overflowLeft = self.scrollX < 0
	local overflowRight = x + widthOfAllTabs > self.width
    local blinkTabsAlphaNotUpdated = true;
	if widthOfAllTabs > self.width then
		self:setStencilRect(0, 0, self.width, self.tabHeight)
	end
	for i,viewObject in ipairs(newViewList) do
		tabWidth = self.equalTabWidth and self.maxLength or viewObject.tabWidth
		-- if we drag a tab over an existing one, we move the other
		if tabDragSelected ~= -1 and i == (tabDragSelected + 1) then
			x = x + tabWidth + gap;
		end
		-- if this tab is the active one, we make the tab btn lighter
		if viewObject.name == self.activeView.name and not self.isDragging and not ISTabPanel.mouseOut then
			--self:drawTextureScaled(ISTabPanel.tabSelected, x, 0, tabWidth, self.tabHeight - 1, self.tabTransparency,1,1,1);
            self:drawRect(x, 0, tabWidth, self.tabHeight - 1, self.selBackgroundColor.a, self.selBackgroundColor.r, self.selBackgroundColor.g, self.selBackgroundColor.b);
            self:drawRectBorder(x, 0, tabWidth, self.tabHeight - 1, self.selBorderColor.a, self.selBorderColor.r, self.selBorderColor.g, self.selBorderColor.b);
        else
            local alpha = self.tabTransparency;
            local shouldBlink = false;
            if self.blinkTabs then
                for j,tab in ipairs(self.blinkTabs) do
                    if tab and tab == viewObject.name then
                        shouldBlink = true;
                    end
                end
            end
            if (self.blinkTab and self.blinkTab == viewObject.name) or (shouldBlink and blinkTabsAlphaNotUpdated) then
                blinkTabsAlphaNotUpdated = false;
                if not self.blinkTabAlpha then
                    self.blinkTabAlpha = self.tabTransparency;
                    self.blinkTabAlphaIncrease = false;
                end

                if not self.blinkTabAlphaIncrease then
                    self.blinkTabAlpha = self.blinkTabAlpha - 0.1 * self.tabTransparency * (UIManager.getMillisSinceLastRender() / 33.3);
                    if self.blinkTabAlpha < 0 then
                        self.blinkTabAlpha = 0;
                        self.blinkTabAlphaIncrease = true;
                    end
                else
                    self.blinkTabAlpha = self.blinkTabAlpha + 0.1 * self.tabTransparency * (UIManager.getMillisSinceLastRender() / 33.3);
                    if self.blinkTabAlpha > self.tabTransparency then
                        self.blinkTabAlpha = self.tabTransparency;
                        self.blinkTabAlphaIncrease = false;
                    end
                end
                alpha = self.blinkTabAlpha;
                --self:drawTextureScaled(ISTabPanel.tabUnSelected, x, 0, tabWidth, self.tabHeight - 1, self.tabTransparency,1,1,1);
                self:drawRect(x, 0, tabWidth, self.tabHeight - 1, alpha, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
                self:drawRectBorder(x, 0, tabWidth, self.tabHeight - 1, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
                --self:drawRect(x, 0, tabWidth, self.tabHeight - 1, alpha, 1, 1, 1);
            elseif shouldBlink then
                alpha = self.blinkTabAlpha;
                --self:drawTextureScaled(ISTabPanel.tabUnSelected, x, 0, tabWidth, self.tabHeight - 1, self.tabTransparency,1,1,1);
                self:drawRect(x, 0, tabWidth, self.tabHeight - 1, alpha, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
                self:drawRectBorder(x, 0, tabWidth, self.tabHeight - 1, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
            else
                self:drawRect(x, 0, tabWidth, self.tabHeight - 1, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
                self:drawRectBorder(x, 0, tabWidth, self.tabHeight - 1, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
			    --self:drawTextureScaled(ISTabPanel.tabUnSelected, x, 0, tabWidth, self.tabHeight - 1, self.tabTransparency,1,1,1);
			    if self:getMouseY() >= 0 and self:getMouseY() < self.tabHeight and self:isMouseOver() and self:getTabIndexAtX(self:getMouseX()) == i then
					viewObject.fade:setFadeIn(true)
				else
					viewObject.fade:setFadeIn(false)
			    end
			    viewObject.fade:update()
                --self:drawRect(x, 0, tabWidth, self.tabHeight - 1, self.selBackgroundColor.a, self.selBackgroundColor.r, self.selBackgroundColor.g, self.selBackgroundColor.b)
                --self:drawRectBorder(x, 0, tabWidth, self.tabHeight - 1, self.selBorderColor.a, self.selBorderColor.r, self.selBorderColor.g, self.selBorderColor.b)
				--self:drawTextureScaled(ISTabPanel.tabSelected, x, 0, tabWidth, self.tabHeight - 1, 0.2 * viewObject.fade:fraction(),1,1,1);
           end
		end
		self:drawTextCentre(viewObject.name, x + (tabWidth / 2), 3, self.textColor.r, self.textColor.g, self.textColor.b, self.textTransparency, UIFont.Small);
		x = x + tabWidth + gap;
	end
	local butPadX = 3
	if overflowLeft then
		local tex = getTexture("media/ui/ArrowLeft.png")
		local butWid = tex:getWidthOrig() + butPadX * 2
		self:drawRect(inset, 0, butWid, self.tabHeight, 1, 0, 0, 0)
		self:drawRectBorder(inset, 0, butWid, self.tabHeight, 1, 1, 1, 1)
		self:drawTexture(tex, inset + butPadX, (self.tabHeight - tex:getHeight()) / 2, 1, 1, 1, 1)
	end
	if overflowRight then
		local tex = getTexture("media/ui/ArrowRight.png")
		local butWid = tex:getWidthOrig() + butPadX * 2
		self:drawRect(self.width - inset - butWid, 0, butWid, self.tabHeight, 1, 0, 0, 0)
		self:drawRectBorder(self.width - inset - butWid, 0, butWid, self.tabHeight, 1, 1, 1, 1)
		self:drawTexture(tex, self.width - butWid + butPadX, (self.tabHeight - tex:getHeight()) / 2, 1, 1, 1, 1)
	end
	if widthOfAllTabs > self.width then
		self:clearStencilRect()
	end
	-- we draw a ghost of our tab we currently dragging
	if self.draggingTab and self.isDragging and not ISTabPanel.mouseOut then
		if self.draggingTab > 0 then
			--self:drawTextureScaled(ISTabPanel.tabSelected, inset + (self.draggingTab * (tabWidth + gap)) + (self:getMouseX() - ISTabPanel.xMouse), 0, tabWidth, self.tabHeight - 1, 0.8,1,1,1);
			self:drawTextCentre(ISTabPanel.viewDragging.name, inset + (self.draggingTab * (tabWidth + gap)) + (self:getMouseX() - ISTabPanel.xMouse) + (tabWidth / 2), 3, 1, 1, 1, 1, UIFont.Normal);
		else
			--self:drawTextureScaled(ISTabPanel.tabSelected, inset + (self:getMouseX() - ISTabPanel.xMouse), 0, tabWidth, self.tabHeight - 1, 0.8,1,1,1);
			self:drawTextCentre(ISTabPanel.viewDragging.name, inset + (self:getMouseX() - ISTabPanel.xMouse) + (tabWidth / 2), 3, 1, 1, 1, 1, UIFont.Normal);
		end
    end
end