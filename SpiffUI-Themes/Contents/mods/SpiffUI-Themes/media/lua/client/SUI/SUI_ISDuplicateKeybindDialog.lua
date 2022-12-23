SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISDuplicateKeybindDialog_createChildren = ISDuplicateKeybindDialog.createChildren
function ISDuplicateKeybindDialog:createChildren()
    _ISDuplicateKeybindDialog_createChildren(self)
    if not spiff.config.enabled then
        return
    end

    local theme = spiff.GetTheme()

    self.clear.borderColor = spiff.GetColor(theme.Border.Option)
    self.keep.borderColor = spiff.GetColor(theme.Border.Option)
    self.cancel.borderColor = spiff.GetColor(theme.Border.Option)
end