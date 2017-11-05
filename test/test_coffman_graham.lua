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
local coffman_graham = require "experimental.coffman_graham"

-- https://www.slideshare.net/nikolovn/gd-2001-ver2
local g = graph()
for i = 1, 22 do
  g:add_vertex()
end
g:add_edge(22, 16)
g:add_edge( 1, 14)
g:add_edge( 2, 11)
g:add_edge( 3,  7)
g:add_edge( 4,  9)
g:add_edge( 8, 22)
g:add_edge( 8, 14)
g:add_edge( 9,  6)
g:add_edge( 9, 18)
g:add_edge(11,  3)
g:add_edge(12,  4)
g:add_edge(12, 13)
g:add_edge(12, 13)
g:add_edge(13, 20)
g:add_edge(15,  6)
g:add_edge(16, 10)
g:add_edge(17,  6)
g:add_edge(17,  7)
g:add_edge(18,  5)
g:add_edge(19, 17)
g:add_edge(20,  7)
g:add_edge(21,  7)
g:add_edge(21, 10)
g:add_edge(21, 12)

local expect_layering = {
  { 5, 7 };
  { 6, 18, 20 };
  { 9, 10, 13 };
  { 3, 4, 16 };
  { 22, 11, 12, 14, 17 };
  { 2, 8, 15, 19, 21 };
  { 1 };
}

local result = coffman_graham(g, 5)
-- print(table.concat(result, " "))

for layer = 1, #expect_layering do
  local layering = expect_layering[layer]
  for i = 1, #layering do
    local uid = layering[i]
    -- print(uid, layer, result[uid])
    assert(result[uid] == layer)
  end
end

-- http://slidesplayer.net/slide/11273019/
local g = graph()
for i = 1, 9 do
  g:add_vertex()
end
g:add_edge(1, 4)
g:add_edge(2, 4)
g:add_edge(2, 5)
g:add_edge(3, 4)
g:add_edge(3, 5)
g:add_edge(3, 6)
g:add_edge(4, 7)
g:add_edge(5, 7)
g:add_edge(5, 8)
g:add_edge(6, 7)
g:add_edge(6, 8)
g:add_edge(7, 9)
g:add_edge(8, 9)

local expect_layering = {
  { 9 };
  { 7, 8 };
  { 4, 5, 6 };
  { 1, 2, 3 };
}

local result = coffman_graham(g)
-- print(table.concat(result, " "))

for layer = 1, #expect_layering do
  local layering = expect_layering[layer]
  for i = 1, #layering do
    local uid = layering[i]
    -- print(uid, layer, result[uid])
    assert(result[uid] == layer)
  end
end
