-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local event = {
  "initialize_vertex",
  "discover_vertex",
  "examine_vertex",
  "examine_edge",
  "tree_edge",
  "non_tree_edge",
  "gray_target",
  "black_target",
  "finish_vertex",
}

local function empty()
end

return function (visitor)
  for i = 1, #event do
    local v = event[i]
    if not visitor[v] then
      visitor[v] = empty
    end
  end
  return visitor
end
