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

local clone = require "dromozoa.graph.clone"

local function promote(g, layer_map, d_map, uid)
  local vu = g.vu
  local vu_after = vu.after
  local vu_target = vu.target

  local d = 0
  local u = layer_map[uid] + 1

  local eid = vu.first[uid]
  while eid do
    local vid = vu_target[eid]
    if u == layer_map[vid] then
      d = d + promote(g, layer_map, d_map, vid)
    end
    eid = vu_after[eid]
  end

  layer_map[uid] = u

  return d + d_map[uid]
end

return function (g, layer_map)
  local u = g.u
  local u_first = u.first
  local u_after = u.after

  local uv = g.uv

  local vu = g.vu
  local vu_first = vu.first

  local old_layer_map = layer_map
  local new_layer_map = {}

  local layer_map = setmetatable(new_layer_map, {
    __index = old_layer_map;
  })

  local d_map = {}
  local uid = u_first
  while uid do
    d_map[uid] = uv:degree(uid) - vu:degree(uid)
    uid = u_after[uid]
  end

  repeat
    local promotions = 0
    local uid = u_first
    while uid do
      if vu_first[uid] then -- not source vertex
        if promote(g, layer_map, d_map, uid) < 0 then
          promotions = promotions + 1
          for i, v in next, new_layer_map do
            old_layer_map[i] = v
            new_layer_map[i] = nil
          end
        else
          for i, v in next, new_layer_map do
            new_layer_map[i] = nil
          end
        end
      end
      uid = u_after[uid]
    end
  until promotions == 0

  return old_layer_map
end
