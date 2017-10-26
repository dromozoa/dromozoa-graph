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
  local vu = g.vu

  for uid, eid in pairs(uv.ue) do
    if eid then
      local distance = {}

      local order = topological_sort(uv, uid)
      for i = #order, 1, -1 do
        local vid = order[i]
        local value = 0
        for _, uid in vu:each_edge(vid) do
          local v = distance[uid]
          if v and value < v then
            value = v
          end
        end
        distance[vid] = value + 1
      end

      for eid, vid in uv:each_edge(uid) do
        if distance[vid] > 2 then
          g:remove_edge(eid)
        end
      end
    end
  end
end
