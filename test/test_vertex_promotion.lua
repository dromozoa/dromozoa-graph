-- Copyright (C) 2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local longest_path = require "dromozoa.graph.longest_path"
local vertex_promotion = require "dromozoa.graph.vertex_promotion"
local clone = require "clone"

local function check(result, expect)
  local n = #result
  assert(n == #expect)
  for i = 1, n do
    assert(result[i] == expect[i])
  end
end

local g = graph()
for i = 1, 7 do
  g:add_vertex()
end
g:add_edge(1, 2)
g:add_edge(2, 3)
g:add_edge(3, 4)
g:add_edge(3, 5)
g:add_edge(2, 6)
g:add_edge(1, 7)

local layer_map1 = longest_path(g)
check(layer_map1, { 4, 3, 2, 1, 1, 1, 1 })

local layer_map2 = vertex_promotion(g, layer_map1)
check(layer_map2, { 4, 3, 2, 1, 1, 2, 3 })

-- Fig.6
local g = graph()
for i = 1, 8 do
  g:add_vertex()
end
g:add_edge(1, 2)
g:add_edge(2, 3)
g:add_edge(3, 4)
g:add_edge(1, 5)
g:add_edge(5, 6)
g:add_edge(5, 7)
g:add_edge(5, 8)

local layer_map1 = longest_path(g)
local layer_map2 = vertex_promotion(g, clone(layer_map1))
for k, v in pairs(layer_map1) do
  assert(v == layer_map2[k])
end
for k, v in pairs(layer_map2) do
  assert(v == layer_map1[k])
end
