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

local json = require "dromozoa.commons.json"
local sequence = require "dromozoa.commons.sequence"
local graph = require "dromozoa.graph"

local g = graph()

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

local map = {}
local nodes = sequence()
local links = sequence()

local i = 0
for u in g:each_vertex() do
  map[u.id] = #nodes
  nodes:push({ text = tostring(u.id) })
end
for e in g:each_edge() do
  links:push({
    source = map[e.uid];
    target = map[e.vid];
  })
end

local handle = assert(io.open("doc/dromozoa-graph.html"))
io.write(handle:read("*a"))
handle:close()

io.write("<script>dromozoa.graph(");
json.write(io.stdout, {
  nodes = nodes;
  links = links;
})
io.write(");</script>\n")
