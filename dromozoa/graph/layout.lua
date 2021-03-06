-- Copyright (C) 2018,2019 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local longest_path = require "dromozoa.graph.longest_path"
local make_dummy_vertices = require "dromozoa.graph.make_dummy_vertices"
local make_layers = require "dromozoa.graph.make_layers"
local make_paths = require "dromozoa.graph.make_paths"
local minimize_crossings = require "dromozoa.graph.minimize_crossings"
local promote_vertices = require "dromozoa.graph.promote_vertices"
local remove_cycles = require "dromozoa.graph.remove_cycles"
local remove_self_edges = require "dromozoa.graph.remove_self_edges"
local subdivide_double_edges = require "dromozoa.graph.subdivide_double_edges"

return function (g, last_uid, last_eid, reversed_eids, skip_promote_vertices)
  local removed_eids, removed_uids = remove_self_edges(g)
  remove_cycles(g, reversed_eids)

  local layer_map = longest_path(g)
  if not skip_promote_vertices then
    layer_map = promote_vertices(g, layer_map)
  end
  make_dummy_vertices(g, layer_map, reversed_eids)
  local layers = make_layers(g, layer_map)
  local layers = minimize_crossings(g, layers)
  local x = brandes_kopf(g, layer_map, layers, last_uid)

  for i = 1, #reversed_eids do
    g:reverse_edge(reversed_eids[i])
  end

  for i = 1, #removed_eids do
    local uid = removed_uids[i]
    g:set_edge(removed_eids[i], uid, uid)
  end

  local max = 0
  for _, v in pairs(x) do
    if max < v then
      max = v
    end
  end
  x.max = max

  local h = #layers
  local y = { max = h - 1 }
  for k, v in pairs(layer_map) do
    y[k] = h - v
  end

  subdivide_double_edges(g, x, y)
  local paths = make_paths(g, last_uid, last_eid)

  return x, y, paths
end
