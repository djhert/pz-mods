------------------------------------------
-- SpiffUI Radials
---- ISFirearmRadialMenu getWeapon hack
------------------------------------------

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