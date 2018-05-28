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

local g = graph()

local n0 = g:add_vertex()
local n1 = g:add_vertex()
local n2 = g:add_vertex()
local n3 = g:add_vertex()
local n4 = g:add_vertex()
local n5 = g:add_vertex()
local s0 = g:add_vertex()
local s1 = g:add_vertex()
local s2 = g:add_vertex()
local s3 = g:add_vertex()
local s4 = g:add_vertex()
g:add_edge(n0, s0)
g:add_edge(n1, s1)
g:add_edge(n1, s2)
g:add_edge(n2, s0)
g:add_edge(n2, s3)
g:add_edge(n2, s4)
g:add_edge(n3, s0)
g:add_edge(n3, s2)
g:add_edge(n4, s3)
g:add_edge(n5, s2)
g:add_edge(n5, s4)

local layers = {
  { s0, s1, s2, s3, s4 };
  { n0, n1, n2, n3, n4, n5 };
}

local count = count_crossings(g, layers[1], layers[2])
assert(count == 12)
