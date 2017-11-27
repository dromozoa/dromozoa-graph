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

local tree = require "dromozoa.graph.tree"

local function visit(t, uid)
  local uv = t.uv
  local after = uv.after
  local vid = uv.first[uid]
  while vid do
    visit(t, vid)
    vid = after[vid]
  end
  print(uid)
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
t:add_edge(n1, n4)
t:add_edge(n3, n5)
t:add_edge(n3, n6)
t:add_edge(n4, n7)

visit(t, 1)

assert(t:remove_edge(n1, n3) == n4)
t:add_edge(n2, n3)

print("--")
visit(t, 1)

local n8 = t:add_vertex()
t:insert_edge(n4, n8)

print("--")
visit(t, 1)


