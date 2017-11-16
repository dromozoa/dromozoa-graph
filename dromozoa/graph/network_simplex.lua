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

local longest_path = require "dromozoa.graph.longest_path"
local spanning_tree = require "dromozoa.graph.spanning_tree"

local function visit(g, t, color, rank_map, uid, rank)
  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target
  local uv_rank = rank + 1

  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target
  local vu_rank = rank - 1

  color[uid] = true
  rank_map[uid] = rank

  local eid = uv_first[uid]
  while eid do
    local vid = uv_target[eid]
    if not color[vid] then
      t:add_edge(eid, uid, vid)
      visit(g, t, color, rank_map, vid, uv_rank)
    end
    eid = uv_after[eid]
  end

  local eid = vu_first[uid]
  while eid do
    local vid = vu_target[eid]
    if not color[vid] then
      t:add_edge(eid, uid, vid)
      visit(g, t, color, rank_map, vid, vu_rank)
    end
    eid = vu_after[eid]
  end
end

local function feasible_tree(g)
  local u = g.u
  local u_after = u.after

  local t = spanning_tree()
  local color = {}
  local rank_map = {}

  local uid = u.first
  while uid do
    if not color[uid] then
      visit(g, t, color, rank_map, uid, 1)
    end
    uid = u_after[uid]
  end

  return t, rank_map
end

return function (g)
  local t, rank_map = feasible_tree(g)
  -- print(table.concat(rank_map, " "))
  return t, rank_map
end
