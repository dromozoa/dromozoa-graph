-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

assert(g.u.n == 0)
assert(g.e.n == 0)

local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()

assert(g.u.n == 3)
assert(g.e.n == 0)

local e1 = g:add_edge(u1, u2)
local e2 = g:add_edge(u1, u3)

assert(g.u.n == 3)
assert(g.e.n == 2)

local n = 0
for eid, vid in g:each_edge(u1) do
  print(eid, vid)
  n = n + 1
  g:remove_edge(eid)
  g:remove_vertex(vid)
end
assert(n == 2)

assert(g.u.n == 1)
assert(g.e.n == 0)
