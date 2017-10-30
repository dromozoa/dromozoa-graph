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

local clone = require "dromozoa.graph.clone"

local function greedy_linear_ordering(g)
  local order = {}

  local u = g.u
  local uid_after = u.after
  local uv = g.uv
  local uv_first = uv.first
  local vu = g.vu
  local vu_first = vu.first

  local min = 1
  local max = u.n

  while u.first do
    repeat
      local n = max
      local uid = u.first
      while uid do
        if not uv_first[uid] then -- sink
          order[uid] = max
          max = max - 1
          g:remove_edges(uid)
          uid = g:remove_vertex(uid)
        else
          uid = uid_after[uid]
        end
      end
    until n == max

    repeat
      local n = min
      local uid = u.first
      while uid do
        if not vu_first[uid] then -- source
          order[uid] = min
          min = min + 1
          g:remove_edges(uid)
          uid = g:remove_vertex(uid)
        else
          uid = uid_after[uid]
        end
      end
    until n == min

    local wid
    local value

    local uid = u.first
    if not uid then
      break
    end

    while uid do
      local v = uv:degree(uid) - vu:degree(uid)
      if not value or value < v then
        wid = uid
        value = v
      end
      uid = uid_after[uid]
    end

    order[wid] = min
    min = min + 1
    g:remove_edges(wid)
    g:remove_vertex(wid)
  end

  return order
end

return function (g)
  local order = greedy_linear_ordering(clone(g))

  local e = g.e
  local eid_after = e.after
  local source = g.vu.target
  local target = g.uv.target

  local reverse = {}

  local eid = e.first
  while eid do
    local uid = source[eid]
    local vid = target[eid]
    if order[uid] > order[vid] then
      reverse[#reverse + 1] = eid
      print("reverse", uid, vid, eid)
    end
    eid = eid_after[eid]
  end
  return reverse
  -- print(table.concat(order, " "))
end
