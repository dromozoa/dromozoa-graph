-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local count_crossings = require "dromozoa.graph.count_crossings"
local minimize_crossings = require "dromozoa.graph.minimize_crossings"

local verbose = os.getenv "VERBOSE" == "1"

local g = graph()

local v1 = g:add_vertex()
local v2 = g:add_vertex()
local v3 = g:add_vertex()
local v4 = g:add_vertex()
local v5 = g:add_vertex()
local v6 = g:add_vertex()
local v7 = g:add_vertex()
local v8 = g:add_vertex()
local v9 = g:add_vertex()
local v10 = g:add_vertex()
local v11 = g:add_vertex()
local v12 = g:add_vertex()
local v13 = g:add_vertex()

g:add_edge(v1, v2)
g:add_edge(v1, v3)
g:add_edge(v1, v4)
g:add_edge(v2, v5)
g:add_edge(v3, v6)
g:add_edge(v4, v7)
g:add_edge(v5, v10)
g:add_edge(v6, v8)
g:add_edge(v7, v9)
g:add_edge(v8, v13)
g:add_edge(v9, v12)
g:add_edge(v10, v12)
g:add_edge(v11, v12)

local layers = {
  { v12, v13 };
  { v8, v9, v10, v11 };
  { v5, v6, v7 };
  { v2, v3, v4 };
  { v1 };
}

assert(count_crossings(g, layers[1], layers[2]) == 3)
assert(count_crossings(g, layers[2], layers[3]) == 2)
assert(count_crossings(g, layers[3], layers[4]) == 0)
assert(count_crossings(g, layers[4], layers[5]) == 0)

local layers = minimize_crossings(g, layers)

assert(count_crossings(g, layers[1], layers[2]) == 0)
assert(count_crossings(g, layers[2], layers[3]) == 0)
assert(count_crossings(g, layers[3], layers[4]) == 0)
assert(count_crossings(g, layers[4], layers[5]) == 0)

if verbose then
  for i = 1, #layers do
    print(table.concat(layers[i], " "))
  end
end
