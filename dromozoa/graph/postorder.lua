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


--[[

| value | u_color | e_color               |
|:-----:|---------|-----------------------|
|  nil  | WHITE   | tree edge             |
|   1   | GRAY    | back edge             |
|   2   | BLACK   | forward or cross edge |

]]

local function visit(uv_first, uv_after, uv_target, order, u_color, e_color, uid)
  u_color[uid] = 1

  local eid = uv_first[uid]
  while eid do
    local vid = uv_target[eid]
    local color = u_color[vid]
    if not color then
      visit(uv_first, uv_after, uv_target, order, u_color, e_color, vid)
    else
      e_color[eid] = color
    end
    eid = uv_after[eid]
  end

  u_color[uid] = 2
  order[#order + 1] = uid
end

return function (u, uv, start_uid)
  local u_after = u.after
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local order = {}
  local u_color = {}
  local e_color = {}

  if start_uid then
    visit(uv_first, uv_after, uv_target, order, u_color, e_color, start_uid)
  else
    local uid = u.first
    while uid do
      if not u_color[uid] then
        visit(uv_first, uv_after, uv_target, order, u_color, e_color, uid)
      end
      uid = u_after[uid]
    end
  end

  return order, u_color, e_color
end
