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
local greedy = require "experimental.cycle_removal.greedy"

local N = ...
local N = tonumber(N or 6)

local g = graph()
local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local u4 = g:add_vertex()
local e1 = g:add_edge(u1, u2)
local e2 = g:add_edge(u2, u3)
local e3 = g:add_edge(u3, u1)
local e4 = g:add_edge(u3, u4)
local e5 = g:add_edge(u4, u2)

local reverse = greedy(g)
assert(#reverse == 1)
assert(reverse[1] == e2)

local g = graph()
local u = g:add_vertex()
local v = g:add_vertex()
g:add_edge(u, v)
for i = 1, N do
  local w = g:add_vertex()
  g:add_edge(v, w)
  g:add_edge(w, u)
  u = v
  v = w
end

local reverse = greedy(g)

if N % 2 == 0 then
  local n = N / 2
  assert(#reverse == n)
  for i = 1, n do
    assert(reverse[i] == i * 4 - 2)
  end
else
  local n = (N + 1) / 2
  assert(#reverse == n)
  assert(reverse[1] == 3)
  for i = 2, n do
    assert(reverse[i] == i * 4 - 4)
  end
end

io.write("digraph {\n")
local uid = g.u.first
while uid do
  local eid = g.uv.first[uid]
  while eid do
    local vid = g.uv.target[eid]
    io.write(uid, "->", vid, ";\n")
    eid = g.uv.after[eid]
  end
  uid = g.u.after[uid]
end
io.write("}\n")
