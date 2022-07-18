------------------------------------------
-- SpiffUI First Aid Craft Actions
----  Radial Menu for First Aid Crafting
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

local SpiffUIFirstAidCraftRadial = spiff.radialmenu:derive("SpiffUIFirstAidCraftRadial")
if not spiff.radials then spiff.radials = {} end
spiff.radials[4] = SpiffUIFirstAidCraftRadial
------------------------------------------

local SpiffUIFirstAidCraftRadialCommand = spiff.radialcommand:derive("SpiffUIFirstAidCraftRadialCommand")

function SpiffUIFirstAidCraftRadialCommand:Action()
    ISInventoryPaneContextMenu.OnCraft(self.item, self.recipe, self.player:getPlayerNum(), self.amount)
end

function SpiffUIFirstAidCraftRadialCommand:new(menu, recipe)
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
    if spiff.config.firstAidCraftAmount == -1 and recipe.num > 1 then
        -- Ask
        o.shouldAsk = 2
    elseif spiff.config.firstAidCraftAmount == 1 then
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
            return spiff.filters.firstAidCraft[item:getType()] or item:getStringItemType() == "Medical"
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

    for _,item in pairs(items) do
        local recs = RecipeManager.getUniqueRecipeItems(item, player, packs)
        for i = 0, recs:size() - 1 do
            local recipe = recs:get(i)
            local key = recipe:getResult():getFullType()
            recipes[key] = {
                recipe = recipe,
                num = RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, player, packs, item),
                item = item
            }
        end
    end
    return recipes
end

function SpiffUIFirstAidCraftRadial:start()
    local recipes = {}
    
    local bags = ISInventoryPaneContextMenu.getContainers(self.player)
    local recipes = getRecipes(bags, self.player)

    local hasCraft = false
    -- Build Smokeables
    for i,j in pairs(recipes) do      
        self:AddCommand(SpiffUIFirstAidCraftRadialCommand:new(self, j))
        hasCraft = true
        self.btmText[self.page] = getText("UI_SpiffUI_Radial_FirstAidCraft")
        self.centerImg[self.page] = InventoryItemFactory.CreateItem("Base.Bandage"):getTexture()
        self.cImgChange[self.page] = true
    end

    if not hasCraft then
        self.player:Say(getText("UI_character_SpiffUI_noCraft"))
    end
end

function SpiffUIFirstAidCraftRadial:new(player, prev)
    local o = spiff.radialmenu.new(self, player, prev)
    o.askText = getText("UI_amount_SpiffUI_CraftHowMany")
    return o  
end

local function FirstAidCraftDown(player)
    SpiffUI.onKeyDown(player)
    -- if we're not ready, then we're doing an action.
    ---- do it now
    if not SpiffUI.action.ready then
        -- Create Menu
        local menu = SpiffUIFirstAidCraftRadial:new(player)
        menu:display()
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

local function actionInit()
    local bind = {        
        name = 'SpiffUIFirstAidCraftWheel',
        key = 39, -- ;
        queue = true,
        Down = FirstAidCraftDown
    } 
    SpiffUI:AddKeyBind(bind)
end

actionInit()