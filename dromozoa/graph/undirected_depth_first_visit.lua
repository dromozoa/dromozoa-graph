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

return function (g, that, uid, vcolor, ecolor)
  local discover_vertex = that.discover_vertex
  local examine_edge = that.examine_edge
  local tree_edge = that.tree_edge
  local back_edge = that.back_edge
  local finish_edge = that.finish_edge
  local finish_vertex = that.finish_vertex

  local eid_stack1 = {}
  local uid_stack1 = {}
  local vid_stack1 = {}
  local inv_stack1 = {}
  local eid_stack2 = {}
  local inv_stack2 = {}
  local n1 = 0
  local n2 = 0

  vcolor[uid] = 1
  if not discover_vertex or discover_vertex(that, uid) ~= false then
    n1 = g:reverse_push_edges(uid, n1, eid_stack1, uid_stack1, vid_stack1, inv_stack1)
  end

  while n1 > 0 do
    local eid = eid_stack1[n1]
    local uid = uid_stack1[n1]
    local vid = vid_stack1[n1]
    local inv = inv_stack1[n1]
    local vc = vcolor[vid]

    if eid ~= eid_stack2[n2] or inv ~= inv_stack2[n2] then
      if examine_edge then
        examine_edge(that, eid, uid, vid)
      end

      local ec = ecolor[eid]
      ecolor[eid] = true

      if not vc then
        if tree_edge then
          tree_edge(that, eid, uid, vid)
        end
        vcolor[vid] = 1
        if not discover_vertex or discover_vertex(that, vid) ~= false then
          n1 = g:reverse_push_edges(vid, n1, eid_stack1, uid_stack1, vid_stack1, inv_stack1)
        end
      elseif vc > 0 then
        if not ec then
          if back_edge then
            back_edge(that, eid, uid, vid)
          end
        end
        vcolor[vid] = vc + 1
      end

      n2 = n2 + 1
      eid_stack2[n2] = eid
      inv_stack2[n2] = inv
    else
      eid_stack1[n1] = nil
      uid_stack1[n1] = nil
      vid_stack1[n1] = nil
      inv_stack1[n1] = nil
      eid_stack2[n2] = nil
      inv_stack2[n2] = nil

      n1 = n1 - 1
      n2 = n2 - 1

      if vc == 1 then
        vcolor[vid] = 0
        if finish_vertex then
          finish_vertex(that, vid)
        end
      elseif vc > 1 then
        vcolor[vid] = vc - 1
      end

      if finish_edge then
        finish_edge(that, eid, uid, vid)
      end
    end
  end

  vcolor[uid] = 0
  if finish_vertex then
    finish_vertex(that, uid)
  end
end
