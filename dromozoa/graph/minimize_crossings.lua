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

local function wmedian(uv, layers, layer_first, layer_last, layer_step)
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  for i = layer_first + layer_step, layer_last, layer_step do
    local north = layers[i]
    local south = layers[i - layer_step]

    local order_map = {}
    for j = 1, #south do
      order_map[south[j]] = j
    end

    local order = {}
    local sequence = {}

    for j = 1, #north do
      local uid = north[j]
      local s = {}
      local eid = uv_first[uid]
      while eid do
        s[#s + 1] = order_map[uv_target[eid]]
        eid = uv_after[eid]
      end
      sort(s)
      local m = #s
      if m == 0 then
        order[j] = uid
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
        if not order[n] then
          order[n] = sequence[j].uid
          break
        end
      end
    end

    layers[i] = order
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

local function transpose(g, layers)
  local improved = true
  while improved do
    improved = false
    for i = 1, #layers do
      local order = layers[i]
      for j = 1, #order - 1 do
        local uid = order[j]
        local vid = order[j + 1]
        local c1 = crossing(g, order, layers, i)
        order[j] = vid
        order[j + 1] = uid
        local c2 = crossing(g, order, layers, i)
        if c1 > c2 then
          improved = true
        else
          order[j] = uid
          order[j + 1] = vid
        end
      end
    end
  end
end

local function crossing_g(g, layers)
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
    wmedian(g.uv, layers, 1, n, 1)
    transpose(g, layers)
    if crossing_g(g, layers) < crossing_g(g, best) then
      copy(layers, best)
    end
    wmedian(g.vu, layers, n, 1, -1)
    transpose(g, layers)
    if crossing_g(g, layers) < crossing_g(g, best) then
      copy(layers, best)
    end
  end

  return best
end
