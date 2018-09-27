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

return function (g, e_labels)
  local e = g.e
  local e_after = e.after
  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target
  local vu_target = g.vu.target

  local reversed_eids = {}
  local m = 0
  local subdivided_eids = {}
  local n = 0

  local last_eid = e.last

  local eid1 = e.first
  while eid1 do
    local uid = vu_target[eid1]
    local vid = uv_target[eid1]
    if uid == vid then
      local eid2 = g:subdivide_edge(eid1, g:add_vertex())
      g:reverse_edge(eid2)
      m = m + 1
      reversed_eids[m] = eid2
    elseif e_labels and e_labels[eid1] then
      n = n + 1
      subdivided_eids[n] = eid1
    else
      local eid2 = uv_first[uid]
      while eid2 do
        if eid1 ~= eid2 and vid == uv_target[eid2] then
          n = n + 1
          subdivided_eids[n] = eid1
          break
        end
        eid2 = uv_after[eid2]
      end
    end
    if eid1 == last_eid then
      break
    end
    eid1 = e_after[eid1]
  end

  for i = 1, n do
    g:subdivide_edge(subdivided_eids[i], g:add_vertex())
  end

  return reversed_eids
end
