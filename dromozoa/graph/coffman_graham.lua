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

local sort = table.sort

return function (g, width_max)
  if not width_max then
    width_max = g.e.n
  end

  local u = g.u
  local u_after = u.after

  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local ideg = {}

  local order = {}
  local order_map = {}
  local order_min = 0
  local order_max = 0

  local priorities1 = {}
  local priorities2 = {}
  local candidates = {}

  local width = width_max
  local layer_map = {}
  local layer_max = 1

  local compare = function (uid1, uid2)
    -- vertex which added earlier is assigned grater priority
    local n1 = 0
    local eid = vu_first[uid1]
    while eid do
      n1 = n1 + 1
      priorities1[n1] = -order_map[vu_target[eid]]
      eid = vu_after[eid]
    end

    local n2 = 0
    local eid = vu_first[uid2]
    while eid do
      n2 = n2 + 1
      priorities2[n2] = -order_map[vu_target[eid]]
      eid = vu_after[eid]
    end

    -- vertex which most recently added is placed first because the vertex has been assigned the lowest priorty
    sort(priorities1)
    sort(priorities2)

    local result
    for i = 1, n2 do
      local priority1 = priorities1[i]
      local priority2 = priorities2[i]
      if not priority1 then
        result = true
        break
      elseif priority1 ~= priorities2 then
        result = priority1 > priority2
        break
      end
    end

    for i = 1, n1 do
      priorities1[i] = nil
    end
    for i = 1, n2 do
      priorities2[i] = nil
    end

    return result
  end

  local uid = u.first
  while uid do
    if not vu_first[uid] then
      order_max = order_max + 1
      order[order_max] = uid
      order_map[uid] = order_max
    else
      ideg[uid] = vu:degree(uid)
    end
    uid = u_after[uid]
  end

  while order_min < order_max do
    order_min = order_min + 1
    local uid = order[order_min]

    local n = 0

    local eid = uv_first[uid]
    while eid do
      local vid = uv_target[eid]
      local i = ideg[vid]
      if i == 1 then
        ideg[vid] = nil
        n = n + 1
        candidates[n] = vid
      else
        ideg[vid] = i - 1
      end
      eid = uv_after[eid]
    end

    if n > 0 then
      if n == 1 then
        local vid = candidates[1]
        candidates[1] = nil
        order_max = order_max + 1
        order[order_max] = vid
        order_map[vid] = order_max
      else
        sort(candidates, compare)
        for i = 1, n do
          local vid = candidates[i]
          candidates[i] = nil
          order_max = order_max + 1
          order[order_max] = vid
          order_map[vid] = order_max
        end
      end
    end
  end

  for i = order_max, 1, -1 do
    local uid = order[i]
    local u = 0
    local eid = uv_first[uid]
    while eid do
      local v = layer_map[uv_target[eid]]
      if u < v then
        u = v
      end
      eid = uv_after[eid]
    end
    if width == 1 or layer_max <= u then
      width = width_max
      layer_max = layer_max + 1
    else
      width = width - 1
    end
    layer_map[uid] = layer_max
  end

  return layer_map
end
