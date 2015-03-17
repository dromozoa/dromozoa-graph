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

local function dfs(g, visitor, u, mode, color)
  local uid = u.id
  visitor:discover_vertex(g, u)
  color[uid] = 2
  for v, e in u:each_adjacent_vertex(mode) do
    local c = color[v.id]
    visitor:examine_edge(g, e, u, v)
    if c == 1 then
      visitor:tree_edge(g, e, u, v)
      dfs(g, visitor, v, mode, color)
    elseif c == 2 then
      visitor:back_edge(g, e, u, v)
    else
      visitor:forward_or_cross_edge(g, e, u, v)
    end
    visitor:finish_edge(g, e, u, v)
  end
  visitor:finish_vertex(g, u)
  color[uid] = 3
end

return function (g, visitor, s, mode)
  local color = {}
  for u in g:each_vertex() do
    visitor:initialize_vertex(g, u)
    color[u.id] = 1
  end
  if s then
    visitor:start_vertex(g, s)
    dfs(g, visitor, s, mode, color)
  else
    for u in g:each_vertex() do
      if color[u.id] == 1 then
        visitor:start_vertex(g, u)
        dfs(g, visitor, u, mode, color)
      end
    end
  end
end
