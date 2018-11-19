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

local function visit(uv_first, uv_after, uv_target, order, color, uid)
  color[uid] = true

  local eid = uv_first[uid]
  while eid do
    local vid = uv_target[eid]
    if not color[vid] then
      visit(uv_first, uv_after, uv_target, order, color, vid)
    end
    eid = uv_after[eid]
  end

  order[#order + 1] = uid
end

return function (u, uv, uid)
  local u_after = u.after
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local color = {}
  local order = {}

  if uid then
    visit(uv_first, uv_after, uv_target, order, color, uid)
  end

  local uid = u.first
  while uid do
    if not color[uid] then
      visit(uv_first, uv_after, uv_target, order, color, uid)
    end
    uid = u_after[uid]
  end

  return order
end
