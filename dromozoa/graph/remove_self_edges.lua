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

return function (g)
  local e = g.e
  local e_after = e.after
  local uv_target = g.uv.target
  local vu_target = g.vu.target

  local remove_eids = {}
  local remove_uids = {}
  local n = 0

  local eid = e.first
  while eid do
    local uid = uv_target[eid]
    if uid == vu_target[eid] then
      n = n + 1
      remove_eids[n] = eid
      remove_uids[n] = uid
    end
    eid = e_after[eid]
  end

  for i = 1, n do
    g:remove_edge(remove_eids[i])
  end

  return remove_eids, remove_uids
end
