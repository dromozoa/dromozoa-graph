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

local linked_list = require "dromozoa.graph.linked_list"

local function check(source, expect)
  assert(source.n == #expect)
  local i = 0
  local id = source.first
  local after = source.after
  while id do
    i = i + 1
    assert(id == expect[i])
    id = after[id]
  end
  local i = source.n + 1
  local id = source.last
  local before = source.before
  while id do
    i = i - 1
    assert(id == expect[i])
    id = before[id]
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

assert(x:insert(2) == 4)
check(x, { 3, 1, 4, 2 })

local id = x.first
while id do
  id = x:remove(id)
end

assert(x.id == 4)
assert(x.n == 0)

assert(x:add() == 5)
check(x, { 5 })

assert(x:add() == 6)
check(x, { 5, 6 })
