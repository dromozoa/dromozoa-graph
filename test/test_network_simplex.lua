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

local graph = require "dromozoa.graph"
local network_simplex = require "dromozoa.graph.network_simplex"

local g = graph()
for i = 1, 8 do
  g:add_vertex()
end
g:add_edge(1, 2)
g:add_edge(2, 3)
g:add_edge(3, 4)
g:add_edge(4, 5)
g:add_edge(6, 5)
g:add_edge(7, 6)
-- g:add_edge(1, 7)
g:add_edge(7, 1)
g:add_edge(8, 6)
-- g:add_edge(1, 8)
g:add_edge(8, 1)

-- print(table.concat(layer, " "))
local t, rank_map = network_simplex(g)

local function visit(t, uid)
  -- io.write(("%d [label=\"%d/%d\"];\n"):format(uid, uid, rank_map[uid]))

  local eid = t.uv.first[uid]
  while eid do
    local vid = t.uv.target[eid]
    io.write(uid, "->", vid, ";\n")
    visit(t, vid)
    eid = t.uv.after[eid]
  end
end
io.write("digraph {\n")
visit(t, 1)
io.write("}\n")
