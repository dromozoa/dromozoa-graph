-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local adjacency_list = require "dromozoa.graph.adjacency_list"
local dfs = require "dromozoa.graph.dfs"

local g = adjacency_list()

g:add_vertex(1)
g:add_vertex(2)
g:add_vertex(3)
g:add_vertex(4)
g:add_vertex(5)
g:add_edge(1, 1, 2)
g:add_edge(2, 2, 3)
g:add_edge(3, 2, 4)

assert(#g.ue == 5)
assert(#g.ev == 3)

for eid, vid in g:each_edge(2) do
  print(eid, vid)
end

assert(g:degree(2) == 2)

dfs(g, {
  tree_edge = function (_, eid, uid, vid)
    print("tree_edge", uid, vid)
  end;
  finish_edge = function (_, eid, uid, vid)
    print("finish_edge", uid, vid)
  end;
}, 1)
