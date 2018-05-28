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

local sort = table.sort

local function copy(source_orders, target_orders)
  for i = 1, #source_orders do
    local source_order = source_orders[i]
    local target_order = target_orders[i]
    for j = 1, #source_order do
      target_order[j] = source_order[j]
    end
  end
end

local function wmedian(vu, orders, order_first, order_last, order_step)
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  -- 最初の階層はなにもしない
  for i = order_first + order_step, order_last, order_step do
    local order1 = orders[i - order_step]
    local order2 = orders[i]

    local order_map = {}
    for j = 1, #order1 do
      order_map[order1[j]] = j
    end

    local new_order = {}
    local sequence = {}

    for j = 1, #order2 do
      local uid = order2[j]
      local s = {}
      local eid = vu_first[uid]
      while eid do
        s[#s + 1] = order_map[vu_target[eid]]
        eid = vu_after[eid]
      end
      sort(s)
      local m = #s
      if m == 0 then
        new_order[j] = uid
      elseif m % 2 == 1 then
        sequence[#sequence + 1] = {
          uid = uid;
          median = s[(m + 1) / 2];
        }
      elseif m == 2 then
        sequence[#sequence + 1] = {
          uid = uid;
          median = (s[1] + s[2]) / 2;
        }
      else
        local n = m / 2
        local a = s[n]
        local b = s[n + 1]
        local left = a - s[1]
        local right = s[m] - b
        sequence[#sequence + 1] = {
          uid = uid;
          median = (a * right + b * left) / (left + right);
        }
      end
    end

    sort(sequence, function (a, b)
      return a.median < b.median
    end)

    local n = 0
    for j = 1, #sequence do
      while true do
        n = n + 1
        if not new_order[n] then
          new_order[n] = sequence[j].uid
          break
        end
      end
    end

    orders[i] = new_order
  end
end

local function crossing(g, orders)
  local count = 0
  local order1 = orders[1]
  for i = 2, #orders do
    local order2 = orders[i]
    print("<", i, table.concat(order1, " "))
    print(">", i, table.concat(order2, " "))
    count = count + count_crossings(g, order1, order2)
    order1 = order2
  end
  print("?", count)
  return count
end

return function (g, orders)
  local n = #orders

  local best = {}
  for i = 1, n do
    best[i] = {}
  end
  copy(orders, best)

  for i = 1, 12 do
    wmedian(g.vu, orders, 1, n, 1)
    print("[1]", i, crossing(g, orders), crossing(g, best))
    if crossing(g, orders) < crossing(g, best) then
      copy(orders, best)
    end
    wmedian(g.uv, orders, n, 1, -1)
    print("[2]", i, crossing(g, orders), crossing(g, best))
    if crossing(g, orders) < crossing(g, best) then
      copy(orders, best)
    end
  end

  return best
end
