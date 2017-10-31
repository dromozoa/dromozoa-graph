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

local binary_heap = require "experimental.binary_heap"

local x = binary_heap()
x:add(3)
print(table.concat(x.tree, " "))
x:add(4)
print(table.concat(x.tree, " "))
x:add(5)
print(table.concat(x.tree, " "))
x:add(8)
print(table.concat(x.tree, " "))
x:add(11)
print(table.concat(x.tree, " "))
x:add(15)
print(table.concat(x.tree, " "))
print(x:pop())
print(table.concat(x.tree, " "))
print(x:pop())
print(table.concat(x.tree, " "))
print(x:pop())
print(table.concat(x.tree, " "))
print(x:pop())
print(table.concat(x.tree, " "))
print(x:pop())
print(table.concat(x.tree, " "))
print(x:pop())
print(table.concat(x.tree, " "))

