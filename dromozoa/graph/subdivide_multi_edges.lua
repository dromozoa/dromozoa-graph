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

return function (g, x, y)
  local e = g.e
  local e_after = e.after
  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target
  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local last_eid = e.last

  local eid = e.first
  while eid do
    local uid = vu_target[eid]
    local vid = uv_target[eid]
    local is_multi = false
    local eid2 = uv_first[vid]
    while eid2 do
      local uid2 = uv_target[eid2]
      if uid == uid2 then
        is_multi = true
        break
      end
      eid2 = uv_after[eid2]
    end
    if is_multi then
      local wid = g:add_vertex()
      g:subdivide_edge(eid, wid)

      local ux = x[uid]
      local uy = y[uid]
      local vx = x[vid]
      local vy = y[vid]

      if uy < vy then
        x[wid] = (ux + vx) / 2 + 0.25
      else
        x[wid] = (ux + vx) / 2 - 0.25
      end
      y[wid] = (uy + vy) / 2
    end
    if eid == last_eid then
      break
    end
    eid = e_after[eid]
  end
end
