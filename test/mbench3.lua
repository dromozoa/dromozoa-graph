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

local function bench_test()
  collectgarbage() collectgarbage() local count1 = collectgarbage "count"
  local a = {}
  collectgarbage() collectgarbage() local count2 = collectgarbage "count"
  print(("%d\t%d"):format(0, (count2 - count1) * 1024))
  collectgarbage() collectgarbage() local count1 = collectgarbage "count"
  local b = {42}
  collectgarbage() collectgarbage() local count2 = collectgarbage "count"
  print(("%d\t%d"):format(1, (count2 - count1) * 1024))
end

bench_test()
