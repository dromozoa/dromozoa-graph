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

local tree = require "dromozoa.graph.tree"

local function visit(t, data, uid)
  local uv = t.uv
  local after = uv.after
  local vid = uv.first[uid]
  while vid do
    visit(t, data, vid)
    vid = after[vid]
  end
  data[#data + 1] = uid
end

local t = tree()

local n1 = t:add_vertex()
local n2 = t:add_vertex()
local n3 = t:add_vertex()
local n4 = t:add_vertex()
local n5 = t:add_vertex()
local n6 = t:add_vertex()
local n7 = t:add_vertex()

t:add_edge(n1, n2)
t:add_edge(n1, n3)
t:add_edge(n2, n4)
t:add_edge(n2, n5)
t:add_edge(n3, n6)
t:add_edge(n3, n7)

assert(t.uv.first[n1] == n2)
assert(t.uv.last[n1] == n3)
assert(t.uv.after[n1] == nil)
assert(t.uv.after[n2] == n3)
assert(t.uv.after[n3] == nil)
assert(t.uv.before[n1] == nil)
assert(t.uv.before[n2] == nil)
assert(t.uv.before[n3] == n2)
assert(t.vu[n1] == nil)
assert(t.vu[n2] == n1)
assert(t.vu[n3] == n1)

assert(t:remove_edge(n2) == n3)

assert(t.uv.first[n1] == n3)
assert(t.uv.last[n1] == n3)
assert(t.uv.after[n1] == nil)
assert(t.uv.after[n2] == nil)
assert(t.uv.after[n3] == nil)
assert(t.uv.before[n1] == nil)
assert(t.uv.before[n2] == nil)
assert(t.uv.before[n3] == nil)
assert(t.vu[n1] == nil)
assert(t.vu[n2] == nil)
assert(t.vu[n3] == n1)

assert(t:remove_edge(n3) == nil)

assert(t.uv.first[n1] == nil)
assert(t.uv.last[n1] == nil)
assert(t.uv.after[n1] == nil)
assert(t.uv.after[n2] == nil)
assert(t.uv.after[n3] == nil)
assert(t.uv.before[n1] == nil)
assert(t.uv.before[n2] == nil)
assert(t.uv.before[n3] == nil)
assert(t.vu[n1] == nil)
assert(t.vu[n2] == nil)
assert(t.vu[n3] == nil)

t:add_edge(n1, n2)
t:insert_edge(n2, n3)

local data = {}
visit(t, data, 1)
assert(table.concat(data, " ") == "6 7 3 4 5 2 1")

assert(t.uv.first[n1] == n3)
assert(t.uv.last[n1] == n2)
assert(t.uv.after[n1] == nil)
assert(t.uv.after[n2] == nil)
assert(t.uv.after[n3] == n2)
assert(t.uv.before[n1] == nil)
assert(t.uv.before[n2] == n3)
assert(t.uv.before[n3] == nil)
assert(t.vu[n1] == nil)
assert(t.vu[n2] == n1)
assert(t.vu[n3] == n1)
