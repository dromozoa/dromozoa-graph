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

local t = tree()

t:add_node(1, 2)
t:add_node(1, 3)
t:add_node(1, 4)
t:add_node(3, 5)
t:add_node(3, 6)
t:add_node(4, 7)

local function visit(t, uid)
  local after = t.after

  local vid = t.first[uid]
  while vid do
    visit(t, vid)
    vid = after[vid]
  end

  print(uid)
end
visit(t, 1)

assert(t:remove_node(3) == 4)
t:add_node(2, 3)

print("--")
visit(t, 1)

t:insert_node(4, 8)

print("--")
visit(t, 1)


