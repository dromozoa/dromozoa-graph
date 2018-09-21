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

return function (g, last_uid, last_eid)
  local e = g.e
  local e_after = e.after
  local uv = g.uv
  local uv_first = uv.first
  local uv_target = uv.target
  local vu = g.vu
  local vu_first = vu.first
  local vu_target = vu.target

  local paths = {}

  local eid = e.first
  while eid do
    if eid <= last_eid then
      local eid = eid
      local path = {}
      paths[eid] = path

      local uid = vu_target[eid]
      while uid > last_uid do
        eid = vu_first[uid]
        uid = vu_target[eid]
      end

      local n = 1
      path[1] = eid

      local vid = uv_target[eid]
      while vid > last_uid do
        eid = uv_first[vid]
        vid = uv_target[eid]
        n = n + 1
        path[n] = eid
      end
    end
    eid = e_after[eid]
  end

  return paths
end
