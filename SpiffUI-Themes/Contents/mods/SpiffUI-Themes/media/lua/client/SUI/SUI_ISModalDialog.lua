SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("themes")

local _ISModalDialog_initialise = ISModalDialog.initialise
function ISModalDialog:initialise()
    _ISModalDialog_initialise(self)
    if not spiff.config.enabled then
        return
    end

    local theme = spiff.GetTheme()

	self.backgroundColor = spiff.GetColor(theme.Background.Primary)
    self.borderColor = spiff.GetColor(theme.Border.Primary)

    -- For the buttons
    self.oborderColor = spiff.GetColor(theme.Border.Option)

    -- Resync the theme
	if self.yesno then
        self.yes.borderColor = spiff.GetColor(self.oborderColor)
        self.no.borderColor = spiff.GetColor(self.oborderColor)
    else
        self.ok.borderColor = spiff.GetColor(self.oborderColor)
    end
end