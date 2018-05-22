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

local adjacency_list = require "dromozoa.graph.adjacency_list"

local g = adjacency_list()

g:add_edge(1, 1, 2)
g:add_edge(2, 2, 3)
g:add_edge(3, 2, 4)

local eid = g.first[2]
assert(eid == 2)
assert(g.target[eid] == 3)
local eid = g.after[eid]
assert(eid == 3)
assert(g.target[eid] == 4)
local eid = g.after[eid]
assert(not eid)
assert(not g.target[eid])

assert(g:degree(1) == 1)
assert(g:degree(2) == 2)
assert(g:degree(3) == 0)

local eid = g.first[2]
while eid do
  eid = g:remove_edge(eid, 2)
end

assert(g:degree(1) == 1)
assert(g:degree(2) == 0)
assert(g:degree(3) == 0)

g:remove_edge(1, 1)

assert(g:degree(1) == 0)
assert(g:degree(2) == 0)
assert(g:degree(3) == 0)

local g = adjacency_list()

g:add_edge(1, 1, 2)
assert(not g:remove_edge(1, 1))

g:add_edge(1, 1, 2)
g:add_edge(2, 1, 3)
assert(g:remove_edge(1, 1) == 2)
assert(not g:remove_edge(2, 1))

g:add_edge(1, 1, 2)
g:add_edge(2, 1, 3)
assert(not g:remove_edge(2, 1))
assert(not g:remove_edge(1, 1))

g:add_edge(1, 1, 2)
g:insert_edge(1, 2, 1, 3)
g:insert_edge(1, 3, 1, 4)
assert(g.first[1] == 2)
assert(g.after[2] == 3)
assert(g.after[3] == 1)
assert(not g.after[1])
assert(g.last[1] == 1)
assert(g.before[1] == 3)
assert(g.before[3] == 2)
assert(not g.before[2])
assert(g.target[1] == 2)
assert(g.target[2] == 3)
assert(g.target[3] == 4)
