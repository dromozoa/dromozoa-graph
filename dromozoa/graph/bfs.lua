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

local visit = require "dromozoa.graph.visit"

return function (g, visitor, s, start)
  local color = {}
  for u in g:each_vertex() do
    visit(visitor, "initialize_vertex", g, u)
    color[u.id] = 1
  end
  local q = { s }
  local i = 1
  local j = 2
  visit(visitor, "discover_vertex", g, s)
  while i < j do
    -- pop queue
    local u = q[i]
    q[i] = nil
    i = i + 1
    visit(visitor, "examine_vertex", g, u)
    for v, e in u:each_adjacent_vertex(start) do
      if visit(visitor, "examine_edge", g, e, u, v) ~= false then
        local vid = v.id
        local c = color[vid]
        if c == 1 then
          visit(visitor, "tree_edge", g, e, u, v)
          color[vid] = 2
          -- push queue
          q[j] = v
          j = j + 1
          visit(visitor, "discover_vertex", g, v)
        else
          visit(visitor, "non_tree_edge", g, e, u, v)
          if c == 2 then
            visit(visitor, "gray_target", g, e, u, v)
          else
            visit(visitor, "black_target", g, e, u, v)
          end
        end
      end
    end
    color[u.id] = 3
    visit(visitor, "finish_vertex", g, u)
  end
end
