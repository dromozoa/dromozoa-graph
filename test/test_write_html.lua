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

local graph = require "dromozoa.graph"

local function append(g, u, i)
  i = i - 1
  if i == 0 then
    return g
  else
    for j = 1, 4 do
      local v = g:create_vertex()
      g:create_edge(u, v)
      append(g, v, i)
    end
  end
end

local g = graph()
-- append(g, g:create_vertex(), 6)

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local v4 = g:create_vertex()
local v5 = g:create_vertex()
local v6 = g:create_vertex()

g:create_edge(v1, v2)
g:create_edge(v3, v5)
g:create_edge(v3, v6)
g:create_edge(v1, v4)
g:create_edge(v2, v5)
g:create_edge(v5, v4)

local handle = assert(io.open("doc/dromozoa-graph.html"))
io.write(handle:read("*a"))
handle:close()

io.write("<script>dromozoa.graph(");
g:write_d3_json(io.stdout, {
  node_attributes = function (context, g, u)
    return {
      text = tostring(u.id);
    }
  end;
})
io.write(");</script>\n")
