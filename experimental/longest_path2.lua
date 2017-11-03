-- Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local topological_sort = require "dromozoa.graph.topological_sort"

return function (g)
  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local layer_map = {}

  local order = topological_sort(g)
  for i = 1, #order do
    local uid = order[i]
    local eid = uv_first[uid]
    if not eid then
      layer_map[uid] = 1
    else
      local u

      repeat
        local v = layer_map[uv_target[eid]]
        if not u or u < v then
          u = v
        end
        eid = uv_after[eid]
      until not eid

      layer_map[uid] = u + 1
    end
  end

  return layer_map
end
