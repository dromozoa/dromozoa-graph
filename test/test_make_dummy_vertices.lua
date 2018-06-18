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
local longest_path = require "dromozoa.graph.longest_path"
local make_dummy_vertices = require "dromozoa.graph.make_dummy_vertices"

local verbose = os.getenv "VERBOSE" == "1"

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

local last_uid = g.u.last
assert(g.u.last == 5)
make_dummy_vertices(g, layer_map, {})
assert(g.u.last == 8)

assert(layer_map[6] == 3)
assert(layer_map[7] == 3)
assert(layer_map[8] == 2)

local g = graph()
local u1 = g:add_vertex()
local layer_map = longest_path(g)
assert(layer_map[u1] == 1)
assert(g.u.last == 1)
make_dummy_vertices(g, layer_map, {})
assert(g.u.last == 1)

local g = graph()
g:add_vertex()
g:add_vertex()
g:add_edge(1, 2)
local layer_map = { 5, 1 }
make_dummy_vertices(g, layer_map, {})

assert(g.u.last == 5)
assert(g.e.last == 4)
local eid = g.e.first
while eid do
  if verbose then
    print(eid, g.vu.target[eid], g.uv.target[eid])
  end
  eid = g.e.after[eid]
end
