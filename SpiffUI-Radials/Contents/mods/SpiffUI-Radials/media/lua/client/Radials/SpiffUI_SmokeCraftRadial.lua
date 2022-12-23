------------------------------------------
-- SpiffUI Smoke Actions
----  Radial Menu for drinks
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUISmokeCraftRadial = spiff.radialmenu:derive("SpiffUISmokeCraftRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[7] = SpiffUISmokeCraftRadial
------------------------------------------

local SpiffUISmokeCraftRadialCommand = spiff.radialcommand:derive("SpiffUISmokeCraftRadialCommand")

function SpiffUISmokeCraftRadialCommand:Action()
    ISInventoryPaneContextMenu.OnCraft(self.item, self.recipe, self.player:getPlayerNum(), self.amount)
end

function SpiffUISmokeCraftRadialCommand:new(menu, recipe)
    local texture = InventoryItemFactory.CreateItem(recipe.recipe:getResult():getFullType()):getTexture()

    local tooltip = {
        recipe = recipe.recipe,
        item = recipe.item,
        isRecipe = true
    }

    local o = spiff.radialcommand.new(self, menu, recipe.recipe:getName(), texture, tooltip)

    o.recipe = recipe.recipe
    o.item = recipe.item

    o.amount = false

    -- If we should and and we can make more than 1
    if spiff.config.smokeCraftAmount == -1 and recipe.num > 1 then
        -- Ask
        o.shouldAsk = 2
    elseif spiff.config.smokeCraftAmount == 1 then
        -- Craft All
        o.amount = true
    end

    return o
end

local function getRecipes(packs, player)
    local items = {}
    local recipes = {}
    -- This will get cigs, or
    for p = 0, packs:size() - 1 do
        local pack = packs:get(p)
        local ps = pack:getAllEval(function(item)
            return (spiff.filters.smokecraft[item:getType()] ~= nil or item:getCustomMenuOption() == "Smoke")
        end)
        if ps and ps:size() > 0 then
            for i = 0, ps:size() - 1 do
                local item = ps:get(i)
                if item then
                    if not items[item:getType()] then
                        items[item:getType()] = {
                            item = item,
                            cat = spiff.filters.smokecraft[item:getType()] or "misc"
                        }
                    end
                end
            end
        end
    end

    local count = 0
    for _,item in pairs(items) do
        local recs = RecipeManager.getUniqueRecipeItems(item.item, player, packs)
        for i = 0, recs:size() - 1 do
            local recipe = recs:get(i)
            if item.cat == "misc" and item.item:getStressChange() > -0.01 then
                item.cat = "butts"
            end
            recipes[count] = {
                recipe = recipe,
                num = RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, player, packs, item.item),
                item = item.item,
                cat = item.cat
            }
            count = count + 1
        end
    end
    return recipes
end


function SpiffUISmokeCraftRadial:start()
    local recipes = {}
    
    local bags = ISInventoryPaneContextMenu.getContainers(self.player)
    local recipes = getRecipes(bags, self.player)

    -- Remove any breaking actions if applicable
    if not spiff.config.smokeCraftShowDismantle then
        for i,recipe in pairs(recipes) do
            local first = luautils.split(recipe.recipe:getName(), " ")[1]
            if spiff.rFilters.smokecraft.dismantle[first] then
                recipes[i] = nil
            end
        end
    end

    -- Remove any cigpack actions if applicable
    if not spiff.config.smokeCraftShowCigPacks then
        for i,recipe in pairs(recipes) do
            local first = luautils.split(recipe.recipe:getName(), " ")[1]
            if spiff.rFilters.smokecraft.cigpacks[first] then
                recipes[i] = nil
            end
        end
    end

    -- Always remove these ones
    for i,recipe in pairs(recipes) do
        local first = luautils.split(recipe.recipe:getName(), " ")[1]
        if spiff.rFilters.smokecraft.always[first] then
            recipes[i] = nil
        end
    end

    local hasCraft = false
    -- Build Smokeables
    for i,j in pairs(recipes) do      
        self:AddCommand(SpiffUISmokeCraftRadialCommand:new(self, j))
        hasCraft = true
        self.btmText[self.page] = getText("UI_SpiffUI_Radial_SmokeCraft")
        self.centerImg[self.page] = self.icon
        self.cImgChange[self.page] = true
    end

    if not hasCraft then
        self.player:Say(getText("UI_character_SpiffUI_noCraft"))
    end
end

function SpiffUISmokeCraftRadial:new(player, prev)
    local o = spiff.radialmenu.new(self, player, prev)
    o.askText = getText("UI_amount_SpiffUI_CraftHowMany")

    if getActivatedMods():contains('jiggasGreenfireMod') then
       o.icon = InventoryItemFactory.CreateItem("Greenfire.SmokingPipe"):getTexture()
    elseif getActivatedMods():contains('Smoker') then
       o.icon = InventoryItemFactory.CreateItem("SM.SMSmokingBlendPipe"):getTexture()
    elseif getActivatedMods():contains('MoreCigsMod') then
       o.icon = InventoryItemFactory.CreateItem("Cigs.CigsOpenPackReg"):getTexture()
    else
       o.icon = InventoryItemFactory.CreateItem("Base.Cigarettes"):getTexture()
    end

    return o  
end

local function SmokeCraftDown(player)
    SpiffUI.onKeyDown(player)
    -- if we're not ready, then we're doing an action.
    ---- do it now
    if not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUISmokeCraftRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

local function actionInit()
    local bind = {        
        name = 'SpiffUISmokeCraftWheel',
        key = 43, -- \
        queue = true,
        Down = SmokeCraftDown
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()