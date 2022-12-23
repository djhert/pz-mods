SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

--local _ISPanel_createChildren = ISPanel.createChildren
function ISPanel:createChildren()
    --_ISPanel_createChildren(self)
    if not spiff.config.enabled then
        return
    end
    
    -- The ISPanel is commonly used to make child items within a window or joypad panel
    local theme = spiff.GetTheme()

	self.backgroundColor = spiff.GetColor(theme.Background.Option)
    self.borderColor = spiff.GetColor(theme.Border.Option)
end