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

local filename = "doc/EastAsianWidth.txt"

local function ptov(p)
  if not p or p == "N" then
    return 0
  elseif p == "A" then
    return 1
  elseif p == "F" then
    return 2
  elseif p == "H" then
    return 3
  elseif p == "Na" then
    return 4
  elseif p == "W" then
    return 5
  end
end

local function make_flat()
  local flat = {}
  local prev
  for line in io.lines(filename) do
    local a, b, p = line:match("^(%x+)%.%.(%x+);(%a+)")
    if not a then
      a, p = line:match("^(%x+);(%a+)")
      b = a
    end
    if a then
      local a = tonumber(a, 16)
      local b = tonumber(b, 16)
      local v = ptov(p)

      assert(a <= b)
      assert(not prev or prev < a)

      for i = a, b do
        flat[i] = v
      end

      prev = b
    end
  end

  for i = 0, 0x10FFFF do
    if not flat[i] then
      flat[i] = 0
    end
  end

  return flat
end

local function make_range(flat)
  local range = {}

  local i = 0
  local u = flat[0]
  for j = 2, 0x10FFFF do
    local v = flat[j]
    if u ~= v then
      range[#range + 1] = { i, j - 1, u }
      i = j
      u = v
    end
  end
  range[#range + 1] = { i, 0x10FFFF, u }

  return range
end

local function make_tree(range)
  local m = #range - 1
  local n = math.ceil(math.log(m, 2))

  local indice = linked_list()
  for i = 1, m do
    indice:add()
  end

  local tree = {}

  for i = n, 1, -1 do
    local x = 2^(i-1)
    local index = indice.first
    while index and x <= m do
      tree[x] = range[index + 1][1]
      index = indice:remove(index)
      if index then
        index = indice.after[index]
      end
      x = x + 1
    end
  end

  local leaf = {}

  for i = 1, #range do
    local r = range[i]
    local x = r[1]
    local v = r[3]
    local index = 1
    while true do
      if x < tree[index] then
        index = index * 2
      else
        index = index * 2 + 1
      end
      if not tree[index] then
        leaf[index - m] = v
        break
      end
    end
  end

  return tree, leaf
end

collectgarbage()
collectgarbage()
local c1 = collectgarbage("count")

local flat = make_flat()

collectgarbage()
collectgarbage()
local c2 = collectgarbage("count")

local range = make_range(flat)

collectgarbage()
collectgarbage()
local c3 = collectgarbage("count")

local tree, leaf = make_tree(range)

collectgarbage()
collectgarbage()
local c4 = collectgarbage("count")

local sum = 0
for i = 1, #range do
  local r = range[i]
  sum = sum + (r[2] - r[1] + 1)
end
assert(sum == 0x110000)

-- print("flat", c2 - c1, #flat)
-- print("range", c3 - c2, #range)
-- print("tree", c4 - c3, #tree, #leaf)

local function run(fn, first, last)
  local sum = 0
  for i = first, last do
    sum = sum + fn(i)
  end
  return fn, first, last, sum
end

local function fn_flat(code_point)
  return flat[code_point]
end

local m = #range - 1
local function fn_tree(code_point)
  local x = 1
  while true do
    local v = tree[x]
    if not v then
      return leaf[x - m]
    end
    if code_point < v then
      x = x * 2
    else
      x = x * 2 + 1
    end
  end
end

local algorithms = {
  fn_flat,
  fn_tree,
}

local benchmarks = {}
for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], 0x3000, 0x3800 }
end
return benchmarks
