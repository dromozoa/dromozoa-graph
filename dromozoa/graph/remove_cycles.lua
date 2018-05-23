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

local binary_heap = require "dromozoa.graph.binary_heap"

local function greedy_linear_ordering(g)
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

  local odeg = {}
  local ideg = {}
  local sink_queue = {}
  local sink_min = 0
  local sink_max = 0
  local source_queue = {}
  local source_min = 0
  local source_max = 0
  local queue = binary_heap()

  local order_map = {}
  local order_min = 1
  local order_max = u.n

  local uid = u.first
  while uid do
    if not uv_first[uid] then
      sink_max = sink_max + 1
      sink_queue[sink_max] = uid
    elseif not vu_first[uid] then
      source_max = source_max + 1
      source_queue[source_max] = uid
    else
      local o = uv:degree(uid)
      local i = vu:degree(uid)
      odeg[uid] = o
      ideg[uid] = i
      queue:push(uid, o - i)
    end
    uid = u_after[uid]
  end

  while true do
    while sink_min < sink_max do
      sink_min = sink_min + 1
      local uid = sink_queue[sink_min]
      sink_queue[sink_min] = nil

      order_map[uid] = order_max
      order_max = order_max - 1

      local eid = vu_first[uid]
      while eid do
        local vid = vu_target[eid]
        local o = odeg[vid]
        if o then
          if o == 1 then
            odeg[vid] = nil
            ideg[vid] = nil
            sink_max = sink_max + 1
            sink_queue[sink_max] = vid
            queue:remove(vid)
          else
            odeg[vid] = o - 1
            queue:decrease(vid, 1)
          end
        end
        eid = vu_after[eid]
      end
    end

    while source_min < source_max do
      source_min = source_min + 1
      local uid = source_queue[source_min]
      source_queue[source_min] = nil

      order_map[uid] = order_min
      order_min = order_min + 1

      local eid = uv_first[uid]
      while eid do
        local vid = uv_target[eid]
        local i = ideg[vid]
        if i then
          if i == 1 then
            odeg[vid] = nil
            ideg[vid] = nil
            source_max = source_max + 1
            source_queue[source_max] = vid
            queue:remove(vid)
          else
            ideg[vid] = i - 1
            queue:increase(vid, 1)
          end
        end
        eid = uv_after[eid]
      end
    end

    local uid = queue:pop()
    if not uid then
      break
    end

    odeg[uid] = nil
    ideg[uid] = nil

    order_map[uid] = order_min
    order_min = order_min + 1

    local eid = vu_first[uid]
    while eid do
      local vid = vu_target[eid]
      local o = odeg[vid]
      if o then
        if o == 1 then
          odeg[vid] = nil
          ideg[vid] = nil
          sink_max = sink_max + 1
          sink_queue[sink_max] = vid
          queue:remove(vid)
        else
          odeg[vid] = o - 1
          queue:decrease(vid, 1)
        end
      end
      eid = vu_after[eid]
    end

    local eid = uv_first[uid]
    while eid do
      local vid = uv_target[eid]
      local i = ideg[vid]
      if i then
        if i == 1 then
          odeg[vid] = nil
          ideg[vid] = nil
          source_max = source_max + 1
          source_queue[source_max] = vid
          queue:remove(vid)
        else
          ideg[vid] = i - 1
          queue:increase(vid, 1)
        end
      end
      eid = uv_after[eid]
    end
  end

  return order_map
end

return function (g)
  local order_map = greedy_linear_ordering(g)

  local e = g.e
  local e_after = e.after
  local uv_target = g.uv.target
  local vu_target = g.vu.target

  local reverse_eids = {}
  local n = 0

  local eid = e.first
  while eid do
    if order_map[uv_target[eid]] < order_map[vu_target[eid]] then
      n = n + 1
      reverse_eids[n] = eid
    end
    eid = e_after[eid]
  end

  for i = 1, n do
    g:reverse_edge(reverse_eids[i])
  end

  return reverse_eids
end
