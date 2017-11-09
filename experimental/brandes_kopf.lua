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

  local h = #layer

  local position_map = {}
  for i = 1, #layer do
    local L = layer[i]
    local P = {}
    for j = 1, #L do
      P[L[j]] = j
    end
    position_map[i] = P
  end

  local mark = {}

  -- preprocessing (mark type 1 conflicts)
  for i = 2, #layer - 2 do
    local L0 = layer[i + 1]
    local n0 = #L0
    local L1 = layer[i]
    local n1 = #L1
    local P0 = position_map[i + 1]
    local P1 = position_map[i]

    local k0 = 0
    local l = 1

    for l1 = 1, n1 do
      local uid = L1[l1]
      local vid
      local is_inner_segment
      if uid >= dummy_uid then
        local eid = vu_first[uid]
        assert(vu:degree(uid) == 1)
        vid = vu_target[eid]
        is_inner_segment = vid >= dummy_uid
        -- if is_inner_segment then
        --   print("inner", uid, vid)
        -- end
      end

      if l1 == n1 or is_inner_segment then
        local k1 = n0
        if is_inner_segment then
          k1 = P0[vid]
          assert(k1, "? " .. i .. " " .. uid .. " " .. vid)
        end

        while l <= l1 do
          local uid = L1[l]
          local eid = vu_first[uid]
          while eid do
            local vid = vu_target[eid]
            local k = P0[vid]
            if k < k0 or k > k1 then
              print("mark", uid, vid, "e", eid)
              mark[eid] = true
            end
            eid = vu_after[eid]
          end
          l = l + 1
        end
        k0 = k1
      end
    end
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

  for i = #layer, 1, -1 do
    local L = layer[i]
    local n = #L
    local L0 = layer[i + 1]
    local P0 = position_map[i + 1]

    local r = 0
    for k = 1, n do
      local uid = L[k]

      local eids = {}

      local eid = vu_first[uid]
      while eid do
        eids[#eids + 1] = eid
        eid = vu_after[eid]
      end

      table.sort(eids, function (eid1, eid2)
        local vid1 = vu_target[eid1]
        local vid2 = vu_target[eid2]
        return P0[vid1] < P0[vid2]
      end)

      local d = #eids
      if d > 0 then
        local h = (d + 1) / 2

        for m = math.floor(h), math.ceil(h) do
          if align[uid] == uid then
            local eid = eids[m]
            local vid = vu_target[eid]
            if not mark[eid] and r < P0[vid] then
              print("?", uid, vid)
              align[vid] = uid
              root[uid] = root[vid]
              align[uid] = root[uid]
              r = P0[vid]
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
        local P = position_map[i]
        local p = P[wid]
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
