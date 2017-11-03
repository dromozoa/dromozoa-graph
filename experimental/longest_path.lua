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

  local uset = {}
  local zset = {}
  local result = {}

  local uid = u.first
  while uid do
    if not uv_first[uid] then
      result[uid] = 1
      zset[uid] = true
    else
      uset[uid] = true
    end
    uid = u_after[uid]
  end

  local layer = 2
  while next(uset) ~= nil do
    local znew = {}

    for uid in pairs(uset) do
      local assign = true
      local eid = uv_first[uid]
      while eid do
        local vid = uv_target[eid]
        if not zset[vid] then
          assign = false
          break
        end
        eid = uv_after[eid]
      end
      if assign then
        result[uid] = layer
        znew[uid] = true
        uset[uid] = nil
      end
    end

    if next(znew) == nil then
      break
    end

    layer = layer + 1
    for uid in pairs(znew) do
      zset[uid] = uid
    end
  end

  return result
end
