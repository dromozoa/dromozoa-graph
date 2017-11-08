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

local function visit(first, after, target, layer_map, layer, color, uid)
  color[uid] = 1

  local eid = first[eid]
  while eid do
    local vid = target[eid]
    local c = color[vid]
    if not c then
      visit(first, after, target, layer_map, layer, color, vid)
    elseif c == 1 then
      error "not a dag"
    end
  end

  color[uid] = 2

  local u = layer_map[uid]
  local order = layer[u]
  if not order then
    layer[u] = { uid }
  else
    order[#order + 1] = uid
  end
end

return function (g, layer_map)
  local u = g.u
  local u_after = u.after

  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local layer = {}
  local color = {}

  local uid = u.first
  while uid do
    if not color[uid] then
      visit(uv_first, uv_after, uv_target, layer_map, layer, color, uid)
    end
    uid = u_after[uid]
  end

  return layer
end
