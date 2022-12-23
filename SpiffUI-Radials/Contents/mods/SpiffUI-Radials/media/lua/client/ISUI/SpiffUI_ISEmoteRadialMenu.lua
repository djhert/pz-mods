------------------------------------------
-- SpiffUI Radials
---- ISEmoteRadial SpiffUI
------------------------------------------
SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local _ISEmoteRadialMenu_fillMenu = ISEmoteRadialMenu.fillMenu
function ISEmoteRadialMenu:fillMenu(submenu)
    local menu = getPlayerRadialMenu(self.playerNum)
    if not submenu then
        menu:setRadialImage(ISEmoteRadialMenu.icons["wavehi"])
        menu:setRadialText(getText("UI_SpiffUI_EmoteWheel"))
    else
        menu:setRadialImage(ISEmoteRadialMenu.icons[submenu])
        menu:setRadialText(ISEmoteRadialMenu.menu[submenu].name)
    end

    _ISEmoteRadialMenu_fillMenu(self, submenu)
end