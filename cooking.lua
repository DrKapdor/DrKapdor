box.cfg{
    listen = 3301
}

box.schema.space.create('recipes', {if_not_exists = true})

box.space.recipes:create_index('primary', {
    type = 'TREE',
    parts = {1, 'unsigned'},
    if_not_exists = true
})

box.space.recipes:create_index('name', {
    type = 'TREE',
    parts = {2, 'string'},
    unique = false,
    if_not_exists = true
})

box.space.recipes:create_index('category', {
    type = 'TREE',
    parts = {3, 'string'},
    unique = false,
    if_not_exists = true
})

function add_recipe(name, category, ingredients, instructions, cooking_time)
    local id = box.sequence.recipes_id:next()
    return box.space.recipes:insert{
        id, 
        name, 
        category, 
        ingredients, 
        instructions, 
        cooking_time,
        os.time()
    }
end

function get_recipe_by_id(id)
    return box.space.recipes:get(id)
end

function find_recipes_by_name(name_pattern)
    return box.space.recipes.index.name:pairs(name_pattern, {iterator = 'GE'})
end

function find_recipes_by_category(category)
    return box.space.recipes.index.category:select(category)
end

function update_recipe(id, updates)
    local recipe = box.space.recipes:get(id)
    if not recipe then
        return nil, "Recipe not found"
    end
    
    local updated = recipe:update(updates)
    return updated
end

function delete_recipe(id)
    return box.space.recipes:delete(id)
end

function get_all_recipes()
    return box.space.recipes:select{}
end

box.schema.sequence.create('recipes_id', {if_not_exists = true})

if box.space.recipes:count() == 0 then
    add_recipe(
        "Омлет классический",
        "Завтраки",
        {"Яйца - 3 шт", "Молоко - 50 мл", "Соль - по вкусу", "Масло сливочное - 1 ст.л."},
        "1. Взбить яйца с молоком и солью\n2. Разогреть сковороду с маслом\n3. Вылить смесь и жарить 5-7 минут",
        10
    )
    
    add_recipe(
        "Салат Цезарь",
        "Салаты",
        {"Куриное филе - 200 г", "Салат романо - 1 кочан", "Пармезан - 50 г", "Сухарики - 100 г", "Соус цезарь - 3 ст.л."},
        "1. Обжарить курицу\n2. Порвать салат\n3. Смешать все ингредиенты\n4. Заправить соусом",
        20
    )
    
    add_recipe(
        "Борщ",
        "Супы",
        {"Свекла - 2 шт", "Картофель - 3 шт", "Капуста - 200 г", "Мясо - 300 г", "Сметана - для подачи"},
        "1. Сварить мясной бульон\n2. Добавить овощи\n3. Варить до готовности\n4. Подавать со сметаной",
        60
    )
end

print("Количество рецептов в базе: " .. box.space.recipes:count())

return {
    add_recipe = add_recipe,
    get_recipe_by_id = get_recipe_by_id,
    find_recipes_by_name = find_recipes_by_name,
    find_recipes_by_category = find_recipes_by_category,
    update_recipe = update_recipe,
    delete_recipe = delete_recipe,
    get_all_recipes = get_all_recipes
}
