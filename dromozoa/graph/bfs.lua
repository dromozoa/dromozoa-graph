-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

return function (g, visitor, uid, color)
  if not color then
    color = {}
  end

  local discover_vertex = visitor.discover_vertex
  local examine_vertex = visitor.examine_vertex
  local examine_edge = visitor.examine_edge
  local tree_edge = visitor.tree_edge
  local non_tree_edge = visitor.non_tree_edge
  local gray_target = visitor.gray_target
  local black_target = visitor.black_target
  local finish_vertex = visitor.finish_vertex

  local queue = { uid }
  local min = 1
  local max = 1

  color[uid] = 1
  if discover_vertex then
    discover_vertex(visitor, uid)
  end

  while min <= max do
    local uid = queue[min]
    queue[min] = nil
    min = min + 1

    if not examine_vertex or examine_vertex(visitor, uid) ~= false then
      for eid, vid in g:each_edge(uid) do
        if examine_edge then
          examine_edge(visitor, eid, uid, vid)
        end

        local c = color[vid]
        if not c then
          if tree_edge then
            tree_edge(visitor, eid, uid, vid)
          end

          max = max + 1
          queue[max] = vid

          color[vid] = 1
          if discover_vertex then
            discover_vertex(visitor, vid)
          end
        else
          if non_tree_edge then
            non_tree_edge(visitor, eid, uid, vid)
          end

          if c == 1 then
            if gray_target then
              gray_target(visitor, eid, uid, vid)
            end
          else
            if black_target then
              black_target(visitor, eid, uid, vid)
            end
          end
        end
      end
    end

    color[uid] = 0
    if finish_vertex then
      finish_vertex(visitor, uid)
    end
  end

  return color
end
