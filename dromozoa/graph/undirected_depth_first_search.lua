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

local undirected_depth_first_visit = require "dromozoa.graph.undirected_depth_first_visit"

return function (g, that, uid, vcolor, ecolor)
  if not vcolor then
    vcolor = {}
  end
  if not ecolor then
    ecolor = {}
  end

  local start_vertex = that.start_vertex

  if uid then
    if start_vertex then
      start_vertex(that, uid)
    end
    undirected_depth_first_visit(g, that, uid, vcolor, ecolor)
  end

  for uid in pairs(g.ue) do
    if not vcolor[uid] then
      if start_vertex then
        start_vertex(that, uid)
      end
      undirected_depth_first_visit(g, that, uid, vcolor, ecolor)
    end
  end

  return vcolor, ecolor
end
