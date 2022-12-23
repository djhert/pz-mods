SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISCollapsableWindow_createChildren = ISCollapsableWindow.createChildren
function ISCollapsableWindow:createChildren()
    _ISCollapsableWindow_createChildren(self)
    if not spiff.config.enabled then
        return 
    end

    local theme = spiff.GetTheme()

	self.backgroundColor = spiff.GetColor(theme.Background.Primary)
    self.borderColor = spiff.GetColor(theme.Border.Primary)

    self.hborderColor = spiff.GetColor(theme.Border.Header)
    self.hbackgroundColor = spiff.GetColor(theme.Background.Header)

    --o.widgetTextureColor = {r = 1, g = 0, b = 0, a = 1};

    return o
end

function ISCollapsableWindow:prerender()
	local height = self:getHeight();
	local th = self:titleBarHeight()
	if self.isCollapsed then
		height = th;
    end
    if self.drawFrame then
        self:drawRect(0, 0, self:getWidth(), th, self.hbackgroundColor.a, self.hbackgroundColor.r, self.hbackgroundColor.g, self.hbackgroundColor.b);
        --self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);
        self:drawRectBorder(0, 0, self:getWidth(), th, self.hborderColor.a, self.hborderColor.r, self.hborderColor.g, self.hborderColor.b);
    end
    if self.background and not self.isCollapsed then
		local rh = self:resizeWidgetHeight()
		if not self.resizable or not self.resizeWidget:getIsVisible() then rh = 0 end
        self:drawRect(0, th, self:getWidth(), self.height - th - rh, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    end

	if self.clearStentil then
		self:setStencilRect(0,0,self.width, height);
	end

	if self.title ~= nil and self.drawFrame then
		self:drawTextCentre(self.title, self:getWidth() / 2, 1, 1, 1, 1, 1, self.titleBarFont);
	end
end