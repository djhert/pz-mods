------------------------------------------
-- spiff
--- ISButton
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISButton_setEnable = ISButton.setEnable 
function ISButton:setEnable(bEnabled)
    if not spiff.config.enabled then
        _ISButton_setEnable(self, bEnabled)
        return 
    end
	self.enable = bEnabled;
	if not self.borderColorEnabled then
		self.borderColorEnabled = { r = self.borderColor.r, g = self.borderColor.g, b = self.borderColor.b, a = self.borderColor.a }
	end
	if bEnabled then
		self:setTextureRGBA(1, 1, 1, 1)
		self:setBorderRGBA(
			self.borderColorEnabled.r,
			self.borderColorEnabled.g,
			self.borderColorEnabled.b,
			self.borderColorEnabled.a)
	else
		self:setTextureRGBA(0.3, 0.3, 0.3, 1.0)
		--self:setBorderRGBA(0.7, 0.1, 0.1, 0.7)
	end
end

local _ISButton_render = ISButton.render 
function ISButton:render()
    if not spiff.config.enabled then
        _ISButton_render(self)
        return 
    end

    if self.image ~= nil then
        local alpha = self.textureColor.a;
        if self.blinkImage then
            if not self.blinkImageAlpha then
                self.blinkImageAlpha = 1;
                self.blinkImageAlphaIncrease = false;
            end

            if not self.blinkImageAlphaIncrease then
                self.blinkImageAlpha = self.blinkImageAlpha - 0.1 * (UIManager.getMillisSinceLastRender() / 33.3);
                if self.blinkImageAlpha < 0 then
                    self.blinkImageAlpha = 0;
                    self.blinkImageAlphaIncrease = true;
                end
            else
                self.blinkImageAlpha = self.blinkImageAlpha + 0.1 * (UIManager.getMillisSinceLastRender() / 33.3);
                if self.blinkImageAlpha > 1 then
                    self.blinkImageAlpha = 1;
                    self.blinkImageAlphaIncrease = false;
                end
            end

            alpha = self.blinkImageAlpha;
        end
        if self.forcedWidthImage and self.forcedHeightImage then
            self:drawTextureScaledAspect(self.image, (self.width / 2) - (self.forcedWidthImage / 2), (self.height / 2) - (self.forcedHeightImage / 2),self.forcedWidthImage,self.forcedHeightImage, alpha, self.textureColor.r, self.textureColor.g, self.textureColor.b);
        elseif self.image:getWidthOrig() <= self.width and self.image:getHeightOrig() <= self.height then
            self:drawTexture(self.image, (self.width / 2) - (self.image:getWidthOrig() / 2), (self.height / 2) - (self.image:getHeightOrig() / 2), alpha, self.textureColor.r, self.textureColor.g, self.textureColor.b);
        else
            self:drawTextureScaledAspect(self.image, 0, 0, self.width, self.height, alpha, self.textureColor.r, self.textureColor.g, self.textureColor.b);
        end
    end
    local textW = getTextManager():MeasureStringX(self.font, self.title)
    local height = getTextManager():MeasureStringY(self.font, self.title)
    local x = self.width / 2 - textW / 2;
    if self.isJoypad and self.joypadTexture then
        local texWH = self.joypadTextureWH
        local texX = x - 5 - texWH
        local texY = self.height / 2 - 20 / 2
        texX = math.max(5, texX)
        x = texX + texWH + 5
        self:drawTextureScaled(self.joypadTexture,texX,texY,texWH,texWH,1,1,1,1);
    end
    if self.enable then
        self:drawText(self.title, x, (self.height / 2) - (height/2) + self.yoffset, self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a, self.font);
    elseif self.displayBackground and not self.isJoypad and self.joypadFocused then
        self:drawText(self.title, x, (self.height / 2) - (height/2) + self.yoffset, self.stextColor.r, self.stextColor.g, self.stextColor.b, self.stextColor.a, self.font);
    else
        self:drawText(self.title, x, (self.height / 2) - (height/2) + self.yoffset, self.stextColor.r, self.stextColor.g, self.stextColor.b, self.stextColor.a, self.font);
    end
    if self.overlayText then
        self:drawTextRight(self.overlayText, self.width, self.height - 10, self.textColor.r, self.textColor.g, self.textColor.b, 0.5, UIFont.Small);
    end
    -- call the onMouseOverFunction
    if (self.mouseOver and self.onmouseover) then
        self.onmouseover(self.target, self, x, y);
    end

    if self.textureOverride then
        self:drawTexture(self.textureOverride, (self.width /2) - (self.textureOverride:getWidth() / 2), (self.height /2) - (self.textureOverride:getHeight() / 2), 1, 1, 1, 1);
    end

    if false and self.mouseOver and self.tooltip then
        self:drawRect(self:getMouseX() + 23, self:getMouseY() + 23, getTextManager():MeasureStringX(UIFont.Small, self.tooltip) + 24, 32+24, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, self.backgroundColor.a);
        self:drawRectBorder(self:getMouseX()  + 23, self:getMouseY() + 23, getTextManager():MeasureStringX(UIFont.Small, self.tooltip) + 24, 32+24, self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a);
        self:drawText(self.tooltip, self:getMouseX()  + 23 + 12, self:getMouseY() + 23 + 12, self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a);
    end
end

--local _ISButton_createChildren = ISButton.createChildren 
function ISButton:createChildren()
    --_ISButton_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    -- o.borderColor = {r=0.7, g=0.7, b=0.7, a=1};
    -- o.backgroundColor = {r=0, g=0, b=0, a=1.0};
    -- o.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0}

    local theme = spiff.GetTheme()
    self.backgroundColor = spiff.GetColor(theme.Background.Option)
    if spiff.config.Theme == "Project Zomboid" then
        self.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0}
        self.backgroundColorPressed = spiff.GetColorMod(self.backgroundColorMouseOver, 0.5)
    else
        self.backgroundColorMouseOver = spiff.GetColorMod(theme.Background.Option, 2)
        self.backgroundColorPressed = spiff.GetColorMod(theme.Background.Option, 0.5)
    end
    self.borderColor  = spiff.GetColor(theme.Border.Option)
    
    self.textColor  = spiff.GetColor(theme.Text.Option)
    self.stextColor = spiff.GetColor(theme.Text.Secondary)

    if self.image or self.textureOverride then
        self.backgroundColor.a = 0
        self.borderColor.a = 0
    end
end