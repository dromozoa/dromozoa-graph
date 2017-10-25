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

local S_t_32 = 32
local S_t_64 = 56
local S_v = 16

local function log2(x)
  return math.log(x, 2)
end

local function left(m, S_t)
  return log2(S_t / S_v / m + 1)
end

local function right(n)
  local v = log2(n)
  return math.ceil(v) - v
end

local function prob(n, v, f)
  local c = 0
  for i = 1, n do
    if right(i) < v then
      c = c + 1
    end
  end
  return c / n * 100
end

local function S_a(n)
  return S_v * 2^math.ceil(log2(n))
end

local function prob_low(m, S_t, n)
  local c = 0
  for i = 1, n do
    local l = m * S_a(i)
    local r = (S_t + m * S_v) * i
    if l < r then
      c = c + 1
    end
  end
  return c / n * 100
end

local n = 2^18

for m = 1, 12 do
  local l_32 = left(m, S_t_32)
  local l_64 = left(m, S_t_64)
  print(("<tr><td>%d</td><td>%.1f%%</td><td>%.1f%%</td></tr>"):format(m, prob(n, l_32), prob(n, l_64)))
end

io.write("\n")

for m = 1, 12 do
  print(("<tr><td>%d</td><td>%.1f%%</td><td>%.1f%%</td></tr>"):format(m, prob_low(m, S_t_32, n), prob_low(m, S_t_64, n)))
end
