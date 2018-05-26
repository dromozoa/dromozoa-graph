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

  local order1_map = {}
  for i = 1, #order1 do
    order1_map[order1[i]] = i
  end

  local order2_map = {}
  for i = 1, #order2 do
    order2_map[order2[i]] = i
  end

  local sequence = {}
  for i = 1, #order1 do
    local uid = order1[i]
    local eid = uv.first[uid]
    while eid do
      sequence[#sequence + 1] = {
        eid = eid;
        u = order1_map[uid];
        v = order2_map[uv_target[eid]];
      }
      eid = uv.after[eid]
    end
  end

  sort(sequence, function (a, b)
    if a.u == b.u then
      return a.v < b.v
    else
      return a.u < b.u
    end
  end)

  local first_index = 1
  while first_index < #order2 do
    first_index = first_index * 2
  end
  local tree_size = 2 * first_index - 1
  local tree = {}
  for i = 1, tree_size do
    tree[i] = 0
  end

  local cross_count = 0
  for i = 1, #sequence do
    local index = sequence[i].v + first_index
    tree[index] = tree[index] + 1
    while index > 1 do
      if index % 2 == 0 then
        cross_count = cross_count + tree[index + 1]
      end
      index = index / 2
      index = index - index % 1
      tree[index] = tree[index] + 1
    end
  end

  return cross_count
end

return function (g, order1, order2)
  if #order1 >= #order2 then
    return count(g.uv, order1, order2)
  else
    return count(g.vu, order2, order1)
  end
end
