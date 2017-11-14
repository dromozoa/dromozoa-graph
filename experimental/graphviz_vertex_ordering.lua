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

local function make_index_map(layer)
  local index_map = {}

  local index_map = {}
  for i = 1, #layer do
    local order = layer[i]
    for j = 1, #order do
      index_map[order[j]] = j
    end
  end

  return index_map
end

local function wmedian(vu, layer, index_map, layer_first, layer_last, layer_step)
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local indices = {}
  local median = {}

  local compare = function (uid1, uid2)
    local u1 = median[uid1]
    local u2 = median[uid2]
    if u1 == u2 then
      return index_map[uid1] < index_map[uid2]
    else
      return u1 < u2
    end
  end

  local new_layer = {}

  for i = layer_first, layer_last, layer_step do
    local uids = layer[i]
    local un = #uids

    local new_uids = {}
    new_layer[i] = new_uids

    for j = 1, un do
      local uid = uids[j]
      new_uids[j] = uid

      local n = 0
      local eid = vu_first[uid]
      while eid do
        n = n + 1
        indices[n] = index_map[vu_target[eid]]
        eid = vu_after[eid]
      end

      if n == 0 then
        median[uid] = -1
      elseif n == 1 then
        median[uid] = indices[1]
      elseif n == 2 then
        median[uid] = (indices[1] + indices[2]) / 2
      else
        for i = n + 1, #indices do
          indices[i] = nil
        end
        sort(indices)

        local m1
        local m2
        if n % 2 == 0 then
          m1 = n / 2
          m2 = m1 + 1
        else
          m1 = (n - 1) / 2
          m2 = m1 + 1
        end

        local a = indices[m1]
        local b = indices[m2]
        local l = a - indices[1]
        local r = indices[n] - b
        median[uid] = (a * r + b * l) / (l + r)
      end
    end

    sort(new_uids, compare)
  end

  return new_layer
end

local function crossing(uv, vu, index_map, uid1, uid2)
  local uv_target = uv.target

  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local eids = {}
  local en = 0

  local eid = vu_first[uid1]
  while eid do
    en = en + 1
    eids[en] = eid
    eid = vu_after[eid]
  end

  local eid = vu_first[uid2]
  while eid do
    en = en + 1
    eids[en] = eid
    eid = vu_after[eid]
  end

  if en > 1 then
    local compare = function (eid1, eid2)
      local index1 = index_map[vu_target[eid1]]
      local index2 = index_map[vu_target[eid2]]
      if index1 == index2 then
        return uv_target[eid1] == uid1
      else
        return index1 < index2
      end
    end
    sort(eids, compare)
  end

  local a = 0
  local c = 0
  local prev_vid
  for i = 1, en do
    local eid = eids[i]
    local uid = uv_target[eid]
    local vid = vu_target[eid]
    if uid == uid1 then
      a = a + c
    else
      c = c + 1
    end
    if vid == prev_vid then
      eids[i] = eids[i - 1]
      eids[i - 1] = eid
    end
    prev_vid = vid
  end

  local b = 0
  local c = 0

  for i = 1, en do
    local eid = eids[i]
    local uid = uv_target[eid]
    if uid == uid2 then
      b = b + c
    else
      c = c + 1
    end
  end

  return a, b
end

local function transpose(g, layer, index_map)
  local uv = g.uv
  local vu = g.vu

  local improved = true
  while improved do
    improved = false
    for i = #layer, 1, -1 do
      local uids = layer[i]
      local uid = uids[1]
      for j = 2, #uids do
        local vid = uids[j]
        local a, b = crossing(vu, uv, index_map, uid, vid)
        local c, d = crossing(uv, vu, index_map, uid, vid)
        if a + c > b + d then
          local k = j - 1
          improved = true
          uids[k] = vid
          uids[j] = uid
          index_map[uid] = k
          index_map[vid] = j
        else
          vid = uid
        end
      end
    end
  end
end

local function crossing_layer(g, layer, index_map)
  local uv = g.uv
  local uv_target = uv.target

  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local eids = {}
  for i = #layer - 1, 1, -1 do
    local uids = layer[i]
    local un = #uids
    local en = 0

    for j = 1, un do
      local uid = uids[j]
      local eid = vu_first[uid]
      while eid do
        en = en + 1
        eids[en] = eid
        eid = vu_after[eid]
      end
    end

    if en > 1 then
      for j = en + 1, #eids do
        eids[i] = nil
      end
      local compare = function (eid1, eid2)
        local index1 = index_map[vu_target[eid1]]
        local index2 = index_map[vu_target[eid2]]
        if index1 == index2 then
          local index1 = index_map[uv_target[eid1]]
          local index2 = index_map[uv_target[eid2]]
          return index1 < index2
        else
          return index1 < index2
        end
      end
      sort(eids, compare)
    end

    -- エッジの数が少ないときは？
    local tree = {}
    local first = 1
    while first < un do
      first = first * 2
    end
    first = first - 2
    for j = 0, first + un + 1 do
      tree[j] = 0
    end

    local count = 0
    for j = 1, en do
      local index = first + index_map[uv_target[eids[j]]]
      tree[index] = tree[index] + 1
      while index > 0 do
        if index % 2 == 1 then
          count = count + tree[index + 1]
          index = (index - 1) / 2
        else
          index = (index - 2) / 2
        end
        tree[index] = tree[index] + 1
      end
    end

    print(count)
  end
end

return function (g, layer)
  local uv = g.uv
  local vu = g.vu

  local layer_max = #layer

  local index_map = make_index_map(layer)

  -- local new_layer = wmedian(vu, layer, index_map, layer_max, 1, -1)
  local new_layer = wmedian(uv, layer, index_map, 1, layer_max, 1)
  local new_index_map = make_index_map(new_layer)
  -- transpose(g, new_layer, new_index_map)
  -- transpose(g, layer, index_map)

  crossing_layer(g, layer, index_map)


end
