-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-graph.
--
-- dromozoa-graph is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-graph is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-graph.  If not, see <http://www.gnu.org/licenses/>.

local brandes_kopf = require "dromozoa.graph.brandes_kopf"
local initialize_layer = require "dromozoa.graph.initialize_layer"
local introduce_dummy_vertices = require "dromozoa.graph.introduce_dummy_vertices"
local longest_path = require "dromozoa.graph.longest_path"
local remove_cycles = require "dromozoa.graph.remove_cycles"
local remove_self_edges = require "dromozoa.graph.remove_self_edges"
local promote_vertices = require "dromozoa.graph.promote_vertices"

return function (g)
  local removed_eids, removed_uids = remove_self_edges(g)
  local reversed_eids = remove_cycles(g)

  local layer_map = promote_vertices(g, longest_path(g))
  local dummy_min = introduce_dummy_vertices(g, layer_map, reversed_eids)
  local layer = initialize_layer(g, layer_map)
  local x = brandes_kopf(g, layer_map, layer, dummy_min)

  for i = 1, #reversed_eids do
    g:reverse_edge(reversed_eids[i])
  end

  for i = 1, #removed_eids do
    local uid = removed_uids[i]
    g:set_edge(removed_eids[i], uid, uid)
  end

  return dummy_min, layer_map, x
end
