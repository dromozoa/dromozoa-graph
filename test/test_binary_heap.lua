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

local binary_heap = require "dromozoa.graph.binary_heap"

local verbose = os.getenv "VERBOSE" == "1"

local function check(source, expect)
  if verbose then
    print("result", table.concat(source.heap, " "))
    print("expect", table.concat(expect, " "))
  end
  local n = #expect
  assert(n == source.n)
  assert(n == #source.heap)
  for i = 1, n do
    assert(source.heap[i] == expect[i])
  end
end

local x = binary_heap()
x:push(5, 1)
check(x, { 5 })
x:push(4, 2)
check(x, { 4, 5 })
x:push(3, 3)
check(x, { 3, 5, 4 })
x:push(2, 4)
check(x, { 2, 3, 4, 5 })
x:push(1, 5)
check(x, { 1, 2, 4, 5, 3 })

assert(x:pop() == 1)
assert(x:pop() == 2)
assert(x:pop() == 3)
assert(x:pop() == 4)
assert(x:pop() == 5)

local x = binary_heap()
x:push(1, 100)
x:push(2, 200)
x:push(3, 300)
x:push(4, 400)
x:push(5, 500)
check(x, { 5, 4, 2, 1, 3 })

x:remove(3)
check(x, { 5, 4, 2, 1 })

x:push(6, 600)
x:push(7, 700)
check(x, { 7, 5, 6, 1, 4, 2 })

x:remove(5)
check(x, { 7, 4, 6, 1, 2 })

x:push(5, 500)
check(x, { 7, 4, 6, 1, 2, 5 })

x:remove(2)
check(x, { 7, 5, 6, 1, 4 })

x:update(5, 0)
check(x, { 7, 4, 6, 1, 5 })

x:update(1, 1000)
check(x, { 1, 7, 6, 4, 5 })

local x = binary_heap()
x:push(1, 1)
assert(x.n == 1)
assert(x:pop() == 1)
assert(x.n == 0)
assert(not x:pop())
assert(x.n == 0)

local x = binary_heap()
x:push(1, 1)
x:push(2, 2)
x:push(3, 3)
x:push(4, 4)
check(x, { 4, 3, 2, 1 })
x:increase(3, 1)
check(x, { 4, 3, 2, 1 })
x:increase(3, 1)
check(x, { 3, 4, 2, 1 })
x:decrease(3, 2)
check(x, { 4, 3, 2, 1 })
