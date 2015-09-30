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

local g = graph()

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local v4 = g:create_vertex()

local e1 = g:create_edge(v1, v2)
local e2 = g:create_edge(v2, v3)
local e3 = g:create_edge(v2, v4)
local e4 = g:create_edge(v3, v1)
local e5 = g:create_edge(v4, v1)

e1:collapse()

local n = 0
for v, e in v1:each_adjacent_vertex() do
  assert(v.id == v3.id or v.id == v4.id)
  n = n + 1
end
assert(n == 2)

local result = {}
for v in g:each_vertex() do
  result[v.id] = true
end
assert(result[v1.id])
assert(not result[v2.id])

local g = graph()

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()

local e1 = g:create_edge(v1, v2)
local e2 = g:create_edge(v2, v3)
local e3 = g:create_edge(v3, v1)

e1:collapse("v")

assert(e2.uid == e3.vid)
assert(e2.vid == e3.uid)

io.write "digraph \"graph\" { \n  graph [rankdir = LR];\n"
for e in g:each_edge() do
  io.write("  ", e.uid, " -> ", e.vid, ";\n")
end
io.write "}\n"
