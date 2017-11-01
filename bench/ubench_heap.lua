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
local binary_heap2 = require "experimental.binary_heap2"
local binary_heap3 = require "experimental.binary_heap3"

local N = 1000

local value = {}

for i = 1, N do
  value[i] = (1103515245 * i + 12345) % 0x10000
end

local function push(class)
  local x = class()
  for i = 1, N do
    x:push(i, value[i])
  end
  return class, x
end

local function push_pop(class)
  local _, x = push(class)
  local v = 0
  while true do
    local id = x:pop()
    if id then
      v = v + id
    else
      break
    end
  end
  return class, v
end

local classes = {
  binary_heap;
  binary_heap2;
  binary_heap3;
}

local benchmarks = {}

for i = 1, #classes do
  local class = classes[i]
  benchmarks[("A%02d"):format(i)] = { push, class }
  benchmarks[("B%02d"):format(i)] = { push_pop, class }
end

return benchmarks
