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
local write_dot = require "write_dot"

local function check(uv, uid, expect)
  local n = #expect

  local result = {}
  local eid = uv.first[uid]
  while eid do
    result[#result + 1] = uv.target[eid]
    eid = uv.after[eid]
  end
  assert(n == #result)
  for i = 1, n do
    assert(result[i] == expect[i])
  end
end

local g = graph()

local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()

local e1 = g:add_edge(u1, u2)
local e2 = g:add_edge(u1, u2)
local e3 = g:add_edge(u2, u3)
local e4 = g:add_edge(u3, u1)

write_dot("test1.dot", g)

g:reverse_edge(e2, u2, u1)

write_dot("test2.dot", g)

g:remove_edge(e2)
g:set_edge(e2, u1, u1)

write_dot("test3.dot", g)
