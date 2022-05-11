------------------------------------------
-- SpiffUI Radials Module
------------------------------------------
SpiffUI = SpiffUI or {}

-- Register our inventory
local spiff = SpiffUI:Register("radials")

local rOptions = {
    consume = {
        [1] = 1,
        [2] = 0.5,
        [3] = 0.25,
        [4] = 0,
        [5] = -1
    },
    craft = {
        [1] = 0,
        [2] = 1,
        [3] = -1
    }
}

------------------------------------------
-- Add functions 
---- Used later
------------------------------------------
spiff.functions = {}

------------------------------------------
-- Main Functions
------------------------------------------

local function SpiffUIOnGameStart() 
    spiff.filters = {
        smoke = {
            ["cigarettes"] = {
                -- Smoker Homemade
                ["SMHomemadeCigarette2"] = "",
                ["SMHomemadeCigarette"] = "",
                -- Smoker Cigs
                ["SMCigarette"] = "",
                ["SMCigaretteLight"] = "",
                ["SMPCigaretteMenthol"] = "",
                ["SMPCigaretteGold"] = "",
                -- MCM Cigs
                ["CigsCigaretteReg"] = "",
                ["CigsCigaretteLite"] = "",
                ["CigsCigaretteReg"] = "",
                ["CigsCigaretteReg"] = "",
                -- Greenfire Cigs
                ["GFCigarette"] = "",
            },
            ["butts"] = {
                -- Smoker Butts
                ["SMButt"] = "",
                ["SMButt2"] = "",
                -- MCM Butts 
                ["CigsButtReg"] = "",
                ["CigsButtLite"] = "",
                ["CigsButtMent"] = "",
                ["CigsButtGold"] = "",
            },
            ["openedPacks"] = {
                -- Smoker Open Pack
                ["SMPack"] = "SM.SMCigarette",
                ["SMPackLight"] = "SM.SMCigaretteLight",
                ["SMPackMenthol"] = "SM.SMPCigaretteMenthol",
                ["SMPackGold"] = "SM.SMPCigaretteGold",
                -- MCM Open Pack
                ["CigsOpenPackReg"] = "Cigs.CigsCigaretteReg",
                ["CigsOpenPackLite"] = "Cigs.CigsCigaretteLite",
                ["CigsOpenPackMent"] = "Cigs.CigsCigaretteMent",
                ["CigsOpenPackGold"] = "Cigs.CigsCigaretteGold",
            },
            ["closedIncompletePacks"] = {
                -- Smoker Random Packs (Base.Cigarettes only)
                -- MCM Random packs (also Base.Cigarettes)
                ["CigsSpawnPackLite"] = "Cigs.CigsOpenPackLite",
                ["CigsSpawnPackMent"] = "Cigs.CigsOpenPackMent",
                ["CigsSpawnPackGold"] = "Cigs.CigsOpenPackGold",
            },
            ["closedPacks"] = {
                --Smoker Full Pack
                ["SMFullPack"] = "SM.SMPack", 
                ["SMFullPackLight"] = "SM.SMPackLight",
                ["SMFullPackMenthol"] = "SM.SMPackMenthol",
                ["SMFullPackGold"] = "SM.SMPackGold",
                -- MCM Full Pack
                ["CigsClosedPackReg"] = "Cigs.CigsOpenPackReg",
                ["CigsClosedPackLite"] = "Cigs.CigsOpenPackLite",
                ["CigsClosedPackMent"] = "Cigs.CigsOpenPackMent",
                ["CigsClosedPackGold"] = "Cigs.CigsOpenPackGold",
                --Greenfire Pack
                ["GFCigarettes"] = "Greenfire.GFCigarette",
            },
            ["openedCartons"] = {
                --Greenfire Cartons
                ["GFUsedCigaretteCarton"] = "Greenfire.GFCigarettes",
            },
            ["cartons"] = {
                --Smoker Carton
                ["SMCartonCigarettes"] = "SM.SMFullPack",
                ["SMCartonCigarettesLight"] = "SM.SMFullPackLight",
                ["SMCartonCigarettesMenthol"] = "SM.SMFullPackMenthol",
                ["SMCartonCigarettesGold"] = "SM.SMFullPackGold",
                -- MCM Carton
                ["CigsCartonReg"] = "Cigs.CigsClosedPackReg",
                ["CigsCartonLite"] = "Cigs.CigsClosedPackLite",
                ["CigsCartonMent"] = "Cigs.CigsClosedPackMent",
                ["CigsCartonGold"] = "Cigs.CigsClosedPackGold",
                --Greenfire Cartons
                ["GFCigaretteCarton"] = "Greenfire.GFCigarettes",
            },
            ["gum"] = {
                -- Smoker Gum
                ["SMGum"] = "",
            },
            ["gumBlister"] = {
                -- Smoker Gum pack
                ["SMNicorette"] = "SM.SMGum",
            },
            ["gumPack"] = {
                -- Smoker Gum Carton
                ["SMNicoretteBox"] = "SM.SMNicorette"
            }
        },
        smokecraft = {
            ["Tobacco"] = "misc",
            ["Cannabis"] = "misc",
            ["CannabisShake"] = "misc",
            ["Hashish"] = "misc",
            ["CigarLeaf"] = "misc",
            ["SMPinchTobacco"] = "misc",
            ["SMSmallHandfulTobacco"] = "misc",
            ["SMHandfulTobacco"] = "misc",
            ["SMPileTobacco"] = "misc",
            ["SMBigPileTobacco"] = "misc",
            ["SMTobaccoPouches"] = "misc",
            ["FreshUnCanna"] = "misc",
            ["DryUnCanna"] = "misc",
            ["FreshTCanna"] = "misc",
            ["DryTCanna"] = "misc",
            ["FreshCannabisFanLeaf"] = "misc",
            ["DryCannabisFanLeaf"] = "misc",
            ["FreshCannabisSugarLeaf"] = "misc",
            ["DryCannabisSugarLeaf"] = "misc",
            ["CannaJar"] = "misc",
            ["CannaJar2"] = "misc",
            ["CannaJar3"] = "misc",
            ["CannaJar4"] = "misc",
            ["UnCannaJar"] = "misc",
            ["UnCannaJar2"] = "misc",
            ["UnCannaJar3"] = "misc",
            ["UnCannaJar4"] = "misc",
            ["Cannabis"] = "misc",
            ["OzCannabis"] = "misc",
            ["KgCannabis"] = "misc",
            ["CannabisShake"] = "misc",
            ["FreshBTobacco"] = "misc",
            ["DryBTobacco"] = "misc",
            ["SMSmokingBlend"] = "misc",       
        }, 
        eat = {
            ["Cannabis"] = true
        },
        smokeables = {
            ["Bong"] = "misc",
            ["SmokingPipe"] = "misc",
            ["RollingPapers"] = "misc",
            ["GFGrinder"] = "misc",
            ["BluntWrap"] = "misc",
            ["SMFilter"] = "misc"
        },
        firstAid = {
            ["Bandage"] = true,
            ["Bandaid"] = true, 
            ["RippedSheets"] = true, 
            ["Disinfectant"] = true, 
            ["Needle"] = true, 
            ["Thread"] = true, 
            ["SutureNeedle"] = true, 
            ["Tweezers"] = true, 
            ["SutureNeedleHolder"] = true, 
            ["Splint"] = true, 
            ["TreeBranch"] = true, 
            ["WoodenStick"] = true, 
            ["PlantainCataplasm"] = true, 
            ["WildGarlicCataplasm"] = true,
            ["ComfreyCataplasm"] = true
        },
        firstAidCraft = {
            ["Bandage"] = true,
            ["BandageDirty"] = true,
            ["Bandaid"] = true, 
            ["RippedSheets"] = true,
            ["RippedSheetsDirty"] = true,
            ["Disinfectant"] = true, 
            ["Needle"] = true, 
            ["Thread"] = true, 
            ["SutureNeedle"] = true, 
            ["Tweezers"] = true, 
            ["SutureNeedleHolder"] = true, 
            ["Splint"] = true, 
            ["TreeBranch"] = true, 
            ["WoodenStick"] = true, 
            ["PlantainCataplasm"] = true, 
            ["WildGarlicCataplasm"] = true,
            ["ComfreyCataplasm"] = true
        }
    }

    -- Lets add the base Cigs
    if getActivatedMods():contains('Smoker') then
        spiff.filters.smoke["closedIncompletePacks"]["Cigarettes"] = "SM.SMPack"
    elseif getActivatedMods():contains('MoreCigsMod') then
        spiff.filters.smoke["closedIncompletePacks"]["Cigarettes"] = "Cigs.CigsOpenPackReg"
    else
        spiff.filters.smoke["cigarettes"]["Cigarettes"] = ""
    end

    -- Add Smokes to Smokeables
    for i,_ in pairs(spiff.filters.smoke) do
        for j,k in pairs(spiff.filters.smoke[i]) do
            spiff.filters.smokeables[j] = k
        end
    end

    -- Add Smoke Craft to Smokeables
    for i,j in pairs(spiff.filters.smokecraft) do
        spiff.filters.smokeables[i] = j
    end

    -- Add Smokes to Smoke Craft
    for i,_ in pairs(spiff.filters.smoke) do
        if not luautils.stringStarts(i, "gum") then
            for j,_ in pairs(spiff.filters.smoke[i]) do
                spiff.filters.smokecraft[j] = "cigs"
            end
        end
    end

    spiff.rFilters = {
        smoke = {
            butts = {
                -- Smoker Butts
                ["SMButt"] = true,
                ["SMButt2"] = true,
                -- MCM Butts 
                ["CigsButtReg"] = true,
                ["CigsButtLite"] = true,
                ["CigsButtMent"] = true,
                ["CigsButtGold"] = true
            },
            gum = {
                -- Smoker Gum
                ["SMGum"] = true,
                -- Smoker Gum pack
                ["SMNicorette"] = true,
                -- Smoker Gum Carton
                ["SMNicoretteBox"] = true                
            }
        },
        smokecraft = {
            dismantle = {
                ["Unload"] = true,
                ["Dismantle"] = true,
                ["Break"] = true,
                ["Remove"] = true,
                ["Unpack"] = true
            },
            cigpacks = {
                ["Put"] = true,
                ["Take"] = true,
                ["Open"] = true,
                ["Close"] = true
            },
            always = {
                ["Convert"] = true
            }
        }
    }
