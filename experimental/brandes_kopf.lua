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

local function preprocessing(g, layer, layer_index, dummy_uid)
  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local layer_max = #layer

  local mark = {}

  local vn = #layer[layer_max - 2]
  for i = layer_max - 1, 2, -1 do
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

  return mark
end

local function vertical_alignment(u, vu, layer, layer_index, mark, layer_first, layer_last, layer_step, left)
  local u_after = u.after

  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local compare
  if left then
    compare = function (eid1, eid2)
      return layer_index[vu_target[eid1]] < layer_index[vu_target[eid2]]
    end
  else
    compare = function (eid1, eid2)
      return layer_index[vu_target[eid1]] > layer_index[vu_target[eid2]]
    end
  end

  local root = {}
  local align = {}

  local uid = u.first
  while uid do
    root[uid] = uid
    align[uid] = uid
    uid = u_after[uid]
  end

  local first
  local last
  local step

  local eids = {}
  local m1
  local m2
  local condition

  for i = layer_first, layer_last, layer_step do
    local uids = layer[i]

    if left then
      first = 1
      last = #uids
      step = 1
    else
      first = #uids
      last = 1
      step = -1
    end

    local a

    for j = first, last, step do
      local uid = uids[j]
      local en = 0

      local eid = vu_first[uid]
      while eid do
        en = en + 1
        eids[en] = eid
        eid = vu_after[eid]
      end

      if en > 0 then
        sort(eids, compare)

        if en % 2 == 0 then
          m1 = en / 2
          m2 = m1 + 1
        else
          m1 = (en + 1) / 2
          m2 = m1
        end

        for m = m1, m2 do
          if align[uid] == uid then
            local eid = eids[m]
            if not mark[eid] then
              local vid = vu_target[eid]
              local b = layer_index[vid]
              if not a then
                condition = true
              elseif left then
                condition = a < b
              else
                condition = a > b
              end
              if condition then
                local wid = root[vid]
                root[uid] = wid
                align[vid] = uid
                align[uid] = wid
                a = b
              end
            end
          end
        end

        for k = 1, en do
          eids[k] = nil
        end
      end
    end
  end

  return root, align
end

local function place_block(layer_map, layer, layer_index, root, align, left, sink, shift, x, vid)
  if not x[vid] then
    x[vid] = 0
    local wid = vid
    repeat
      local i = layer_index[wid]
      local wids = layer[layer_map[wid]]
      local uid
      if left then
        if i > 1 then
          uid = root[wids[i - 1]]
        end
      else
        if i < #wids then
          uid = root[wids[i + 1]]
        end
      end
      if uid then
        place_block(layer_map, layer, layer_index, root, align, left, sink, shift, x, uid)
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

local function horizontal_compaction(u, layer_map, layer, layer_index, root, align, left)
  local u_first = u.first
  local u_after = u.after

  local sink = {}
  local shift = {}
  local rx = {}
  local ax = {}

  local uid = u_first
  while uid do
    sink[uid] = uid
    uid = u_after[uid]
  end

  local uid = u_first
  while uid do
    if root[uid] == uid then
      place_block(layer_map, layer, layer_index, root, align, left, sink, shift, rx, uid)
    end
    uid = u_after[uid]
  end

  if left then
    local uid = u_first
    while uid do
      local vid = root[uid]
      local s = shift[sink[vid]]
      if s then
        ax[uid] = rx[vid] + s
      else
        ax[uid] = rx[vid]
      end
      uid = u_after[uid]
    end
  else
    local x
    local max = 0

    local uid = u_first
    while uid do
      local vid = root[uid]
      local s = shift[sink[vid]]
      if s then
        x = rx[vid] + s
      else
        x = rx[vid]
      end
      ax[uid] = x
      if max < x then
        max = x
      end
      uid = u_after[uid]
    end

    local uid = u_first
    while uid do
      ax[uid] = max - ax[uid]
      uid = u_after[uid]
    end
  end

  return ax
end

local function dump(layer, dummy_uid, x)
  for i = #layer, 1, -1 do
    local L = layer[i]
    local row = {}
    local max = 1
    for j = 1, #L do
      local uid = L[j]
      local X = x[uid] + 1
      if uid < dummy_uid then
        row[X] = uid
      else
        row[X] = "*"
      end
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

return function (g, layer_map, layer, dummy_uid)
  local u = g.u
  local u_after = u.after

  local uv = g.uv
  local vu = g.vu

  local layer_max = #layer
  local layer_index = {}
  for i = 1, #layer do
    local order = layer[i]
    for j = 1, #order do
      layer_index[order[j]] = j
    end
  end

  local mark = preprocessing(g, layer, layer_index, dummy_uid)

  local root, align = vertical_alignment(u, vu, layer, layer_index, mark, layer_max, 1, -1, true)
  local xul = horizontal_compaction(u, layer_map, layer, layer_index, root, align, true)
  local root, align = vertical_alignment(u, vu, layer, layer_index, mark, layer_max, 1, -1, false)
  local xur = horizontal_compaction(u, layer_map, layer, layer_index, root, align, false)
  local root, align = vertical_alignment(u, uv, layer, layer_index, mark, 1, layer_max, 1, true)
  local xll = horizontal_compaction(u, layer_map, layer, layer_index, root, align, true)
  local root, align = vertical_alignment(u, uv, layer, layer_index, mark, 1, layer_max, 1, false)
  local xlr = horizontal_compaction(u, layer_map, layer, layer_index, root, align, false)

  local x = {}

  local uid = u.first
  while uid do
    local a = xul[uid]
    local b = xur[uid]
    local c = xll[uid]
    local d = xlr[uid]

    if b < a then
      a, b = b, a
    end
    if c < a then
      a, b, c = c, a, b
    else
      if c < b then
        b, c = c, b
      end
    end
    if d < b then
      if d < a then
        x[uid] = (a + b) / 2 -- d,a,b,c
      else
        x[uid] = (d + b) / 2 -- a,d,b,c
      end
    else
      if d < c then
        x[uid] = (b + d) / 2 -- a,b,d,c
      else
        x[uid] = (b + c) / 2 -- a,b,c,d
      end
    end

    uid = u_after[uid]
  end

  print("-- leftmost upper")
  dump(layer, dummy_uid, xul)
  print("-- rightmost upper")
  dump(layer, dummy_uid, xur)
  print("-- leftmost lower")
  dump(layer, dummy_uid, xll)
  print("-- rightmost lower")
  dump(layer, dummy_uid, xlr)

  return x
end
