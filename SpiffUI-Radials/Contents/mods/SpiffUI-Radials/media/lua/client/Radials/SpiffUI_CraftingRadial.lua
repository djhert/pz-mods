------------------------------------------
-- SpiffUI Crafting Radial Actions
----  Radial Menu for Crafting
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUICraftingRadial = spiff.radialmenu:derive("SpiffUICraftingRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[0] = SpiffUICraftingRadial

------------------------------------------

local SpiffUICraftingRadialCommand = spiff.radialcommand:derive("SpiffUICraftingRadialCommand")

function SpiffUICraftingRadialCommand:Action()
    ISInventoryPaneContextMenu.OnCraft(self.item, self.recipe, self.player:getPlayerNum(), self.amount)
end

function SpiffUICraftingRadialCommand:new(menu, recipe)
    if SpiffUI.config.debug then
        print("Item: " .. recipe.item:getFullType() .. " | Recipe: " .. recipe.recipe:getName() .. " | Result: " .. recipe.recipe:getResult():getFullType())
    end
    local texture
    local itex = InventoryItemFactory.CreateItem(recipe.recipe:getResult():getFullType())
    if itex then
        texture = itex:getTexture()
    else
        texture = recipe.item:getTexture()
    end

    local tooltip = {
        recipe = recipe.recipe,
        item = recipe.item,
        isRecipe = true
    }
    local o = spiff.radialcommand.new(self, menu, recipe.recipe:getName(), texture, tooltip)

    o.recipe = recipe.recipe
    o.item = recipe.item

    if spiff.config.craftAmount == -1 and recipe.num > 1 then
        -- Ask
        o.shouldAsk = 2
    elseif spiff.config.craftAmount == 1 then
        -- Craft All
        o.amount = true
    end

    return o
end

local function getRecipes(packs, player)
    local items = {}
    local recipes = {}
    for p = 0, packs:size() - 1 do
        local pack = packs:get(p)
        local ps = pack:getAllEval(function(item)
            return instanceof(item, "InventoryItem") and not instanceof(item, "Moveable")
        end)
        if ps and ps:size() > 0 then
            for i = 0, ps:size() - 1 do
                local item = ps:get(i)
                if item then
                    if not items[item:getType()] then
                        items[item:getType()] = item
                    end
                end
            end
        end
    end

    if not spiff.config.craftShowSmokeables then
        for i,item in pairs(items) do
            if spiff.filters.smokeables[item:getType()] or item:getCustomMenuOption() == "Smoke" then
                items[item:getType()] = nil
            end
        end
    end

    if not spiff.config.craftShowMedical then
        for i,item in pairs(items) do
            if spiff.filters.firstAidCraft[item:getType()] or item:getStringItemType() == "Medical" then
                items[item:getType()] = nil
            end
        end
    end

    if not spiff.config.craftShowEquipped then
        for i,item in pairs(items) do
        if player:isEquipped(item) and (player:getPrimaryHandItem() ~= item and player:getSecondaryHandItem() ~= item) then
            items[item:getType()] = nil
            end
        end
    end

    local count = 0
    for _,item in pairs(items) do
        local recs = RecipeManager.getUniqueRecipeItems(item, player, packs)
        for i = 0, recs:size() - 1 do
            local recipe = recs:get(i)
            local key
            if spiff.config.craftFilterUnique then
                key = recipe:getName()
            else
                key = count
            end
            if not recipes[key] then
                recipes[key] = {
                    recipe = recipe,
                    num = RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, player, packs, item),
                    item = item
                }
                count = count + 1
            end
        end
    end

    return recipes
end

------------------------------------------

function SpiffUICraftingRadial:start()
    local bags = ISInventoryPaneContextMenu.getContainers(self.player)
    local recipes = getRecipes(bags, self.player)

    local hasRecipes = false
    for i,j in pairs(recipes) do      
        self:AddCommand(SpiffUICraftingRadialCommand:new(self, j))
        hasRecipes = true
        self.centerImg[self.page] = getTexture("media/spifcons/crafting.png")
        self.btmText[self.page] = getText("UI_SpiffUI_Radial_Crafting")
        self.cImgChange[self.page] = true
    end    

    if not hasRecipes then
        self.player:Say(getText("UI_character_SpiffUI_noCraft"))
    end
end

function SpiffUICraftingRadial:new(player, prev)
    local o = spiff.radialmenu.new(self, player, prev)
    o.askText = getText("UI_amount_SpiffUI_CraftHowMany")
    return o
end

local function SpiffUICraftDown(player)
    SpiffUI.onKeyDown(player)
    if not SpiffUI.action.ready then
        local ui = getPlayerCraftingUI(player:getPlayerNum())
        if ui:getIsVisible() then
            ui:setVisible(false)
            ui:removeFromUIManager()
            -- Ready for another action
            SpiffUI.action.ready = true
        end
    end
end

local function SpiffUICraftHold(player)
    if SpiffUI.holdTime() then
        if spiff.config.craftSwitch then
            ISCraftingUI.toggleCraftingUI()
        else
            -- Create Menu
            local menu = SpiffUICraftingRadial:new(player)
            menu:display()
        end
    end
end

local function SpiffUICraftRelease(player)
    if SpiffUI.releaseTime() then
        if spiff.config.craftSwitch then
            -- Create Menu
            local menu = SpiffUICraftingRadial:new(player)
            menu:display()
        else
            ISCraftingUI.toggleCraftingUI()
        end
    end
end

local function actionInit()
    local bind = {
        name = 'SpiffUICraftWheel',
        key = Keyboard.KEY_B,
        queue = false,
        Down = SpiffUICraftDown,
        Hold = SpiffUICraftHold,
        Up = SpiffUICraftRelease
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()