-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local count_crossings = require "dromozoa.graph.count_crossings"

local function copy(source_orders, target_orders)
  for i = 1, #source_orders do
    local source_order = source_orders[i]
    local target_order = target_orders[i]
    for j = 1, #source_order do
      target_order[j] = source_order[j]
    end
  end
end

local function wmedian(g, orders, iter)
  if iter % 2 == 0 then
    for i = 1, #orders do
      local order = orders[i]
      local median = {}
      for j = 1, #order do
        local uid = order[j]
        median[uid] = median_value(g, uid, i - 1)
      end

    end
  else
  end
end

local function crossing(g, orders)
  local count = 0
  local order1 = orders[1]
  for i = 2, #orders do
    local order2 = orders[i]
    count = count + count_crossings(g, order1, order2)
    order1 = order2
  end
  return count
end

return function (g, orders)
  local best = {}
  for i = 1, #orders do
    best[i] = {}
  end
  copy(orders, best)

  for i = 1, 24 do
    wmedian(g, orders, i)
    if crossing(g, orders) < crossing(g, best) then
      copy(orders, best)
    end
  end

  return best
end
