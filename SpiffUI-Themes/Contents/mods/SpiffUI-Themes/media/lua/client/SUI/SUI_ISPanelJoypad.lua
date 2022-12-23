SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISPanelJoypad_createChildren = ISPanelJoypad.createChildren
function ISPanelJoypad:createChildren()
    _ISPanelJoypad_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    local theme = spiff.GetTheme()

    local zAlpha = self.backgroundColor.a == 0

	self.backgroundColor = spiff.GetColor(theme.Background.Primary)
    self.borderColor = spiff.GetColor(theme.Border.Primary)
    if zAlpha then
        self.backgroundColor.a = 0
        self.borderColor.a = 0
    end
end