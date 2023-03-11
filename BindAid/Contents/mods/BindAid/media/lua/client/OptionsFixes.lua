-- These fixes are included in other mods, so this prevents from multiple runnings
if not Exterminator then 
    Exterminator = {}
end

if not Exterminator.onEnterFromGame then
    -- Protects Against a Known Options Bug
    -- Thanks Burryaga!
    Exterminator.onEnterFromGame = MainScreen.onEnterFromGame
    function MainScreen:onEnterFromGame()
        Exterminator.onEnterFromGame(self)
        -- Guarantee that when you ENTER the options menu, the game does not think you've already changed your damn options.
        MainOptions.instance.gameOptions.changed = false
    end
end

if not Exterminator.MainOptions_apply then
    -- Adds an event when Game Options are changed
    LuaEventManager.AddEvent("OnSettingsApply")
    Exterminator.MainOptions_apply = MainOptions.apply
    function MainOptions:apply(closeAfter)
        Exterminator.MainOptions_apply(self, closeAfter)
        triggerEvent("OnSettingsApply")
    end
end