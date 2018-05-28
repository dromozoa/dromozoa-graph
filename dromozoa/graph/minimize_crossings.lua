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

local function copy(source_layers, target_layers)
  for i = 1, #source_layers do
    local source_order = source_layers[i]
    local target_order = target_layers[i]
    for j = 1, #source_order do
      target_order[j] = source_order[j]
    end
  end
end

local function median(uv, layers, layer_first, layer_last, layer_step)
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local south = layers[layer_first]
  for i = layer_first + layer_step, layer_last, layer_step do
    local north = layers[i]

    local order_map = {}
    for j = 1, #south do
      order_map[south[j]] = j
    end

    local p = {}
    local n = 0
    local order = {}
    local median_map = {}
    for j = 1, #north do
      local uid = north[j]
      local p = {}
      local m = 0
      local eid = uv_first[uid]
      while eid do
        m = m + 1
        p[m] = order_map[uv_target[eid]]
        eid = uv_after[eid]
      end
      for k = m + 1, #p do
        p[k] = nil
      end
      if m > 0 then
        n = n + 1
        north[j] = nil
        order[n] = uid
        if m == 1 then
          median_map[uid] = p[1]
        elseif m == 2 then
          median_map[uid] = (p[1] + p[2]) / 2
        else
          sort(p)
          if m % 2 == 1 then
            median_map[uid] = p[(m + 1) / 2]
          else
            local n = m / 2
            local a = p[n]
            local b = p[n + 1]
            local left = a - p[1]
            local right = p[m] - b
            median_map[uid] = (a * right + b * left) / (left + right)
          end
        end
      end
    end

    sort(order, function (a, b)
      return median_map[a] < median_map[b]
    end)

    local j = 0
    for k = 1, #order do
      while true do
        j = j + 1
        if not north[j] then
          north[j] = order[k]
          break
        end
      end
    end

    south = north
  end
end

local function crossing(g, order, layers, i)
  local count = 0
  if i < #layers then
    count = count + count_crossings(g, order, layers[i + 1])
  end
  if i > 1 then
    count = count + count_crossings(g, layers[i - 1], order)
  end
  return count
end

local function crossing(g, layers)
  local count = 0
  local order1 = layers[1]
  for i = 2, #layers do
    local order2 = layers[i]
    count = count + count_crossings(g, order1, order2)
    order1 = order2
  end
  return count
end

return function (g, layers)
  local n = #layers

  local best = {}
  for i = 1, n do
    best[i] = {}
  end
  copy(layers, best)

  for i = 1, 12 do
    median(g.uv, layers, 1, n, 1)
    if crossing(g, layers) < crossing(g, best) then
      copy(layers, best)
    end
    median(g.vu, layers, n, 1, -1)
    if crossing(g, layers) < crossing(g, best) then
      copy(layers, best)
    end
  end

  return best
end
