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

local equal = require "dromozoa.commons.equal"
local root = require "dromozoa.graph"

local g1 = root()
local v1 = g1:create_vertex()
local v2 = g1:create_vertex()
local v3 = g1:create_vertex()
local e1 = g1:create_edge(v1, v2)
local e2 = g1:create_edge(v2, v3)

local g2 = root()
local v4 = g2:create_vertex()
local v5 = g2:create_vertex()
local v6 = g2:create_vertex()
local v7 = g2:create_vertex()
local e3 = g2:create_edge(v4, v5)
local e4 = g2:create_edge(v5, v6)

assert(e1.id == e3.id)
assert(e1.uid == e3.uid)
assert(e1.vid == e3.vid)
assert(e2.id == e4.id)
assert(e2.uid == e4.uid)
assert(e2.vid == e4.vid)

assert(not equal(g1, g2))
assert(not equal(e1, e3))
assert(not equal(e2, e4))

local e = g1:get_edge(e1.id)
assert(e ~= e1)
assert(equal(e, e1))

assert(not pcall(function () v1.id = 42 end))
assert(not pcall(function () e1.id = 42 end))

e1.u = v2
e1.v = v1

local data = {}
for u, e in v2:each_adjacent_vertex() do
  data[#data + 1] = u.id
end
assert(equal(data, { v3.id, v1.id }))
