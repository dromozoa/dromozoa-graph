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

-- https://www.unicode.org/reports/tr11/
-- https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt

local properties = {
  ["N"]  = 1; -- neutral
  ["Na"] = 2; -- narrow
  ["H"]  = 3; -- halfwidth
  ["A"]  = 4; -- ambiguous
  ["W"]  = 5; -- wide
  ["F"]  = 6; -- fullwidth
}

local function make_flat(filename)
  local flat = {}
  local prev

  for line in io.lines(filename) do
    local first, last, property = line:match("^(%x+)%.%.(%x+);(%a+)")
    if not first then
      first, property = line:match("^(%x+);(%a+)")
      last = first
    end
    if first then
      local first = tonumber(first, 16)
      local last = tonumber(last, 16)
      assert(first <= last)
      assert(not prev or prev < first)
      assert(properties[property])
      for i = first, last do
        flat[i] = property
      end
      prev = last
    end
  end

  for i = 0, 0x10FFFF do
    if not flat[i] then
      flat[i] = "N"
    end
  end

  return flat
end

local function make_range(flat)
  local range = {}
  local n = 0

  local first = 0
  local property = flat[first]
  for i = 1, 0x10FFFF do
    local p = flat[i]
    if property ~= p then
      n = n + 1
      range[n] = { first = first; property = property }
      first = i
      property = p
    end
  end

  range[n + 1] = { first = first; property = property }

  return range
end

local function make_tree(range)
  local m = #range - 1
  local n = math.ceil(math.log(m) / math.log(2)) - 1

  local indice = linked_list()
  for i = 1, m do
    indice:add()
  end

  local tree = {}

  for i = n, 0, -1 do
    local j = 2^i
    local index = indice.first
    while index and j <= m do
      tree[j] = range[index + 1].first
      index = indice:remove(index)
      if index then
        index = indice.after[index]
      end
      j = j + 1
    end
  end

  for i = 1, #range do
    local r = range[i]
    local first = r.first
    local j = 1
    repeat
      if first < tree[j] then
        j = j * 2
      else
        j = j * 2 + 1
      end
    until not tree[j]
    tree[j] = r.property
  end

  return tree
end

local function make_code(tree, code, i, depth)
  local u = tree[i]
  local j = i * 2
  local v = tree[j]
  local w = tree[j + 1]

  local indent = ("  "):rep(depth)
  local depth = depth + 1

  if type(w) == "number" then
    code[#code + 1] = indent .. ("if c < %d then\n"):format(u)
    make_code(tree, code, j, depth)
    code[#code + 1] = indent .. "else\n"
    make_code(tree, code, j + 1, depth)
    code[#code + 1] = indent .. "end\n"
  elseif type(v) == "number" then
    local pw = properties[w]
    code[#code + 1] = indent .. ("if c < %d then\n"):format(u)
    make_code(tree, code, j, depth)
    -- code[#code + 1] = indent .. ("else return %d end\n"):format(pw)
    code[#code + 1] = indent .. ("else return \"%s\" end\n"):format(w)
  else
    local pv = properties[v]
    local pw = properties[w]
    -- code[#code + 1] = indent .. ("if c < %d then return %d else return %d end\n"):format(u, pv, pw)
    code[#code + 1] = indent .. ("if c < %d then return \"%s\" else return \"%s\" end\n"):format(u, v, w)
  end
end

local filename = ...
local flat = make_flat(filename)
local range = make_range(flat)
local tree = make_tree(range)

local code = {[[
return function (c)
]]}
make_code(tree, code, 1, 1)
code[#code + 1] = [[
end
]]

local code = table.concat(code)

local f = assert((loadstring or load)(code))()

if true then
  for i = 0, 0x10FFFF do
    -- assert(properties[flat[i]] == f(i))
    assert(flat[i] == f(i))
  end
end

io.write(code)
