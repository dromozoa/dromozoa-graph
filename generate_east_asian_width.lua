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

local dumper = require "dromozoa.commons.dumper"
local utf8 = require "dromozoa.utf8"
local linked_list = require "dromozoa.graph.linked_list"

local builder = require "dromozoa.parser.builder"
local regexp = require "dromozoa.parser.regexp"

local P = builder.pattern
local R = builder.range
local S = builder.set
local _ = builder()

-- https://www.unicode.org/reports/tr11/
-- https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt

local properties = {
  ["N"]  = true; -- neutral
  ["Na"] = true; -- narrow
  ["H"]  = true; -- halfwidth
  ["A"]  = true; -- ambiguous
  ["W"]  = true; -- wide
  ["F"]  = true; -- fullwidth
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
    code[#code + 1] = indent .. ("if c < %d then\n"):format(u)
    make_code(tree, code, j, depth)
    code[#code + 1] = indent .. ("else return \"%s\" end\n"):format(w)
  else
    code[#code + 1] = indent .. ("if c < %d then return \"%s\" else return \"%s\" end\n"):format(u, v, w)
  end
end

local function encode_utf8(code_point)
  local s = utf8.char(code_point)
  local a, b, c, d = string.byte(s, 1, #s)
  -- b = b or 0
  -- c = c or 0
  -- d = d or 0
  -- return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
  local v
  if d then
    v = a * 0x1000000 + b * 0x10000 + c * 0x100 + d
  elseif c then
    v = a * 0x10000 + b * 0x100 + c
  elseif b then
    v = a * 0x100 + b
  else
    v = a
  end
  return v
end

local function encode_utf8_2(code_point)
  local s = utf8.char(code_point)
  local a, b, c, d = string.byte(s, 1, #s)
  b = b or 0
  c = c or 0
  d = d or 0
  return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
end

local function make_code_utf8(tree, code, i, depth)
  local u = tree[i]
  local j = i * 2
  local v = tree[j]
  local w = tree[j + 1]

  local indent = ("  "):rep(depth)
  local depth = depth + 1

  if type(w) == "number" then
    code[#code + 1] = indent .. ("if c < %d then\n"):format(encode_utf8(u))
    make_code_utf8(tree, code, j, depth)
    code[#code + 1] = indent .. "else\n"
    make_code_utf8(tree, code, j + 1, depth)
    code[#code + 1] = indent .. "end\n"
  elseif type(v) == "number" then
    code[#code + 1] = indent .. ("if c < %d then\n"):format(encode_utf8(u))
    make_code_utf8(tree, code, j, depth)
    code[#code + 1] = indent .. ("else return \"%s\" end\n"):format(w)
  else
    code[#code + 1] = indent .. ("if c < %d then return \"%s\" else return \"%s\" end\n"):format(encode_utf8(u), v, w)
  end
end

local filename = ...
local flat = make_flat(filename)
local range = make_range(flat)
local tree = make_tree(range)

local code = {[[
-- generated from EastAsianWidth-10.0.0.txt
return function (c)
]]}
make_code_utf8(tree, code, 1, 1)
code[#code + 1] = [[
end
]]

local code = table.concat(code)
-- io.write(code)

local f = assert((loadstring or load)(code))()
for i = 0, 0x10FFFF do
  -- io.write(("%d\t%s\n"):format(i, flat[i]))
  -- assert(flat[i] == f(i)
  -- print(flat[i], f(encode_utf8(i)))
  assert(flat[i] == f(encode_utf8(i)))
end

local patterns = {}

local function idiv(x, y)
  return math.floor(x / y)
end

local function encode_utf8_impl(a)
  if a < 0 then
    return nil
  elseif a <= 0x7F then
    return a
  elseif a <= 0x07FF then
    local b = a % 0x40
    local a = idiv(a, 0x40)
    return a, b
  elseif a <= 0xFFFF then
    if 0xD800 <= a and a <= 0xDFFF then
      return nil
    end
    local c = a % 0x40
    local a = idiv(a, 0x40)
    local b = a % 0x40
    local a = idiv(a, 0x40)
    return a, b, c
  elseif a <= 0x10FFFF then
    local d = a % 0x40
    local a = idiv(a, 0x40)
    local c = a % 0x40
    local a = idiv(a, 0x40)
    local b = a % 0x40
    local a = idiv(a, 0x40)
    return a, b, c, d
  else
    return nil
  end
end

local function encode_bits(a)
  if a < 0 then
    return nil
  elseif a <= 0x7F then
    return 0, 0, 0, a
  elseif a <= 0x07FF then
    local b = a % 0x40
    local a = idiv(a, 0x40)
    return 0, 0, 0xC0 + a, 0x80 + b
  elseif a <= 0xFFFF then
    -- if 0xD800 <= a and a <= 0xDFFF then
    --   return nil
    -- end
    local c = a % 0x40
    local a = idiv(a, 0x40)
    local b = a % 0x40
    local a = idiv(a, 0x40)
    return 0, 0xE0 + a, 0x80 + b, 0x80 + c
  elseif a <= 0x10FFFF then
    local d = a % 0x40
    local a = idiv(a, 0x40)
    local c = a % 0x40
    local a = idiv(a, 0x40)
    local b = a % 0x40
    local a = idiv(a, 0x40)
    return 0xF0 + a, 0x80 + b, 0x80 + c, 0x80 + d
  else
    return nil
  end

  -- local d = a % 0x40
  -- local a = idiv(a, 0x40)
  -- local c = a % 0x40
  -- local a = idiv(a, 0x40)
  -- local b = a % 0x40
  -- local a = idiv(a, 0x40)
  -- return a, b, c, d
end

local function encode_utf8_range(x)
  local a = x.a
  local b1 = x.b[1]
  local b2 = x.b[2]
  local c1 = x.c[1]
  local c2 = x.c[2]
  local d1 = x.d[1]
  local d2 = x.d[2]

  if c1 == 0 then
    return R(string.char(d1, d2))
  elseif b1 == 0 then
    return R(string.char(c1, c2)) * R(string.char(d1, d2))
  elseif a == 0 then
    return R(string.char(b1, b2)) * R(string.char(c1, c2)) * R(string.char(d1, d2))
  else
    return P(string.char(a)) * R(string.char(b1, b2)) * R(string.char(c1, c2)) * R(string.char(d1, d2))
  end
end

local patterns = {}

for i = 1, #range do
  local r = range[i]
  local first = r.first
  local last
  local v = r.property
  if i < #range then
    last = range[i + 1].first - 1
  else
    last = 0x10FFFF
  end

  local s1 = utf8.char(first)
  local s2 = utf8.char(last)

  local n = last - first + 1
  -- print(("= %06X %02X %02X %02X %02X %d"):format(first, a1, b1, c1, d1, n))
  -- print(("  %06X %02X %02X %02X %02X"):format(last, a2, b2, c2, d2))

  local items = {}
  for i = first, last do
    local a, b, c, d = encode_bits(i)
    local item = items[#items]
    if not item then
      items[#items + 1] = { a = a, b = b, c = c, d = { d, d } }
    else
      if item.a == a and item.b == b and item.c == c and item.d[2] + 1 == d then
        item.d[2] = d
      else
        items[#items + 1] = { a = a, b = b, c = c, d = { d, d } }
      end
    end
  end

  local items1 = items
  local items = {}
  for i = 1, #items1 do
    local item1 = items1[i]
    local item2 = { a = item1.a, b = item1.b, c = { item1.c, item1.c }, d = item1.d }
    if item2.d[1] == 0x80 and item2.d[2] == 0xBF then
      local item3 = items[#items]
      if not item3 then
        items[#items + 1] = item2
      else
        if item3.a == item2.a and item3.b == item2.b and item3.c[2] + 1 == item2.c[2] and item3.d[1] == 0x80 and item3.d[2] == 0xBF then
          item3.c[2] = item2.c[2]
        else
          items[#items + 1] = item2
        end
      end
    else
      items[#items + 1] = item2
    end
  end

  local items2 = items
  local items = {}
  for i = 1, #items2 do
    local item1 = items2[i]
    local item2 = { a = item1.a, b = { item1.b, item1.b }, c = item1.c, d = item1.d }
    if item2.c[1] == 0x80 and item2.c[2] == 0xBF and item1.d[1] == 0x80 and item1.d[2] == 0xBF then
      local item3 = items[#items]
      if not item3 then
        items[#items + 1] = item2
      else
        if item3.a == item2.a and item3.b[2] + 1 == item2.b[2] and item3.c[1] == 0x80 and item3.c[2] == 0xBF and item3.d[1] == 0x80 and item3.d[2] == 0xBF then
          item3.b[2] = item2.b[2]
        else
          items[#items + 1] = item2
        end
      end
    else
      items[#items + 1] = item2
    end
  end

  print(first, "====", last)
  for i = 1, #items do
    local item = items[i]
    print(("%02X %02X-%02X %02X-%02X %02X-%02X"):format(item.a, item.b[1], item.b[2], item.c[1], item.c[2], item.d[1], item.d[2]))
  end

  local pattern = encode_utf8_range(items[1])
  for i = 2, #items do
    pattern = pattern + encode_utf8_range(items[i])
  end

  if patterns[v] then
    patterns[v] = patterns[v] + pattern
  else
    patterns[v] = pattern
  end
end

_:lexer()
  :_ (patterns.N)  :as "N"
  :_ (patterns.Na) :as "Na"
  :_ (patterns.H)  :as "H"
  :_ (patterns.A)  :as "A"
  :_ (patterns.W)  :as "W"
  :_ (patterns.F)  :as "F"

local lexer = _:build()
lexer:compile("east_asian_width_lexer.lua")

--[[
io.stderr:write("construct nfa\n")
local re_n  = regexp(patterns.n,  1):nfa_to_dfa():minimize()
local re_na = regexp(patterns.na, 2):nfa_to_dfa():minimize()
local re_h  = regexp(patterns.h,  3):nfa_to_dfa():minimize()
local re_a  = regexp(patterns.a,  4):nfa_to_dfa():minimize()
local re_w  = regexp(patterns.w,  5):nfa_to_dfa():minimize()
local re_f  = regexp(patterns.f,  6):nfa_to_dfa():minimize()
local nfa = re_n:union(re_na):union(re_h):union(re_a):union(re_w):union(re_f)

io.stderr:write("nfa to dfa\n")
local dfa = nfa:nfa_to_dfa()
io.stderr:write("minimize dfa\n")
local dfa = dfa:minimize()
io.stderr:write("write dfa\n")
dfa:write_graphviz("test.dot")
]]
