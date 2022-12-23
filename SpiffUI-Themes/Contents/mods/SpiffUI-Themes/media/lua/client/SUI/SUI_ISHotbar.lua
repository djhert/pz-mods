SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISHotbar_createChildren = ISHotbar.createChildren
function ISHotbar:createChildren()
    _ISHotbar_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    local theme = spiff.GetTheme()
    
	self.backgroundColor = spiff.GetColor(theme.Background.Primary)
    self.backgroundColor.a = self.backgroundColor.a/2
    self.borderColor = spiff.GetColor(theme.Border.Option)
    self.textColor = spiff.GetColor(theme.Text.Primary)

end