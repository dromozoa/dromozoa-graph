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

return function (g, layer_map, layer, dummy_uid)
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

  local layer_max = #layer
  local layer_index = {}
  for i = 1, layer_max do
    local order = layer[i]
    for j = 1, #order do
      layer_index[order[j]] = j
    end
  end

  local mark = {}

  -- preprocessing (mark type 1 conflicts)
  local v_last = #layer[layer_max - 1]
  for i = layer_max - 2, 2, -1 do
    local u_order = layer[i]
    local u_first = 1
    local u_last = #u_order

    local k_first = 0
    local j = 1

    for i = u_first, u_last do
      local uid = u_order[i]

      local k_last
      if i == u_last then
        k_last = v_last
      end
      if uid >= dummy_uid then
        local vid = vu_target[vu_first[uid]]
        if vid >= dummy_uid then
          k_last = layer_index[vid]
        end
      end

      if k_last then
        while j <= i do
          local eid = vu_first[u_order[j]]
          while eid do
            local k = layer_index[vu_target[eid]]
            if k < k_first or k > k_last then
              print("mark", u_order[j], vu_target[eid], "e", eid)
              mark[eid] = true
            end
            eid = vu_after[eid]
          end
          j = j + 1
        end
        k_first = k_last
      end
    end

    v_last = #u_order
  end

  -- vertical alignment

  local root = {}
  local align = {}

  local uid = u.first
  while uid do
    root[uid] = uid
    align[uid] = uid
    uid = u_after[uid]
  end

  do
    local layer_first = #layer
    local layer_last = 1
    local layer_step = -1
    local first = vu_first
    local after = vu_after
    local target = vu_target

    for i = layer_first, layer_last, layer_step do
      local order = layer[i]
      local r = 0

      for j = 1, #order do
        local uid = order[j]
        local eids = {}

        local eid = first[uid]
        while eid do
          eids[#eids + 1] = eid
          eid = after[eid]
        end

        table.sort(eids, function (eid1, eid2)
          return layer_index[target[eid1]] < layer_index[target[eid2]]
        end)

        local d = #eids
        if d > 0 then
          local h = (d + 1) / 2
          for m = math.floor(h), math.ceil(h) do
            if align[uid] == uid then
              local eid = eids[m]
              if not mark[eid] then
                local vid = target[eid]
                local q = layer_index[vid]
                if r < q then
                  print("?", uid, vid)
                  local wid = root[vid]
                  root[uid] = wid
                  align[vid] = uid
                  align[uid] = wid
                  r = q
                end
              end
            end
          end
        end
      end
    end
  end

  -- horizontal compaction

  local sink = {}
  local shift = {}
  local x = {}

  local uid = u.first
  while uid do
    sink[uid] = uid
    uid = u_after[uid]
  end

  local delta = 1

  local function place_block(vid)
    if not x[vid] then
      x[vid] = 0
      local wid = vid
      repeat
        local i = assert(layer_map[wid])
        local p = layer_index[wid]
        if p > 1 then
          local L = layer[i]
          local uid = root[L[p - 1]]
          place_block(uid)
          if sink[vid] == vid then
            sink[vid] = sink[uid]
          end
          if sink[vid] ~= sink[uid] then
            local a = shift[sink[uid]]
            local b = x[vid] - x[uid] - delta
            if not a then
              shift[sink[uid]] = b
            else
              if a < b then
                shift[sink[uid]] = a
              else
                shift[sink[uid]] = b
              end
            end
          else
            local a = x[vid]
            local b = x[uid] + delta
            if a < b then
              x[vid] = b
            else
              x[vid] = a
            end
          end
        end
        wid = align[wid]
      until wid == vid
    end
  end

  local uid = u.first
  while uid do
    if root[uid] == uid then
      place_block(uid)
    end
    uid = u_after[uid]
  end

  local x_old = x
  local x = {}

  local uid = u.first
  while uid do
    x[uid] = x_old[root[uid]]
    local s = shift[sink[root[uid]]]
    if s then
      x[uid] = x[uid] + s
    end
    print("X", uid, x[uid], s)
    uid = u_after[uid]
  end

  for i = #layer, 1, -1 do
    local L = layer[i]
    local row = {}
    local max = 1
    for j = 1, #L do
      local uid = L[j]
      local X = x[uid] + 1
      row[X] = uid
      if max < X then
        max = X
      end
    end
    for X = 1, max do
      if not row[X] then
        row[X] = ""
      end
    end
    print(table.concat(row, "\t"))
  end
end
