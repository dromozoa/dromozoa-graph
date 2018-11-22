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
local find_dominators = require "dromozoa.graph.find_dominators"

local verbose = os.getenv "VERBOSE" == "1"

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

local idom = find_dominators(g, L1)

if verbose then
  for uid = 1, 7 do
    print(uid, idom[uid])
  end
end
