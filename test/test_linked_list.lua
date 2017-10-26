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

local linked_list = require "dromozoa.graph.linked_list"

local function check(source, expect)
  local i = 0
  assert(source.n == #expect)
  for id in source:each() do
    i = i + 1
    assert(id == expect[i])
  end
end

local x = linked_list()
check(x, {})

assert(x:add() == 1)
check(x, { 1 })

assert(x:add() == 2)
check(x, { 1, 2 })

assert(x:insert(1) == 3)
check(x, { 3, 1, 2 })

assert(x:insert(3) == 4)
check(x, { 4, 3, 1, 2 })

assert(x:insert(2) == 5)
check(x, { 4, 3, 1, 5, 2 })

for id in x:each() do
  x:remove(id)
end
assert(x.id == 5)
assert(x.n == 0)
