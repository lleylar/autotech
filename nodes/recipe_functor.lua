local object_types = require "nodes.object_types"
local object_node_functor = require "nodes.object_node_functor"
local requirement_node = require "nodes.requirement_node"
local requirement_types = require "nodes.requirement_types"
local item_requirements = require "nodes.item_requirements"
local recipe_requirements = require "nodes.recipe_requirements"

local recipe_functor = object_node_functor:new(object_types.recipe,
function (object, requirement_nodes)
    requirement_node:add_new_object_dependent_requirement(recipe_requirements.enable, object, requirement_nodes, object.configuration)

    local recipe = object.object
    if recipe.ingredients ~= nil then
        local nr_ingredients = #recipe.ingredients
        for i = 1, nr_ingredients do
            requirement_node:add_new_object_dependent_requirement(recipe_requirements.ingredient .. i, object, requirement_nodes, object.configuration)
        end
    end
end,
function (object, requirement_nodes, object_nodes)
    local recipe = object.object

    object_node_functor:add_typed_requirement_to_object(object, recipe.category or "crafting", requirement_types.recipe_category, requirement_nodes)

    local i = 1
    for _, ingredient in pairs(recipe.ingredients or {}) do
        local ingredient_node = object.depends[recipe_requirements.ingredient .. i]
        ingredient_node:add_productlike_fulfiller(ingredient, object_nodes)
        i = i + 1
    end

    for _, result in pairs(recipe.results or {}) do
        object_nodes[result.type == 'item' and object_types.item or object_types.fluid][result.name].depends[item_requirements.create]:add_fulfiller(object)
    end

    if recipe.enabled ~= false then
        object.depends[recipe_requirements.enable]:add_fulfiller(object_nodes[object_types.start][object_types.start])
    end
end)
return recipe_functor
