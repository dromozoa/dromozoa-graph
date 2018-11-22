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

-- A Fast Algorithm for Finding Dominators in a Flowgraph
local g = graph()

local R = g:add_vertex()
local A = g:add_vertex()
local B = g:add_vertex()
local C = g:add_vertex()
local D = g:add_vertex()
local E = g:add_vertex()
local F = g:add_vertex()
local G = g:add_vertex()
local H = g:add_vertex()
local I = g:add_vertex()
local J = g:add_vertex()
local K = g:add_vertex()
local L = g:add_vertex()

g:add_edge(R, A)
g:add_edge(R, B)
g:add_edge(R, C)
g:add_edge(A, D)
g:add_edge(B, A)
g:add_edge(B, D)
g:add_edge(B, E)
g:add_edge(C, F)
g:add_edge(C, G)
g:add_edge(D, L)
g:add_edge(E, H)
g:add_edge(F, I)
g:add_edge(G, I)
g:add_edge(G, J)
g:add_edge(H, E)
g:add_edge(H, K)
g:add_edge(I, K)
g:add_edge(J, I)
g:add_edge(L, H)
g:add_edge(K, R)
g:add_edge(K, I)

local idom = g:find_dominators(R)
if verbose then
  for uid = R, K do
    print(uid, idom[uid])
  end
end
assert(idom[R] == nil)
assert(idom[A] == R)
assert(idom[B] == R)
assert(idom[C] == R)
assert(idom[D] == R)
assert(idom[E] == R)
assert(idom[F] == C)
assert(idom[G] == C)
assert(idom[H] == R)
assert(idom[I] == R)
assert(idom[J] == G)
assert(idom[K] == R)
assert(idom[L] == D)

-- ssa-external-japanese.pdf
local g = graph()

local L1 = g:add_vertex()
local L2 = g:add_vertex()
local L3 = g:add_vertex()
local L4 = g:add_vertex()
local L5 = g:add_vertex()
local L6 = g:add_vertex()
local L7 = g:add_vertex()

g:add_edge(L1, L2)
g:add_edge(L1, L6)
g:add_edge(L2, L3)
g:add_edge(L2, L4)
g:add_edge(L3, L5)
g:add_edge(L4, L5)
g:add_edge(L5, L7)
g:add_edge(L6, L7)

local idom = g:find_dominators(L1)
if verbose then
  for uid = 1, 7 do
    print(uid, idom[uid])
  end
end
assert(idom[L1] == nil)
assert(idom[L2] == L1)
assert(idom[L3] == L2)
assert(idom[L4] == L2)
assert(idom[L5] == L2)
assert(idom[L6] == L1)
assert(idom[L7] == L1)
