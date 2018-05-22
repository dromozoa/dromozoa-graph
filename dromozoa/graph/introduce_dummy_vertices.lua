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

return function (g, layer_map, reverse_eids, reverse_set)
  if not reverse_set then
    reverse_set = {}
  end

  local u = g.u

  local e = g.e
  local e_after = e.after

  local uv_target = g.uv.target
  local vu_target = g.vu.target

  local prev_uid = u.last
  local prev_eid = e.last

  if prev_eid then
    local eid = e.first

    local w_max = layer_map[vu_target[eid]] - 1
    local w_min = layer_map[uv_target[eid]] + 1
    do
      local eid = eid
      local reverse = reverse_set[eid]
      for w = w_max, w_min, -1 do
        local wid = g:add_vertex()
        layer_map[wid] = w
        eid = g:subdivide_edge(eid, wid)
        if reverse then
          reverse_eids[#reverse_eids + 1] = eid
        end
      end
    end

    while eid ~= prev_eid do
      eid = e_after[eid]
      local w_max = layer_map[vu_target[eid]] - 1
      local w_min = layer_map[uv_target[eid]] + 1
      local eid = eid
      local reverse = reverse_set[eid]
      for w = w_max, w_min, -1 do
        local wid = g:add_vertex()
        layer_map[wid] = w
        eid = g:subdivide_edge(eid, wid)
        if reverse then
          reverse_eids[#reverse_eids + 1] = eid
        end
      end
    end
  end

  return u.after[prev_uid]
end
