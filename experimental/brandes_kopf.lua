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

local function place_block_left(layer_map, layer, layer_index, root, align, sink, shift, x, vid)
  if not x[vid] then
    x[vid] = 0
    local wid = vid
    repeat
      local i = layer_index[wid]
      if i > 1 then
        local uid = root[layer[layer_map[wid]][i - 1]]
        place_block_left(layer_map, layer, layer_index, root, align, sink, shift, x, uid)
        local u_sink = sink[uid]
        local v_sink = sink[vid]
        if v_sink == vid then
          sink[vid] = u_sink
          local b = x[uid] + 1
          if x[vid] < b then
            x[vid] = b
          end
        elseif v_sink == u_sink then
          local b = x[uid] + 1
          if x[vid] < b then
            x[vid] = b
          end
        else
          local a = shift[u_sink]
          local b = x[vid] - x[uid] - 1
          if not a or a > b then
            shift[u_sink] = b
          end
        end
      end
      wid = align[wid]
    until wid == vid
  end
end

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
  local vn = #layer[layer_max - 1]
  for i = layer_max - 2, 2, -1 do
    local uids = layer[i]
    local un = #uids

    local a = 1
    local c = 0

    for b = 1, un do
      local uid = uids[b]

      local d
      if b == un then
        d = vn
      end
      if uid >= dummy_uid then
        local vid = vu_target[vu_first[uid]]
        if vid >= dummy_uid then
          d = layer_index[vid]
        end
      end

      if d then
        for a = a, b do
          local eid = vu_first[uids[a]]
          while eid do
            local j = layer_index[vu_target[eid]]
            if j < c or d < j then
              print("mark", uids[a], vu_target[eid], "e", eid)
              mark[eid] = true
            end
            eid = vu_after[eid]
          end
        end
        a = b
        c = d
      end
    end

    vn = #uids
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

    local compare = function (eid1, eid2)
      return layer_index[target[eid1]] < layer_index[target[eid2]]
    end

    for i = layer_first, layer_last, layer_step do
      local uids = layer[i]
      local a = 0

      for j = 1, #uids do
        local uid = uids[j]
        local eids = {}
        local n = 0

        local eid = first[uid]
        while eid do
          n = n + 1
          eids[n] = eid
          eid = after[eid]
        end

        table.sort(eids, compare)

        if n > 0 then
          local h = (n + 1) / 2
          for m = math.floor(h), math.ceil(h) do
            if align[uid] == uid then
              local eid = eids[m]
              if not mark[eid] then
                local vid = target[eid]
                local b = layer_index[vid]
                if a < b then
                  print("?", uid, vid)
                  local wid = root[vid]
                  root[uid] = wid
                  align[vid] = uid
                  align[uid] = wid
                  a = b
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

  local uid = u.first
  while uid do
    if root[uid] == uid then
      place_block_left(layer_map, layer, layer_index, root, align, sink, shift, x, uid)
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
