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

return function (g)
  local uv = g.uv
  local vu = g.vu

  local sl = {}
  local sr = {}

  repeat
    -- each sink vertex
    repeat
      local n = 0
      for uid, eid in pairs(uv.ue) do
        if not eid then
          print("remove sink", uid)
          for eid in vu:each_edge(uid) do
            g:remove_edge(eid)
          end
          g:remove_vertex(uid)
          sr[#sr + 1] = uid
          n = n + 1
        end
      end
    until n == 0

    -- each source vertex
    repeat
      local n = 0
      for uid, eid in pairs(vu.ue) do
        if not eid then
          print("remove source", uid)
          for eid in uv:each_edge(uid) do
            g:remove_edge(eid)
          end
          g:remove_vertex(uid)
          sl[#sl + 1] = uid
          n = n + 1
        end
      end
    until n == 0

    if next(uv.ue) == nil then
      break
    end

    local max_uid
    local max_value
    for uid in pairs(uv.ue) do
      local value = uv:degree(uid) - vu:degree(uid)
      if not max_value or max_value < value then
        max_uid = uid
        max_value = value
      end
    end

    if max_uid then
      print("remove max", max_uid)
      for eid in uv:each_edge(max_uid) do
        g:remove_edge(eid)
      end
      for eid in vu:each_edge(max_uid) do
        g:remove_edge(eid)
      end
      g:remove_vertex(max_uid)
      sl[#sl + 1] = uid
    else
      break
    end
  until false
end
