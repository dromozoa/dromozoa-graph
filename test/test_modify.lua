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

local graph = require "dromozoa.graph"

local g = graph()
local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()

g:create_edge(v1, v2)
g:create_edge(v1, v3)

for v, e in v1:each_adjacent_vertex() do
  if v.id == v2.id then
    e:remove()
  end
end

g:create_edge(v1, v2)
for v, e in v1:each_adjacent_vertex() do
  e:remove()
end
