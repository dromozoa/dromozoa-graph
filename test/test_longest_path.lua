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

local graph = require "dromozoa.graph"
local longest_path = require "experimental.longest_path3"
local topological_sort = require "dromozoa.graph.topological_sort"

-- https://www.slideshare.net/nikolovn/gd-2001-ver2
local g = graph()
for i = 1, 22 do
  g:add_vertex()
end
g:add_edge(22, 16)
g:add_edge( 1, 14)
g:add_edge( 2, 11)
g:add_edge( 3,  7)
g:add_edge( 4,  9)
g:add_edge( 8, 22)
g:add_edge( 8, 14)
g:add_edge( 9,  6)
g:add_edge( 9, 18)
g:add_edge(11,  3)
g:add_edge(12,  4)
g:add_edge(12, 13)
g:add_edge(12, 13)
g:add_edge(13, 20)
g:add_edge(15,  6)
g:add_edge(16, 10)
g:add_edge(17,  6)
g:add_edge(17,  7)
g:add_edge(18,  5)
g:add_edge(19, 17)
g:add_edge(20,  7)
g:add_edge(21,  7)
g:add_edge(21, 10)
g:add_edge(21, 12)

-- print(table.concat(topological_sort(g), " "))

local expect_layering = {
  { 5, 6, 7, 10, 14 };
  { 1, 3, 15, 16, 17, 18, 20 };
  { 22, 9, 11, 13, 19 };
  { 2, 4, 8 };
  { 12 };
  { 21 };
}

local result = longest_path(g)
-- print(table.concat(result, " "))

for layer = 1, #expect_layering do
  local layering = expect_layering[layer]
  for i = 1, #layering do
    local uid = layering[i]
    -- print(uid, layer, result[uid])
    assert(result[uid] == layer)
  end
end
