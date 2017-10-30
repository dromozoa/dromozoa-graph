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
local topological_sort = require "dromozoa.graph.topological_sort"

local g = graph()
local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local u4 = g:add_vertex()
g:add_edge(u1, u2)
g:add_edge(u3, u1)
g:add_edge(u3, u4)
local order = topological_sort(g.u, g.uv)
assert(table.concat(order, " ") == "2 1 4 3")

g:add_edge(u4, u1)
local order = topological_sort(g.u, g.uv)
assert(table.concat(order, " ") == "2 1 4 3")

local e1 = g:add_edge(u2, u4)
local result, message = pcall(topological_sort, g.u, g.uv)
assert(not result)
assert(message:find("not a dag"))

g:remove_edge(e1)
local order = topological_sort(g.u, g.uv)
assert(table.concat(order, " ") == "2 1 4 3")
