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

local function count(uv, order1, order2)
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target

  local order_map = {}
  for i = 1, #order2 do
    order_map[order2[i]] = i
  end

  local sequence = {}
  local p = {}
  for i = 1, #order1 do
    local uid = order1[i]
    local n = 0
    local eid = uv_first[uid]
    while eid do
      n = n + 1
      p[n] = order_map[uv_target[eid]]
      eid = uv_after[eid]
    end
    sort(p)
    for i = 1, n do
      sequence[#sequence + 1] = p[i]
      p[i] = nil
    end
  end

  local index = 1
  while index < #order2 do
    index = index * 2
  end
  local tree_size = 2 * index - 1
  local tree = {}
  for i = 1, tree_size do
    tree[i] = 0
  end

  local count = 0
  for i = 1, #sequence do
    local j = sequence[i] + index
    tree[j] = tree[j] + 1
    while j > 1 do
      if j % 2 == 0 then
        count = count + tree[j + 1]
      end
      j = j / 2
      j = j - j % 1
      tree[j] = tree[j] + 1
    end
  end

  return count
end

return function (g, order1, order2)
  if #order1 >= #order2 then
    return count(g.uv, order1, order2)
  else
    return count(g.vu, order2, order1)
  end
end
