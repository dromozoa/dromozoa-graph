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

v1.foo = 42
v1.bar = false
v2.foo = 69

print(v2.id)
print(v2.foo)

local count = 0
for k, v in v1:each_property() do
  count = count + 1
  print("v1", k, v)
end
for k, v in v2:each_property() do
  count = count + 1
  print("v2", k, v)
end
for k, v in v3:each_property() do
  count = count + 1
  print("v3", k, v)
end
assert(count == 3)

local e1 = g:create_edge(v1, v2)
e1.foo = 42
e1.bar = false

local count = 0
for k, v in e1:each_property() do
  count = count + 1
  print("e1", k, v)
end
assert(count == 2)
