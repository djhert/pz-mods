------------------------------------------
-- SpiffUI Radials
---- ISFirearmRadialMenu SpiffUI
------------------------------------------
SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

-- This lets us set call the radial without having the wepaon in-hand
---- You must have the weapon equipped in primary in order to do an action though
---- Useful as we can inject a weapon to show
local _ISFirearmRadialMenu_getWeapon = ISFirearmRadialMenu.getWeapon
function ISFirearmRadialMenu:getWeapon()
    if not self.weapon then
        return _ISFirearmRadialMenu_getWeapon(self)
    end
	return self.weapon
end

-- I need to inject our previous page if applicable
local _ISFirearmRadialMenu_display = ISFirearmRadialMenu.display
function ISFirearmRadialMenu:display()
    if self.prev then
        -- set some expected things
        -- there be a previous page
        self.page = 1
        self.maxPage = 1
        self.rmenu = getPlayerRadialMenu(self.playerNum)
        local o = spiff.prevCmd:new(self, getText("UI_radial_SpiffUI_Previous"), getTexture("media/spifcons/prevpage.png"))
        o:fillMenu()       
    end

    local weapon = self:getWeapon()
	if not weapon then return end
    local menu = getPlayerRadialMenu(self.playerNum)
    menu:setRadialImage(weapon:getTexture())
    menu:setRadialText(weapon:getName())

	_ISFirearmRadialMenu_display(self)
end