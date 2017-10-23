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

return function (g, vp)
  local uv = g.uv
  local ue = uv.ue

  local layer = 1
  local U = {}
  local Z = {}

  repeat
    local n = 0

    for uid in pairs(ue) do
      if not U[uid] then
        local assign = true
        for eid, vid in uv:each_edge(uid) do
          if not Z[vid] then
            assign = false
            break
          end
        end
        if assign then
          vp:put("layer", uid, layer)
          U[uid] = true
          n = n + 1
        end
      end
    end

    layer = layer + 1
    for k, v in pairs(U) do
      Z[k] = v
    end
  until n == 0
end
