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

local bigraph = require "dromozoa.graph.bigraph"
local greedy = require "dromozoa.graph.cycle_removal.greedy"

local g = bigraph()
local u1 = g:add_vertex()
local u2 = g:add_vertex()
local u3 = g:add_vertex()
local u4 = g:add_vertex()

--[[
g:add_edge(u1, u2)
g:add_edge(u1, u3)
g:add_edge(u2, u4)
g:add_edge(u3, u4)
]]

--[[
g:add_edge(u1, u2)
g:add_edge(u2, u3)
g:add_edge(u3, u4)
g:add_edge(u4, u1)
]]

g:add_edge(u1, u2)
g:add_edge(u2, u3)
g:add_edge(u3, u1)
g:add_edge(u3, u4)
g:add_edge(u4, u2)

greedy(g)
