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

local array_list = require "experimental.array_list"
local linked_list = require "experimental.linked_list"
local naive_linked_list = require "experimental.naive_linked_list"

local N = 3000

local function construct(class)
  local x = class()
  for i = 1, N do
    x:add(i * i)
  end
  return class, x
end

local function each(x)
  local v = 0
  for _, value in x.each, x do
    v = v + value
  end
  return x, v
end

local classes = {
  array_list;
  linked_list;
  naive_linked_list;
}

local benchmarks = {}

local expect_value = 0
for i = 1, N do
  expect_value = expect_value + i * i
end

for i = 1, #classes do
  local class = classes[i]

  collectgarbage() collectgarbage() local count1 = collectgarbage "count"
  local _, data = construct(class)
  local _, value = each(data)
  collectgarbage() collectgarbage() local count2 = collectgarbage "count"
  assert(data.n == N)
  assert(value == expect_value)

  io.stderr:write(("%02d\t%d\n"):format(i, (count2 - count1) * 1024))

  benchmarks[("C%02d"):format(i)] = { construct, class }
  benchmarks[("E%02d"):format(i)] = { each, data }
end

return benchmarks
