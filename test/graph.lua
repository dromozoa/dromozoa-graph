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

local bfs = require "dromozoa.graph.bfs"
local bigraph = require "dromozoa.graph.bigraph"
local dfs = require "dromozoa.graph.dfs"
local digraph = require "dromozoa.graph.digraph"
local undirected_dfs = require "dromozoa.graph.undirected_dfs"

local read = require "test.read"

local directed, filename = ...

local graph
if directed == "directional" then
  graph = digraph()
else
  graph = bigraph()
end

local n = read(graph, filename)

local bfs_visitor = {}
function bfs_visitor:discover_vertex(u)
  print("discover_vertex", u)
end
function bfs_visitor:examine_vertex(u)
  print("examine_vertex", u)
end
function bfs_visitor:examine_edge(e, u, v)
  print("examine_edge", e)
end
function bfs_visitor:tree_edge(e, u, v)
  print("tree_edge", e)
end
function bfs_visitor:non_tree_edge(e, u, v)
  print("non_tree_edge", e)
end
function bfs_visitor:gray_target(e, u, v)
  print("gray_target", e)
end
function bfs_visitor:black_target(e, u, v)
  print("black_target", e)
end
function bfs_visitor:finish_vertex(u)
  print("finish_vertex", u)
end

local dfs_visitor = {}
function dfs_visitor:start_vertex(u)
  print("start_vertex", u)
end
function dfs_visitor:discover_vertex(u)
  print("discover_vertex", u)
end
function dfs_visitor:examine_edge(e, u, v)
  print("examine_edge", e)
end
function dfs_visitor:tree_edge(e, u, v)
  print("tree_edge", e)
end
function dfs_visitor:back_edge(e, u, v)
  print("back_edge", e)
end
function dfs_visitor:finish_edge(e, u, v)
  print("finish_edge", e)
end
function dfs_visitor:finish_vertex(u)
  print("finish_vertex", u)
end

local g
if directed == "undirected" then
  g = graph
else
  g = graph.uv
end

print("==== each_edge ====")

for uid = 1, n do
  for eid, vid in g:each_edge(uid) do
    print("each_edge", eid, uid, vid)
  end
end

print("==== degree ====")
for uid = 1, n do
  print("degree", g:degree(uid))
end

print("==== bfs ====")
bfs(g, bfs_visitor, 1)

print("==== dfs ====")
dfs(g, dfs_visitor, 1)

if directed == "undirected" then
  print("==== undirected_dfs ====")
  undirected_dfs(g, dfs_visitor, 1)
end
