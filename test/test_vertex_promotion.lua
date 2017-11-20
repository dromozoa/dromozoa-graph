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
local longest_path = require "dromozoa.graph.longest_path"
local vertex_promotion = require "dromozoa.graph.vertex_promotion"

local g = graph()
for i = 1, 4 do
  g:add_vertex()
end
g:add_edge(1, 2)
g:add_edge(1, 3)
g:add_edge(3, 4)

local layer_map = longest_path(g)
print(table.concat(layer_map, " "))

local layer_map = vertex_promotion(g, layer_map)
print(table.concat(layer_map, " "))
