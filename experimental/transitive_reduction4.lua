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
  local u = g.u
  local u_after = u.after

  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local remove = {}
  local n = 0

  local order = topological_sort(u, uv)
  local order_map = {}
  for i = 1, #order do
    order_map[order[i]] = i
  end

  local uid = u.first
  while uid do
    local eid = uv_first[uid]
    if eid then
      local order_max = order_map[uid] - 1
      local order_min = order_max
      repeat
        local i = order_map[uv_target[eid]]
        if order_min > i then
          order_min = i
        end
        eid = uv_after[eid]
      until not eid

      local distance = { [uid] = 0 }
      for i = order_max, order_min, -1 do
        local vid = order[i]
        local v

        local eid = vu_first[vid]
        while eid do
          local w = distance[vu_target[eid]]
          if w then
            if not v or v < w then
              v = w
            end
          end
          eid = vu_after[eid]
        end

        if v then
          distance[vid] = v + 1
        end
      end

      local eid = uv_first[uid]
      repeat
        if distance[uv_target[eid]] > 1 then
          n = n + 1
          remove[n] = eid
        end
        eid = uv_after[eid]
      until not eid
    end

    uid = u_after[uid]
  end

  return remove
end
