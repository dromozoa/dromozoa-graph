-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
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

return function (g, visitor, s, mode)
  local color = {}
  for u in g:each_vertex() do
    visitor:initialize_vertex(g, u)
    color[u.id] = 1
  end
  local q = { s }
  visitor:discover_vertex(g, s)
  while #q > 0 do
    local u = q[#q]
    q[#q] = nil
    visitor:examine_vertex(g, u)
    for v, e in u:each_adjacent_vertex(mode) do
      visitor:examine_edge(g, e, u, v)
      local vid = v.id
      local c = color[vid]
      if c == 1 then
        visitor:tree_edge(g, e, u, v)
        color[vid] = 2
        q[#q + 1] = v
        visitor:discover_vertex(g, v)
      else
        visitor:non_tree_edge(g, e, u, v)
        if c == 2 then
          visitor:gray_target(g, e, u, v)
        else
          visitor:black_target(g, e, u, v)
        end
      end
    end
    color[u.id] = 3
    visitor:finish_vertex(g, u)
  end
end
