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

assert(v1:count_degree("u") == 0)
assert(v1:count_degree("v") == 0)

local result = {}
for v, e in v1:each_adjacent_vertex() do result[#result + 1] = { v, e } end
assert(#result == 0)

local e1 = g:create_edge(v1, v1)

assert(v1:count_degree("u") == 1)
assert(v1:count_degree("v") == 1)

local result = {}
for v, e in v1:each_adjacent_vertex() do result[#result + 1] = { v, e } end
assert(#result == 1)
assert(result[1][1].id == 1)

local e2 = g:create_edge(v1, v2)

assert(v1:count_degree("u") == 2)
assert(v1:count_degree("v") == 1)

local result = {}
for v, e in v1:each_adjacent_vertex() do result[#result + 1] = { v, e } end
assert(#result == 2)
assert(result[1][1].id == 1)
assert(result[2][1].id == 2)

local e3 = g:create_edge(v1, v3)

assert(v1:count_degree("u") == 3)
assert(v1:count_degree("v") == 1)

local result = {}
for v, e in v1:each_adjacent_vertex() do result[#result + 1] = { v, e } end
assert(#result == 3)
assert(result[1][1].id == 1)
assert(result[2][1].id == 2)
assert(result[3][1].id == 3)

assert(v2:count_degree("u") == 0)
assert(v2:count_degree("v") == 1)
e2.removed = true
e2:remove()
assert(v2:count_degree("u") == 0)
assert(v2:count_degree("v") == 0)

v1.start = true
local count = 0
for u in g:each_vertex("start") do
  assert(u.id == 1)
  count = count + 1
end
assert(count == 1)

e1.color = 1
e3.color = 3
local count = 0
for e in g:each_edge("color") do
  assert(e.id == e.color)
  count = count + 1
end
assert(count == 2)

assert(v1.start == true)
g:clear_vertex_properties("start")
assert(v1.start == nil)

assert(e1.color == 1)
g:clear_edge_properties("color")
assert(e1.color == nil)

local g = graph()
assert(g:empty())

local u = g:create_vertex()
local v = g:create_vertex()
local e = g:create_edge(u, v)

assert(not g:empty())
assert(g:get_vertex(u.id).id == u.id)
assert(g:get_vertex(v.id).id == v.id)
assert(g:get_edge(e.id).id == e.id)

u.color = 1
v.color = 2
e.color = 1
g:create_edge(v, u).color = 2

local clone = g:clone()

for u in g:each_vertex() do
  local c = clone:get_vertex(u.id)
  assert(u.id == c.id)
  assert(u.color == c.color)
end

for e in g:each_edge() do
  local c = clone:get_edge(e.id)
  assert(e.id == c.id)
  assert(e.color == c.color)
end
