SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISLabel_createChildren = ISLabel.createChildren
function ISLabel:createChildren()
    _ISLabel_createChildren(self)
    if not spiff.config.enabled then
        return 
    end
    
    local theme = spiff.GetTheme()

	self.backgroundColor = spiff.GetColor(theme.Background.Primary)
    self.borderColor = spiff.GetColor(theme.Border.Primary)

    local c = spiff.GetColor(theme.Text.Primary)
    self.r = c.r
    self.g = c.g
    self.b = c.b
    self.a = c.a
end