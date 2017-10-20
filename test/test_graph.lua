-- Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa.
--
-- dromozoa is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa.  If not, see <http://www.gnu.org/licenses/>.

local bigraph = require "dromozoa.graph.bigraph"
local digraph = require "dromozoa.graph.digraph"

local function check(g, uid, expect)
  local n = #expect

  local result = {}
  for eid, vid in g:each_edge(uid) do
    result[#result + 1] = eid
  end
  assert(n == #result)
  for i = 1, n do
    assert(result[i] == expect[i])
  end

  local result = {}
  g:reverse_push_edges(uid, 0, result, {}, {}, {})
  assert(n == #result)
  for i = 1, n do
    assert(result[i] == expect[n - i + 1])
  end
end

local function test(graph, g)
  local u1 = graph:add_vertex()
  local u2 = graph:add_vertex()
  local u3 = graph:add_vertex()
  local u4 = graph:add_vertex()

  assert(#graph.eu == 0)
  assert(#graph.ev == 0)

  check(g, u1, {})
  local e1 = graph:add_edge(u1, u2)
  check(g, u1, { e1 })
  local e2 = graph:add_edge(u1, u3)
  check(g, u1, { e1, e2 })
  local e3 = graph:add_edge(u1, u4)
  check(g, u1, { e1, e2, e3 })

  assert(#graph.eu == 3)
  assert(#graph.ev == 3)

  graph:remove_edge(e1)
  graph:remove_vertex(u2)
  check(g, u1, { e2, e3 })
  graph:remove_edge(e2)
  graph:remove_vertex(u3)
  check(g, u1, { e3 })
  graph:remove_edge(e3)
  graph:remove_vertex(u4)
  check(g, u1, {})

  assert(#graph.eu == 0)
  assert(#graph.ev == 0)
end

local g = digraph()
test(g, g)

local g = bigraph()
test(g, g.uv)

local g = bigraph()
local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local u4 = g:add_vertex()
local u5 = g:add_vertex()
g:add_edge(u2, u1)
g:add_edge(u3, u1)
g:add_edge(u1, u4)
g:add_edge(u1, u5)

for eid, vid, inv in g:each_edge(u1) do
  assert(inv == (vid <= u3))
end
