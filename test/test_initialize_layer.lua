-- Copyright (C) 2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local initialize_layer = require "dromozoa.graph.initialize_layer"

local g = graph()

g:add_vertex()
g:add_vertex()
g:add_vertex()
g:add_vertex()
g:add_vertex()

g:add_edge(1, 2)
g:add_edge(2, 3)
g:add_edge(3, 5)
g:add_edge(1, 4)
g:add_edge(4, 5)
g:add_edge(1, 5)

local layer_map = longest_path(g)
local dummy_min = introduce_dummy_vertices(g, layer_map, {})
local layer = initialize_layer(g, layer_map)

assert(table.concat(layer[4], " ") == "1")
assert(table.concat(layer[3], " ") == "2 6 7")
assert(table.concat(layer[2], " ") == "3 4 8")
assert(table.concat(layer[1], " ") == "5")
