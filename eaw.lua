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

-- https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt

local data = {}

local prev

local data = {}
local count = {}

for line in io.lines() do
  local a, b, p = line:match("^(%x+)%.%.(%x+);(%a+)")
  if not a then
    a, p = line:match("^(%x+);(%a+)")
    b = a
  end
  if a then
    local first = tonumber(a, 16)
    local last = tonumber(b, 16)
    assert(first <= last)
    assert(not prev or prev < first)
    for code_point = first, last do
      data[code_point] = p
    end
    local c = count[p]
    if not c then
      count[p] = last - first + 1
    else
      count[p] = c + last - first + 1
    end
    prev = first
  end
end

local properties = { "A", "F", "H", "N", "Na", "W" }
local sum = 0
for i = 1, #properties do
  local p = properties[i]
  local c = count[p]
  if p ~= "N" then
    print(p, c)
  end
  sum = sum + c
end

local S = 0x110000
local A = count.A
local F = count.F
local H = count.H
local Na = count.Na
local W = count.W
local N = S - A - F - H - Na - W

local a = A / S
local f = F / S
local h = H / S
local n = N / S
local na = Na / S
local w = W / S

local sum = 0

local function fn(V)
  local v = V / S
  local bits = -math.log(v, 2) * V
  sum = sum + bits
  return bits
end

io.write(([[
A : %.17f
F : %.17f
H : %.17f
N : %.17f
Na: %.17f
W : %.17f
]]):format(fn(A), fn(F), fn(H), fn(N), fn(Na), fn(W)))

-- 157KiB
print(sum)

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

local out = assert(io.open("test.dat", "w"))
for i = 0, 0x10FFFF do
  local p = data[i]
  out:write(ptov(p))
end
out:close()

local out = assert(io.open("test-rle.dat", "w"))

local sum = 0
local i = 0
local u = ptov(data[i])
for j = 1, 0x10FFFF do
  local v = ptov(data[j])
  if u ~= v then
    out:write(("%d,%d\n"):format(u, j - i))
    sum = sum + j - i
    i = j
    u = v
  end
end
out:write(("%d,%d\n"):format(u, 0x110000 - i))
sum = sum + 0x110000 - i
out:close()

print(sum)
