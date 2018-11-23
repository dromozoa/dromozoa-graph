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

local graph = require "dromozoa.graph"

local verbose = os.getenv "VERBOSE" == "1"

-- https://eli.thegreenplace.net/2015/directed-graph-traversal-orderings-and-applications-to-data-flow-analysis/
local g = graph()

local X = g:add_vertex()
local T = g:add_vertex()
local B = g:add_vertex()
local C = g:add_vertex()
local E = g:add_vertex()
local D = g:add_vertex()
local G = g:add_vertex()
local M = g:add_vertex()
local Z = g:add_vertex()

g:add_edge(X, C)
g:add_edge(X, B)
g:add_edge(X, T)
g:add_edge(T, B)
g:add_edge(B, D)
g:add_edge(C, E)
g:add_edge(E, M)
g:add_edge(E, D)
g:add_edge(D, G)
g:add_edge(G, D)
g:add_edge(M, C)
g:add_edge(Z, C)

local expect = { M, G, D, E, C, B, T, X }

local result, color = g:uv_postorder(X)
if verbose then
  print(table.concat(expect, " "))
  print(table.concat(result, " "))
  print(color[X])
  print(color[Z])
end

assert(#result == #expect)
for i = 1, #expect do
  assert(result[i] == expect[i])
end
assert(color[X])
assert(not color[Z])
