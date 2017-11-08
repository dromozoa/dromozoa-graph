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
local introduce_dummy_vertices = require "dromozoa.graph.introduce_dummy_vertices"
local longest_path = require "dromozoa.graph.longest_path"

local g = graph()

local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local u4 = g:add_vertex()
local u5 = g:add_vertex()

g:add_edge(u1, u2)
g:add_edge(u2, u3)
g:add_edge(u3, u5)
g:add_edge(u1, u4)
g:add_edge(u4, u5)
g:add_edge(u1, u5)

local layer_map = longest_path(g)
assert(layer_map[u1] == 4)
assert(layer_map[u2] == 3)
assert(layer_map[u3] == 2)
assert(layer_map[u4] == 2)
assert(layer_map[u5] == 1)

local dummy_min = introduce_dummy_vertices(g, layer_map)

assert(dummy_min == 6)
assert(g.u.last == 8)

assert(layer_map[6] == 3)
assert(layer_map[7] == 3)
assert(layer_map[8] == 2)
