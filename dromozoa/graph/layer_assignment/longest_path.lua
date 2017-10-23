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

  local uset = {}
  local zset = {}
  local layer = 2

  for uid, eid in pairs(uv.ue) do
    if eid then
      uset[uid] = true
    else
      vp:put("layer", uid, 1)
      zset[uid] = true
    end
  end

  while next(uset) ~= nil do
    local znew = {}

    for uid in pairs(uset) do
      local assign = true
      for eid, vid in uv:each_edge(uid) do
        if not zset[vid] then
          assign = false
          break
        end
      end
      if assign then
        vp:put("layer", uid, layer)
        znew[uid] = true
        uset[uid] = nil
      end
    end

    if next(znew) == nil then
      break
    end

    layer = layer + 1
    for k, v in pairs(znew) do
      zset[k] = v
    end
  end
end
