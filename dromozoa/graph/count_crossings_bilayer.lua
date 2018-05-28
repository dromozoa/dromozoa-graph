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

local sort = table.sort

local function count(uv, south, north)
  local n = #south

  local order_map = {}
  for i = 1, n do
    order_map[south[i]] = i
  end
  local index = 1
  while index < n do
    index = index * 2
  end
  local tree = {}
  for i = 1, index * 2 - 1 do
    tree[i] = 0
  end
  index = index - 1

  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local positions = {}
  local n = 0
  local p = {}
  for i = 1, #north do
    local uid = north[i]
    local m = 0
    local eid = uv_first[uid]
    while eid do
      m = m + 1
      p[m] = order_map[uv_target[eid]]
      eid = uv_after[eid]
    end
    for j = m + 1, #p do
      p[j] = nil
    end
    sort(p)
    for j = 1, m do
      positions[n + j] = p[j]
    end
    n = n + m
  end

  local count = 0
  for i = 1, #positions do
    local j = positions[i] + index
    tree[j] = tree[j] + 1
    while j > 1 do
      if j % 2 == 0 then
        count = count + tree[j + 1]
        j = j / 2
      else
        j = (j - 1) / 2
      end
      tree[j] = tree[j] + 1
    end
  end

  return count
end

return function (g, south, north)
  if #south <= #north then
    return count(g.uv, south, north)
  else
    return count(g.vu, north, south)
  end
end
