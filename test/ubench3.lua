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

local t = {}
for i = 1, n do
  t[i] = i
end

local l = linked_list()
local lm = {}
for i = 1, n do
  lm[l:add()] = i
end

local f = forward_list()
local fm = {}
for i = 1, n do
  fm[f:add()] = i
end

local L = linked_list2()
local Lm = {}
for i = 1, n do
  Lm[L:add()] = i
end

local function t1(x)
  local v = 0
  for i = 1, #x do
    v = v + x[i]
  end
  return x, v
end

local function t2(x)
  local v = 0
  for _, value in ipairs(x) do
    v = v + value
  end
  return x, v
end

local function t3(x)
  local v = 0
  for _, value in pairs(x) do
    v = v + value
  end
  return x, v
end

local function l0(x)
  local v = 0
  local next = l.next
  local first = l.first
  local id = first
  repeat
    v = v + lm[id]
    id = next[id]
  until id == first
  return x, v
end

local function l1(x)
  local v = 0
  for id in l:each() do
    v = v + lm[id]
  end
  return x, v
end

local function l2(x)
  local v = 0
  local id = f.head
  repeat
    v = v + fm[id]
    id = f[id]
  until not id
  return x, v
end

local function l3(x)
  local v = 0
  local Lnext = L.next
  local id = L.first
  repeat
    v = v + Lm[id]
    id = Lnext[id]
  until not id
  return x, v
end

local function l4(x)
  local v = 0
  for id in L.next_impl, L do
    v = v + Lm[id]
  end
  return x, v
end

local function l5(x)
  local v = 0
  L:each(function (id)
    v = v + Lm[id]
  end)
  return x, v
end


return {
  t1 = { t1, t };
  t2 = { t2, t };
  t3 = { t3, t };
  l0 = { l0, l };
  l1 = { l1, l };
  l2 = { l2, f };
  l3 = { l3, L };
  l4 = { l4, L };
  l5 = { l5, L };
}
