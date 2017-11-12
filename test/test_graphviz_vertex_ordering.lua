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
local graphviz_vertex_ordering = require "experimental.graphviz_vertex_ordering"

local g = graph()
for i = 1, 8 do
  g:add_vertex()
end
g:add_edge(1, 3)
g:add_edge(1, 8)
g:add_edge(2, 4)
g:add_edge(2, 5)
g:add_edge(2, 6)
g:add_edge(2, 7)
local layer = {
  { 3, 4, 5, 6, 7, 8 };
  { 1, 2 };
}
graphviz_vertex_ordering(g, layer)
