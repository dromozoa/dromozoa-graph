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

local forward_list = require "dromozoa.graph.forward_list"
local linked_list = require "dromozoa.graph.linked_list"
local linked_list2 = require "dromozoa.graph.linked_list2"

-- local n = 10000
local n = 3000

local function t1()
  local x = {}
  for i = 1, n do
    x[i] = i
  end
  return x
end

local function t2()
  local x = {}
  for i = 1, n do
    x[#x + 1] = i
  end
  return x
end

local function t3()
  local x = {}
  for i = 1, n do
    table.insert(x, i)
  end
  return x
end

local function l1()
  local x = linked_list()
  local v = {}
  for i = 1, n do
    v[x:add()] = i
  end
  return x
end

local function l2()
  local x = forward_list()
  local v = {}
  for i = 1, n do
    v[x:add()] = i
  end
  return x
end

local function l3()
  local x = linked_list2()
  local v = {}
  for i = 1, n do
    v[x:add()] = i
  end
  return x
end

return {
  t1 = { t1 };
  t2 = { t2 };
  t3 = { t3 };
  l1 = { l1 };
  l2 = { l2 };
  l3 = { l3 };
}
