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

-- local n = 10000
local n = 3000

local function table_insert()
  local x = {}
  for i = 1, n do
    -- table.insert(x, i)
    x[i] = i
  end
  return x
end

local function table_insert_remove()
  local x = {}
  for i = 1, n do
    -- table.insert(x, i)
    x[i] = i
  end
  for i = 1, n do
    table.remove(x, i)
  end
  return x
end

local function list1_insert()
  local x = linked_list()
  local v = {}
  for i = 1, n do
    v[x:insert()] = i
  end
  return x
end

local function list1_insert_remove()
  local x = linked_list()
  local v = {}
  for i = 1, n do
    v[x:insert()] = i
  end
  for i in x:each() do
    v[i] = nil
    x:remove(i)
  end
  return x
end

local class = {}
local metatable = { __index = class }

return {
  table_insert = { table_insert };
  table_insert_remove = { table_insert_remove };
  list1_insert = { list1_insert };
  list1_insert_remove = { list1_insert_remove };
}
