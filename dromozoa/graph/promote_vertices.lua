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

local function promote(vu_first, vu_after, vu_target, layer_map, d_map, uid)
  local d = d_map[uid]
  local u_layer = layer_map[uid] + 1

  local eid = vu_first[uid]
  while eid do
    local vid = vu_target[eid]
    if u_layer == layer_map[vid] then
      d = d + promote(vu_first, vu_after, vu_target, layer_map, d_map, vid)
    end
    eid = vu_after[eid]
  end

  layer_map[uid] = u_layer
  return d
end

return function (g, layer_map)
  local next = next

  local u = g.u
  local u_first = u.first
  local u_after = u.after

  local uv = g.uv

  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local new_layer_map = setmetatable({}, { __index = layer_map })

  local d_map = {}
  local uid = u_first
  while uid do
    d_map[uid] = uv:degree(uid) - vu:degree(uid)
    uid = u_after[uid]
  end

  repeat
    local promoted
    local uid = u_first
    while uid do
      if vu_first[uid] then
        if promote(vu_first, vu_after, vu_target, new_layer_map, d_map, uid) < 0 then
          promoted = true
          for vid, v_layer in next, new_layer_map do
            layer_map[vid] = v_layer
            new_layer_map[vid] = nil
          end
        else
          for vid, v_layer in next, new_layer_map do
            new_layer_map[vid] = nil
          end
        end
      end
      uid = u_after[uid]
    end
  until not promoted

  return layer_map
end
