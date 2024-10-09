local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local item_verbs = require "verbs.item_verbs"
local recipe_verbs = require "verbs.recipe_verbs"
local planet_verbs = require "verbs.planet_verbs"

local technology_node = object_node_base:create_object_class("technology", node_types.technology_node, function(self, nodes)
    local tech = self.object

    self:add_dependency(nodes, node_types.technology_node, tech_data.prerequisites, "prerequisite", "enable")

    for _, modifier in pairs(tech_data.effects or {}) do
        if modifier.type == "give-item" then
            self:add_disjunctive_dependent(nodes, node_types.item_node, modifier.item, "given by tech", item_verbs.create)
        elseif modifier.type == "unlock-recipe" then
            self:add_disjunctive_dependent(nodes, node_types.recipe_node, modifier.recipe, "enabled by tech", recipe_verbs.enable)
        elseif modifier.type == "unlock-space-location" then
            self:add_disjunctive_dependent(nodes, node_types.planet_node, modifier.space_location, "unlocked by tech", planet_verbs.visit)
        end
    end
end)

return technology_node
