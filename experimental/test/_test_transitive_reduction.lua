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
local transitive_reduction = require "dromozoa.graph.transitive_reduction"

local g = graph()
local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local u4 = g:add_vertex()
local e1 = g:add_edge(u1, u2)
local e2 = g:add_edge(u2, u3)
local e3 = g:add_edge(u3, u4)
local e4 = g:add_edge(u1, u4)
local remove = transitive_reduction(g)
-- print(table.concat(remove, " "))
assert(#remove == 1)
assert(remove[1] == e4)

local g = graph()
local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local u4 = g:add_vertex()
local e1 = g:add_edge(u1, u4)
local e2 = g:add_edge(u1, u2)
local e3 = g:add_edge(u2, u3)
local e4 = g:add_edge(u3, u4)
local remove = transitive_reduction(g)
-- print(table.concat(remove, " "))
assert(#remove == 1)
assert(remove[1] == e1)

-- https://jp.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/32723/versions/3/screenshot.png
local g = graph()
for i = 1, 10 do
  g:add_vertex()
end
g:add_edge(1, 5)
g:add_edge(1, 10)
g:add_edge(2, 4)
g:add_edge(2, 5)
g:add_edge(2, 7)
g:add_edge(2, 9)
g:add_edge(3, 7)
g:add_edge(3, 8)
g:add_edge(3, 10)
g:add_edge(4, 10)
g:add_edge(5, 6)
g:add_edge(5, 10)
g:add_edge(6, 8)
g:add_edge(6, 10)
g:add_edge(7, 10)
g:add_edge(8, 10)

local remove = transitive_reduction(g)
-- print(table.concat(remove, " "))
assert(#remove == 4)
assert(remove[1] == 2) -- 1,10
assert(remove[2] == 9) -- 3,10
assert(remove[3] == 12) -- 5,10
assert(remove[4] == 14) -- 6,10
