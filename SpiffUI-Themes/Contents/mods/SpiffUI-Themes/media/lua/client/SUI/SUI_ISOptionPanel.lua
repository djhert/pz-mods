SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISOptionPanel_createChildren = ISOptionPanel.createChildren
function ISOptionPanel:createChildren()
    _ISOptionPanel_createChildren(self)
    if not spiff.config.enabled then
        return
    end
    
    local theme = spiff.GetTheme()

	self.backgroundColor = spiff.GetColor(theme.Background.Primary)
    self.borderColor = spiff.GetColor(theme.Border.Primary)
end