local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local electricity_verbs = require "verbs.electricity_verbs"
local entity_verbs = require "verbs.entity_verbs"
local tile_verbs = require "verbs.tile_verbs"

local planet_node = object_node_base:create_object_class("planet", node_types.planet_node, function(self, nodes)
    local planet = self.object

    if planet.entities_require_heating and defines.feature_flags.freezing then
        self:add_dependency(nodes, node_types.electricity_node, 1, "requires a heat source", electricity_verbs.heat)
    end

    local mgs = planet.map_gen_settings
    if not mgs then return end

    if mgs.cliff_settings then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, mgs.cliff_settings.name, "cliff autoplace", entity_verbs.instantiate)
    end

    if mgs.territory_settings then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, mgs.territory_settings.units, "planet territory owner", entity_verbs.instantiate)
    end

    if mgs.autoplace_controls then
        for control in pairs(mgs.autoplace_controls) do
            self:add_disjunctive_dependent(nodes, node_types.autoplace_control_node, control, "autoplace control", "configure")
        end
    end

    local autoplace_settings = mgs.autoplace_settings
    if not autoplace_settings then return end

    if autoplace_settings.entity then
        for k, _ in pairs(autoplace_settings.entity.settings or {}) do
            self:add_disjunctive_dependent(nodes, node_types.entity_node, k, "autoplace entity", entity_verbs.instantiate)
        end
    end

    if autoplace_settings.tile then
        for k, _ in pairs(autoplace_settings.tile.settings or {}) do
            self:add_disjunctive_dependent(nodes, node_types.tile_node, k, "autoplace tile", tile_verbs.place)
        end
    end
end)

return planet_node
