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

local visit = require "dromozoa.commons.visit"

local function dfs(graph, visitor, u, start, color)
  local uid = u.id
  visit(visitor, "discover_vertex", u)
  color[uid] = 2
  for v, e in u:each_adjacent_vertex(start) do
    if visit(visitor, "examine_edge", e, u, v) ~= false then
      local c = color[v.id]
      if c == 1 then
        visit(visitor, "tree_edge", e, u, v)
        dfs(graph, visitor, v, start, color)
      elseif c == 2 then
        visit(visitor, "back_edge", e, u, v)
      else
        visit(visitor, "forward_or_cross_edge", e, u, v)
      end
      visit(visitor, "finish_edge", e, u, v)
    end
  end
  visit(visitor, "finish_vertex", u)
  color[uid] = 3
end

return function (graph, visitor, s, start)
  local color = {}
  for u in graph:each_vertex() do
    visit(visitor, "initialize_vertex", u)
    color[u.id] = 1
  end
  if s == nil then
    for u in graph:each_vertex() do
      if color[u.id] == 1 then
        visit(visitor, "start_vertex", u)
        dfs(graph, visitor, u, start, color)
      end
    end
  else
    visit(visitor, "start_vertex", s)
    dfs(graph, visitor, s, start, color)
  end
end
