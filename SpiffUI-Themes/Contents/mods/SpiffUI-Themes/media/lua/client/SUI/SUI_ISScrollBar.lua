SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISScrollBar_createChildren = ISScrollBar.createChildren 
function ISScrollBar:createChildren()
    _ISScrollBar_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    -- 	o.backgroundColor = {r=0, g=0, b=0, a=1.0};
    -- o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};

    local theme = spiff.GetTheme()
    self.backgroundColor  = spiff.GetColor(theme.Background.Option)
    self.borderColor  = spiff.GetColor(theme.Background.Option)
end