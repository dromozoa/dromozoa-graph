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

local function bench_test(n)
  collectgarbage()
  collectgarbage()
  local count1 = collectgarbage "count"

  local t = {}
  for i = 1, n do
    t[i] = math.random(n)
  end

  collectgarbage()
  collectgarbage()
  local count2 = collectgarbage "count"

  print(("%d\t%d"):format(n, (count2 - count1) * 1024))
end

for i = 1, 48 do
  local n = 2^(i * 0.25 + 8)
  n = n - n % 1
  bench_test(n)
end
