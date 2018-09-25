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
  local vu_target = g.vu.target

  local last_eid = e.last

  local eid1 = e.first
  while eid1 do
    local uid = vu_target[eid1]
    local vid = uv_target[eid1]
    local eid2 = uv_first[vid]
    while eid2 do
      if uid == uv_target[eid2] then
        break
      end
      eid2 = uv_after[eid2]
    end
    if eid2 then
      local ux = x[uid]
      local uy = y[uid]
      local vx = x[vid]
      local vy = y[vid]
      local wx = (ux + vx) / 2
      local wy = (uy + vy) / 2

      local wid1 = g:add_vertex()
      g:subdivide_edge(eid1, wid1)
      local wid2 = g:add_vertex()
      g:subdivide_edge(eid2, wid2)

      if uy < vy then
        x[wid1] = wx + 1/6
        x[wid2] = wx - 1/6
      else
        x[wid1] = wx - 1/6
        x[wid2] = wx + 1/6
      end
      y[wid1] = wy
      y[wid2] = wy
    end
    if eid1 == last_eid then
      break
    end
    eid1 = e_after[eid1]
  end
end
