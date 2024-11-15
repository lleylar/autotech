local object_types = require "object_nodes.object_types"
local object_node_descriptor = require "object_nodes.object_node_descriptor"
local object_node_functor = require "object_nodes.object_node_functor"
local requirement_node = require "requirement_nodes.requirement_node"
local requirement_types = require "requirement_nodes.requirement_types"
local item_requirements = require "requirements.item_requirements"
local recipe_requirements = require "requirements.recipe_requirements"

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
        object_node_functor:add_productlike_fulfiller(object.depends[recipe_requirements.ingredient .. i], ingredient, object_nodes)
        i = i + 1
    end

    object_node_functor:add_fulfiller_to_productlike_object(object, recipe.results, item_requirements.create, object_nodes)

    if recipe.enabled ~= false then
        object.depends[recipe_requirements.enable]:add_fulfiller(object_nodes:find_object_node(object_node_descriptor:unique_node(object_types.start)))
    end
end)
return recipe_functor