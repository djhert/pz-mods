SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")


local _ISWindow_createChildren = ISWindow.createChildren
function ISWindow:createChildren ()
    _ISWindow_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    local theme = spiff.GetTheme()

	self.backgroundColor = spiff.GetColor(theme.Background.Primary)
    self.borderColor = spiff.GetColor(theme.Border.Primary)
end