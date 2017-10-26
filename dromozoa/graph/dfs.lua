-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local dfs_visit = require "dromozoa.graph.dfs_visit"

return function (g, that, uid, color)
  if not color then
    color = {}
  end

  local start_vertex = that.start_vertex

  if uid then
    if start_vertex then
      start_vertex(that, uid)
    end
    dfs_visit(g, that, uid, color)
  end

  for uid in pairs(g.ue) do
    if not color[uid] then
      if start_vertex then
        start_vertex(that, uid)
      end
      dfs_visit(g, that, uid, color)
    end
  end

  return color
end
