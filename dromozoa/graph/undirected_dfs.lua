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

local undirected_dfs_visit = require "dromozoa.graph.undirected_dfs_visit"

return function (g, visitor, uid)
  local start_vertex = visitor.start_vertex
  local ucolor = {}
  local ecolor = {}
  if uid then
    if start_vertex then
      start_vertex(visitor, uid)
    end
    undirected_dfs_visit(g, visitor, uid, ucolor, ecolor)
  end
  for uid in pairs(g.ue) do
    if not ucolor[uid] then
      if start_vertex then
        start_vertex(visitor, uid)
      end
      undirected_dfs_visit(g, visitor, uid, ucolor, ecolor)
    end
  end
  return ucolor, ecolor
end
