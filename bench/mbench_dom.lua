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

local json = require "dromozoa.commons.json"
local read_file = require "dromozoa.commons.read_file"

local filename = ...

collectgarbage() collectgarbage()
local c1 = collectgarbage "count"

local doc1 = json.decode(read_file(filename))

collectgarbage() collectgarbage()
local c2 = collectgarbage "count"
print("doc1", (c2 - c1) * 1024)

local count_element = 0
local count_text = 0
local count_attr = {}
local count_child = {}
local attr_map = {}

local function visit(u, depth)
  count_element = count_element + 1
  local n = 0
  for k in pairs(u[2]) do
    n = n + 1
    if not attr_map[k] then
      attr_map[k] = 1
    else
      attr_map[k] = attr_map[k] + 1
    end
  end
  local c = count_attr[n]
  if not c then
    c = 0
  end
  count_attr[n] = c + 1
  local n = #u[3]
  local c = count_child[n]
  if not c then
    c = 0
  end
  count_child[n] = c + 1
  for i = 1, n do
    local v = u[3][i]
    if type(v) == "string" then
      count_text = count_text + 1
    else
      visit(v, depth + 1)
    end
  end
end

visit(doc1, 0)

print("count_element", count_element)
print("count_text", count_text)

local max = 0
for i in pairs(count_attr) do
  if max < i then
    max = i
  end
end
for i = 0, max do
  local v = count_attr[i]
  if v then
    print("count_attr", i, count_attr[i])
  end
end

for k, v in pairs(attr_map) do
  print("attr_map", k, v)
end

--[[
local max = 0
for i in pairs(count_child) do
  if max < i then
    max = i
  end
end
for i = 0, max do
  local v = count_child[i]
  if v then
    print("count_child", i, v)
  end
end
]]

local function visit(u)
  local result = { [0] = u[1] }

  for k, v in pairs(u[2]) do
    result[k] = v
  end

  for i = 1, #u[3] do
    local v = u[3][i]
    if type(v) == "string" then
      result[i] = u[3]
    else
      result[i] = visit(v)
    end
  end

  return result
end

local function visit(out, u)
  local name = out[1]
  local attr = out[2]
  local data = out[3]

  local n = #name + 1
  name[n] = u[1]

  local A = {}
  local c = 0
  for k, v in pairs(u[2]) do
    c = c + 1
    A[k] = v
  end
  if c > 0 then
    attr[n] = A
  end

  local D = {}
  for i = 1, #u[3] do
    local v = u[3][i]
    if type(v) == "string" then
      D[i] = u[3]
    else
      D[i] = visit(out, v)
    end
  end
  if #D > 0 then
    if #D == 1 then
      data[n] = D[1]
    else
      data[n] = D
    end
  end

  return n
end

local doc2 = { {}, {}, {} }
visit(doc2, doc1)
local doc1 = nil

collectgarbage() collectgarbage()
local c0 = collectgarbage "count"
doc2[3] = nil
collectgarbage() collectgarbage()
local c2 = collectgarbage "count"
print("doc2.data", (c0 - c2) * 1024)

collectgarbage() collectgarbage()
local c1 = collectgarbage "count"
doc2[2] = nil
collectgarbage() collectgarbage()
local c2 = collectgarbage "count"
print("doc2.attr", (c1 - c2) * 1024)

collectgarbage() collectgarbage()
local c1 = collectgarbage "count"
doc2[1] = nil
collectgarbage() collectgarbage()
local c2 = collectgarbage "count"
print("doc2.name", (c1 - c2) * 1024)

collectgarbage() collectgarbage()
local c1 = collectgarbage "count"
doc2[1] = nil
collectgarbage() collectgarbage()
local c2 = collectgarbage "count"
print("doc2.name", (c1 - c2) * 1024)

collectgarbage() collectgarbage()
local c1 = collectgarbage "count"
doc2 = nil
collectgarbage() collectgarbage()
local c2 = collectgarbage "count"
print("doc2", (c0 - c2) * 1024)
