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
local brandes_kopf = require "experimental.brandes_kopf"

local g = graph()
for i = 1, 26 do
  g:add_vertex()
end

g:add_edge(1, 3)
g:add_edge(1, 19)
g:add_edge(1, 7)
g:add_edge(2, 17)
g:add_edge(2, 18)
g:add_edge(4, 9)
g:add_edge(17, 9)
g:add_edge(5, 9)
g:add_edge(18, 20)
g:add_edge(19, 21)
g:add_edge(6, 9)
g:add_edge(6, 10)
g:add_edge(7, 9)
g:add_edge(7, 22)
g:add_edge(8, 11)
g:add_edge(8, 12)
g:add_edge(8, 13)
g:add_edge(20, 24)
g:add_edge(21, 25)
g:add_edge(22, 13)
g:add_edge(10, 23)
g:add_edge(10, 26)
g:add_edge(11, 14)
g:add_edge(11, 15)
g:add_edge(12, 15)
g:add_edge(23, 14)
g:add_edge(24, 16)
g:add_edge(25, 16)
g:add_edge(13, 16)
g:add_edge(26, 16)

-- io.write("digraph {\n")
-- local eid = g.e.first
-- while eid do
--   local uid = g.vu.target[eid]
--   local vid = g.uv.target[eid]
--   io.write(uid, "->", vid, ";\n")
--   eid = g.e.after[eid]
-- end
-- io.write("}\n")

local dummy_uid = 17

local layer = {
  { 14, 15, 16 };
  { 11, 12, 23, 24, 25, 13, 26 };
  { 8, 9, 20, 21, 22, 10 };
  { 3, 4, 17, 5, 18, 19, 6, 7 };
  { 1, 2 };
}

local layer_map = {}
for i = 1, #layer do
  local L = layer[i]
  for j = 1, #L do
    layer_map[L[j]] = i
  end
end

brandes_kopf(g, layer_map, layer, dummy_uid)
