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

local N = 257
local D = 16

do
  local x = {}
  local y = {}

  collectgarbage() collectgarbage() local count1 = collectgarbage "count"

  for i = 1, N do
    x[#x + 1] = #y + 1
    for j = 1, D do
      y[#y + 1] = i * j
    end
  end

  collectgarbage() collectgarbage() local count2 = collectgarbage "count"
  print((count2 - count1) * 1024)
end

do
  local x = {}

  collectgarbage() collectgarbage() local count1 = collectgarbage "count"

  for i = 1, N do
    local y = {}
    x[#x + 1] = y
    for j = 1, D do
      y[#y + 1] = i * j
    end
  end

  collectgarbage() collectgarbage() local count2 = collectgarbage "count"
  print((count2 - count1) * 1024)
end



