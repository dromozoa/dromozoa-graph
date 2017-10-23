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

local function greedy_linear_ordering(g)
  local uv = g.uv
  local vu = g.vu
  local ue = uv.ue
  local ve = vu.ue

  local min = 1
  local max = g.uid
  local order = {}

  while next(ue) ~= nil do
    -- each sink vertex
    repeat
      local n = max
      for vid, eid in pairs(ue) do
        if not eid then
          for eid in vu:each_edge(vid) do
            g:remove_edge(eid)
          end
          g:remove_vertex(vid)
          order[vid] = max
          max = max - 1
        end
      end
    until n == max

    -- each source vertex
    repeat
      local n = min
      for uid, eid in pairs(ve) do
        if not eid then
          for eid in uv:each_edge(uid) do
            g:remove_edge(eid)
          end
          g:remove_vertex(uid)
          order[uid] = min
          min = min + 1
        end
      end
    until n == min

    if next(ue) == nil then
      break
    end

    -- choose vertex w such that \(d^+(w) - d^-(w)\) is maximum
    local wid
    local value
    for uid in pairs(ue) do
      local v = uv:degree(uid) - vu:degree(uid)
      if not value or value < v then
        wid = uid
        value = v
      end
    end

    for eid in uv:each_edge(wid) do
      g:remove_edge(eid)
    end
    for eid in vu:each_edge(wid) do
      g:remove_edge(eid)
    end
    g:remove_vertex(wid)
    order[wid] = min
    min = min + 1
  end

  return order
end

return function (g, that)
  local ev = g.ev
  local eu = g.eu

  local reverse_edge = that.reverse_edge

  local order = greedy_linear_ordering(g:clone())

  for eid, vid in pairs(ev) do
    local uid = eu[eid]
    if order[uid] > order[vid] then
      reverse_edge(that, eid, uid, vid)
    end
  end
end
