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
local topological_sort = require "dromozoa.graph.topological_sort"

local function make_spanning_tree(g, t, dir_map, color, uid)
  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  color[uid] = true

  local eid = uv_first[uid]
  while eid do
    local vid = uv_target[eid]
    if not color[vid] then
      t:add_edge(eid, uid, vid)
      dir_map[eid] = 1
      make_spanning_tree(g, t, dir_map, color, vid)
    end
    eid = uv_after[eid]
  end

  local eid = vu_first[uid]
  while eid do
    local vid = vu_target[eid]
    if not color[vid] then
      t:add_edge(eid, uid, vid)
      dir_map[eid] = -1
      make_spanning_tree(g, t, dir_map, color, vid)
    end
    eid = vu_after[eid]
  end
end

local function update_tree_properties(t, lim_map, low_map, uid, lim)
  local uv = t.uv
  local uv_after = uv.after
  local uv_target = uv.target

  local low

  local eid = uv.first[uid]
  if eid then
    lim, low = update_tree_properties(t, lim_map, low_map, uv_target[eid], lim)
    eid = uv_after[eid]
    while eid do
      lim = update_tree_properties(t, lim_map, low_map, uv_target[eid], lim)
      eid = uv_after[eid]
    end
    lim = lim + 1
  else
    lim = lim + 1
    low = lim
  end

  lim_map[uid] = lim
  low_map[uid] = low
  return lim, low
end

local function update_dv(g, t, dv_map, uid)
  local uv = t.uv
  local uv_after = uv.after
  local uv_target = uv.target

  local dv = 0

  local eid = uv.first[uid]
  while eid do
    local vid = uv_target[eid]
    dv = dv + update_dv(g, t, dv_map, vid)
    eid = uv_after[eid]
  end

  local guv = g.uv
  local guv_first = guv.first
  local guv_after = guv.after

  local gvu = g.vu
  local gvu_first = gvu.first
  local gvu_after = gvu.after

  local eid = gvu_first[uid]
  while eid do
    if not uv_target[eid] then -- is non-tree edge
      dv = dv + 1
    end
    eid = gvu_after[eid]
  end

  local eid = guv_first[uid]
  while eid do
    if not uv_target[eid] then -- is non-tree edge
      dv = dv - 1
    end
    eid = guv_after[eid]
  end

  print("dv", uid, dv)

  dv_map[uid] = dv
  return dv
end

local function update_cut_value(g, t, dir_map, dv_map, cv_map, uid)
  local uv = t.uv
  local uv_after = uv.after
  local uv_target = uv.target

  local sum = 0

  local eid = uv.first[uid]
  while eid do
    local vid = uv_target[eid]
    update_cut_value(g, t, dir_map, dv_map, cv_map, vid)
    sum = sum + cv_map[eid] + dv_map[vid]
    eid = uv_after[eid]
  end

  local guv = g.uv
  local guv_first = guv.first
  local guv_after = guv.after

  local gvu = g.vu
  local gvu_first = gvu.first
  local gvu_after = gvu.after

  local dv = 0

  local eid = guv_first[uid]
  while eid do
    if not uv_target[eid] then -- is non-tree edge
      dv = dv - 1
    end
    eid = guv_after[eid]
  end

  local eid = gvu_first[uid]
  while eid do
    if not uv_target[eid] then -- is non-tree edge
      dv = dv + 1
    end
    eid = gvu_after[eid]
  end

  dv_map[uid] = dv

  local eid = t.vu.first[uid]
  if eid then
    local cv = dir_map[eid] * (dv + sum) - 1
    cv_map[eid] = cv
    print("cv,dv", uid, cv, dv)
  end
end

local function feasible_tree(g)
  local u = g.u
  local u_after = u.after

  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local t = spanning_tree()
  local dir_map = {}
  local color = {}
  local root = {}

  local layer_map = longest_path(g)
  print(table.concat(layer_map, " "))

  local uid = u.first
  while uid do
    if not color[uid] then
      if vu:degree(uid) == 0 then
        root[#root + 1] = uid
        make_spanning_tree(g, t, dir_map, color, uid)
      end
    end
    uid = u_after[uid]
  end

  print("root", root[1])

  local dv_map = {}
  for i = 1, #root do
    update_dv(g, t, dv_map, root[i])
  end

  local eid = g.e.first
  while eid do
    local uid = vu_target[eid]
    local vid = uv_target[eid]
    local is_tree_edge = t.uv.target[eid] ~= nil
    local dir
    local wid
    local dv
    local cv
    if is_tree_edge then
      dir = dir_map[eid]
      if dir_map[eid] == 1 then
        wid = vid
      else
        wid = uid
      end
      dv = dv_map[wid]
      cv = dir_map[eid] * dv_map[wid] + 1
    end
    print(uid, vid, dir, wid, dv, cv)
    eid = g.e.after[eid]
  end

  return t
end




local function feasible_tree(g)
  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local rank_map = {}

  local order = topological_sort(g)
  for i = #order, 1, -1 do
    local uid = order[i]
    local u = 0
    local eid = vu_first[uid]
    while eid do
      local vid = vu_target[eid]
      local v = rank_map[vid]
      if u < v then
        u = v
      end
      eid = vu_after[eid]
    end
    rank_map[uid] = u + 1
  end





end

return function (g)
  feasible_tree(g)
  return t
end
