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

local greedy_cycle_removal = require "dromozoa.graph.greedy_cycle_removal"
local brandes_kopf = require "dromozoa.graph.brandes_kopf"
local longest_path = require "dromozoa.graph.longest_path"
local introduce_dummy_vertices = require "dromozoa.graph.introduce_dummy_vertices"
local initialize_layer = require "dromozoa.graph.initialize_layer"
local vertex_promotion = require "dromozoa.graph.vertex_promotion"

local function remove_loop_edges(g)
  local e = g.e
  local e_after = e.after
  local source = g.vu.target
  local target = g.uv.target

  local remove_eids = {}
  local remove_uids = {}
  local n = 0

  local eid = e.first
  while eid do
    local uid = source[eid]
    if uid == target[eid] then
      n = n + 1
      remove_eids[n] = eid
      remove_uids[n] = uid
    end
    eid = e_after[eid]
  end

  return remove_eids, remove_uids
end

return function (g)
  local remove_eids, remove_uids = remove_loop_edges(g)
  for i = 1, #remove_eids do
    g:remove_edge(remove_eids[i])
  end

  local reverse_eids = greedy_cycle_removal(g)
  local reverse_set = {}
  for i = 1, #reverse_eids do
    local eid = reverse_eids[i]
    reverse_set[eid] = true
    g:reverse_edge(eid)
  end

  local layer_map = vertex_promotion(g, longest_path(g))
  local dummy_min = introduce_dummy_vertices(g, layer_map, reverse_eids, reverse_set)
  local layer = initialize_layer(g, layer_map)
  local x = brandes_kopf(g, layer_map, layer, dummy_min)

  for i = 1, #reverse_eids do
    g:reverse_edge(reverse_eids[i])
  end

  for i = 1, #remove_eids do
    local uid = remove_uids[i]
    g:set_edge(remove_eids[i], uid, uid)
  end

  return dummy_min, layer_map, x
end
