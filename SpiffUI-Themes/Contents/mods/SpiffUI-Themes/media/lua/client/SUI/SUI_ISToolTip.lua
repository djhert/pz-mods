SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISToolTip_createChildren = ISToolTip.createChildren
function ISToolTip:createChildren()
    _ISToolTip_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    local theme = spiff.GetTheme()
    
	self.backgroundColor = {r=0, g=0, b=0, a=0}
    self.borderColor = {r=0, g=0, b=0, a=0}

    self.descriptionPanel.backgroundColor = spiff.GetColor(theme.Background.Option)
    self.descriptionPanel.borderColor = spiff.GetColor(theme.Border.Option)

    self:noBackground()
end