end

local function SpiffUIBoot()

    spiff.config = {
        showTooltips = true,
        smokeShowButts = true,
        smokeShowGum = true,
        smokeCraftShowDismantle = true,
        smokeCraftShowCigPacks = true,
        smokeCraftAmount = -1,
        craftShowEquipped = false,
        craftShowSmokeables = false,
        craftShowMedical = false,
        craftAmount = -1,
        craftSwitch = true,
        craftFilterUnique = true,
        equipShowDrop = true,
        equipShowAllRepairs = false,
        equipShowClothingActions = true,
        equipShowRecipes = true,
        repairShowEquipped = false,
        repairShowHotbar = true,
        firstAidCraftAmount = -1,
        eatAmount = 0,
        drinkAmount = 0,
        eatQuickAmount = 1,
        drinkQuickAmount = 1
    }

    if ModOptions and ModOptions.getInstance then
        local function apply(data)
            local options = data.settings.options
            spiff.config.showTooltips = options.showTooltips

            spiff.config.smokeShowNow = options.smokeShowNow
            spiff.config.smokeShowButts = options.smokeShowButts
            spiff.config.smokeShowGum = options.smokeShowGum

            spiff.config.smokeCraftShowDismantle = options.smokeCraftShowDismantle
            spiff.config.smokeCraftShowCigPacks = options.smokeCraftShowCigPacks

            spiff.config.craftSwitch = options.craftSwitch
            spiff.config.craftShowEquipped = options.craftShowEquipped
            spiff.config.craftShowSmokeables = options.craftShowSmokeables
            spiff.config.craftShowMedical = options.craftShowMedical
            spiff.config.craftFilterUnique = options.craftFilterUnique

            spiff.config.eatShowNow = options.eatShowNow
            spiff.config.drinkShowNow = options.drinkShowNow
            spiff.config.pillsShowNow = options.pillsShowNow

            spiff.config.equipShowDrop = options.equipShowDrop
            spiff.config.equipShowAllRepairs = options.equipShowAllRepairs
            spiff.config.equipShowClothingActions = options.equipShowClothingActions
            spiff.config.equipShowRecipes = options.equipShowRecipes

            spiff.config.repairShowEquipped = options.repairShowEquipped
            spiff.config.repairShowHotbar = options.repairShowHotbar

            spiff.config.smokeCraftAmount = rOptions.craft[options.smokeCraftAmount]
            spiff.config.craftAmount = rOptions.craft[options.craftAmount]
            spiff.config.eatAmount = rOptions.consume[options.eatAmount]
            spiff.config.eatQuickAmount = rOptions.consume[options.eatQuickAmount]
            spiff.config.drinkAmount = rOptions.consume[options.drinkAmount]
            spiff.config.drinkQuickAmount = rOptions.consume[options.drinkQuickAmount]

            SpiffUI.equippedItem["Craft"] = not options.hideCraftButton
        end

        local function applyGame(data)
            apply(data)
            local options = data.settings.options
            SpiffUI:updateEquippedItem()
        end

        local SETTINGS = {
            options_data = {
                showTooltips = {
                    name = "UI_ModOptions_SpiffUI_showTooltips",
                    default = true,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_showTooltips"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                hideCraftButton = {
                    name = "UI_ModOptions_SpiffUI_hideCraftButton",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = applyGame,
                },
                eatShowNow = {
                    name = "UI_ModOptions_SpiffUI_eatShowNow",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_eatShowNow"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                eatAmount = {
                    getText("UI_amount_SpiffUI_One"), getText("UI_amount_SpiffUI_Half"),
                    getText("UI_amount_SpiffUI_Quarter"), getText("UI_amount_SpiffUI_Ask"),
                    getText("UI_amount_SpiffUI_Full"),
    
                    name = "UI_ModOptions_SpiffUI_eatAmount",
                    default = 4,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                eatQuickAmount = {
                    getText("UI_amount_SpiffUI_One"), getText("UI_amount_SpiffUI_Half"),
                    getText("UI_amount_SpiffUI_Quarter"), getText("UI_amount_SpiffUI_Full"),
    
                    name = "UI_ModOptions_SpiffUI_eatQuickAmount",
                    default = 1,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                drinkShowNow = {
                    name = "UI_ModOptions_SpiffUI_drinkShowNow",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_drinkShowNow"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                drinkAmount = {
                    getText("UI_amount_SpiffUI_One"), getText("UI_amount_SpiffUI_Half"),
                    getText("UI_amount_SpiffUI_Quarter"), getText("UI_amount_SpiffUI_Ask"),
                    getText("UI_amount_SpiffUI_Full"),

                    name = "UI_ModOptions_SpiffUI_drinkAmount",
                    default = 4,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                drinkQuickAmount = {
                    getText("UI_amount_SpiffUI_One"), getText("UI_amount_SpiffUI_Half"),
                    getText("UI_amount_SpiffUI_Quarter"), getText("UI_amount_SpiffUI_Full"),
                    
                    name = "UI_ModOptions_SpiffUI_drinkQuickAmount",
                    default = 1,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                pillsShowNow = {
                    name = "UI_ModOptions_SpiffUI_pillsShowNow",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_pillsShowNow"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                smokeShowNow = {
                    name = "UI_ModOptions_SpiffUI_smokeShowNow",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_smokeShowNow"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                smokeShowButts = {
                    name = "UI_ModOptions_SpiffUI_smokeShowButts",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                smokeShowGum = {
                    name = "UI_ModOptions_SpiffUI_smokeShowGum",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                smokeCraftShowDismantle = {
                    name = "UI_ModOptions_SpiffUI_smokeCraftShowDismantle",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                smokeCraftShowCigPacks = {
                    name = "UI_ModOptions_SpiffUI_smokeCraftShowCigPacks",
                    default = false,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                smokeCraftAmount = {
                    getText("UI_amount_SpiffUI_One"), getText("UI_amount_SpiffUI_All"),
                    getText("UI_amount_SpiffUI_Ask"),
                    
                    name = "UI_ModOptions_SpiffUI_smokeCraftAmount",
                    default = 3,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                craftSwitch = {
                    name = "UI_ModOptions_SpiffUI_craftSwitch",
                    default = true,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_CraftingWheelSwitch"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                craftShowEquipped = {
                    name = "UI_ModOptions_SpiffUI_craftShowEquipped",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_craftShowEquipped"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                craftShowSmokeables = {
                    name = "UI_ModOptions_SpiffUI_craftShowSmokeables",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_craftShowSmokeables"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                craftShowMedical = {
                    name = "UI_ModOptions_SpiffUI_craftShowMedical",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_craftShowMedical"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                craftFilterUnique = {
                    name = "UI_ModOptions_SpiffUI_craftFilterUnique",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                craftAmount = {
                    getText("UI_amount_SpiffUI_One"), getText("UI_amount_SpiffUI_All"),
                    getText("UI_amount_SpiffUI_Ask"),
                    
                    name = "UI_ModOptions_SpiffUI_craftAmount",
                    default = 3,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                equipShowDrop = {
                    name = "UI_ModOptions_SpiffUI_equipShowDrop",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                equipShowAllRepairs = {
                    name = "UI_ModOptions_SpiffUI_equipShowAllRepairs",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_equipShowAllRepairs"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                equipShowClothingActions = {
                    name = "UI_ModOptions_SpiffUI_equipShowClothingActions",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                equipShowRecipes = {
                    name = "UI_ModOptions_SpiffUI_equipShowRecipes",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                repairShowEquipped = {
                    name = "UI_ModOptions_SpiffUI_repairShowEquipped",
                    default = false,
                    tooltip = getText("UI_ModOptions_SpiffUI_tooltip_repairShowEquipped"),
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                repairShowHotbar = {
                    name = "UI_ModOptions_SpiffUI_repairShowHotbar",
                    default = true,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply,
                },
                firstAidCraftAmount = {
                    getText("UI_amount_SpiffUI_One"), getText("UI_amount_SpiffUI_All"),
                    getText("UI_amount_SpiffUI_Ask"),
                    
                    name = "UI_ModOptions_SpiffUI_firstAidCraftAmount",
                    default = 3,
                    OnApplyMainMenu = apply,
                    OnApplyInGame = apply
                }
            },
            mod_id = "SpiffUI-Rads",
            mod_shortname = "SpiffUI-Rads",
            mod_fullname = getText("UI_Name_SpiffUI_Radials")
        }

        local oInstance = ModOptions:getInstance(SETTINGS)
        ModOptions:loadFile()

        Events.OnPreMapLoad.Add(function()
            apply({settings = SETTINGS})
        end)
    end

    spiff.icons = {
        [1] = getTexture("media/SpiffUI/1.png"),
        [2] = getTexture("media/SpiffUI/1-2.png"),
        [3] = getTexture("media/SpiffUI/1-4.png"),
        [4] = getTexture("media/SpiffUI/ALL.png"),
        [5] = getTexture("media/SpiffUI/FULL.png"),
        ["unequip"] = getTexture("media/ui/Icon_InventoryBasic.png"),
        ["drop"] = getTexture("media/ui/Container_Floor.png")
    }

    SpiffUI:AddKeyDisable("Toggle Inventory")
    SpiffUI:AddKeyDisable("Crafting UI")
    SpiffUI:AddKeyDisable("SpiffUI_Inv")
    SpiffUI:AddKeyDisable("NF Smoke")

    SpiffUI:AddKeyDefault("Toggle Moveable Panel Mode", 0)
    SpiffUI:AddKeyDefault("Display FPS", 0)

    print(getText("UI_Hello_SpiffUI_Radials"))
end

spiff.Boot = SpiffUIBoot
spiff.Start = SpiffUIOnGameStart