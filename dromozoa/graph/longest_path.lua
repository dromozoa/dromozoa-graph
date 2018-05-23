-- Copyright (C) 2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local function visit(uv_first, uv_after, uv_target, color, layer_map, uid)
  color[uid] = 1

  local u_layer = 0

  local eid = uv_first[uid]
  while eid do
    local vid = uv_target[eid]
    local c = color[vid]
    if not c then
      local v_layer = visit(uv_first, uv_after, uv_target, color, layer_map, vid)
      if u_layer < v_layer then
        u_layer = v_layer
      end
    elseif c == 1 then
      error "not a dag"
    else
      local v_layer = layer_map[vid]
      if u_layer < v_layer then
        u_layer = v_layer
      end
    end
    eid = uv_after[eid]
  end

  color[uid] = 2

  u_layer = u_layer + 1
  layer_map[uid] = u_layer
  return u_layer
end

return function (g)
  local u = g.u
  local u_after = u.after
  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local color = {}
  local layer_map = {}

  local uid = u.first
  while uid do
    if not color[uid] then
      visit(uv_first, uv_after, uv_target, color, layer_map, uid)
    end
    uid = u_after[uid]
  end

  return layer_map
end
