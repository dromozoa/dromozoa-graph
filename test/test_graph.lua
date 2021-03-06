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

local function check(g, uid, expect)
  local n = #expect

  local result = {}
  local eid = g.uv.first[uid]
  while eid do
    result[#result + 1] = eid
    eid = g.uv.after[eid]
  end
  assert(n == #result)
  for i = 1, n do
    assert(result[i] == expect[i])
  end
end

local g = graph()

assert(g.u.n == 0)
local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local u4 = g:add_vertex()
assert(g.u.n == 4)

check(g, u1, {})
local e1 = g:add_edge(u1, u2)
check(g, u1, { e1 })
local e2 = g:add_edge(u1, u3)
check(g, u1, { e1, e2 })
local e3 = g:add_edge(u1, u4)
check(g, u1, { e1, e2, e3 })

g:remove_edge(e1)
g:remove_vertex(u2)
check(g, u1, { e2, e3 })
g:remove_edge(e2)
g:remove_vertex(u3)
check(g, u1, { e3 })
g:remove_edge(e3)
g:remove_vertex(u4)
check(g, u1, {})

local g = graph()
local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local e1 = g:add_edge(u1, u2)
local e2 = g:add_edge(u2, u3)
check(g, u2, { e2 })
g:reverse_edge(e1)
check(g, u2, { e2, e1 })
