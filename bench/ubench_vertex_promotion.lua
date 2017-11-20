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
local clone = require "dromozoa.graph.clone"
local longest_path = require "dromozoa.graph.longest_path"
local vertex_promotion = require "experimental.vertex_promotion"
local vertex_promotion2 = require "experimental.vertex_promotion2"
local vertex_promotion3 = require "experimental.vertex_promotion3"
local vertex_promotion4 = require "experimental.vertex_promotion4"
local vertex_promotion5 = require "experimental.vertex_promotion5"

local N = 20

local function run(f, g, layer_map)
  local result = f(g, clone(layer_map))
  return f, g, layer_map, result
end

local g = graph()
local uid = g:add_vertex()
for i = 1, N do
  local vid1 = g:add_vertex()
  local vid2 = g:add_vertex()
  g:add_edge(uid, vid1)
  g:add_edge(uid, vid2)
  uid = vid1
end

local layer_map = longest_path(g)

local algorithms = {
  -- vertex_promotion;
  -- vertex_promotion2;
  vertex_promotion3;
  vertex_promotion4;
  vertex_promotion5;
}

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g, layer_map }
end

return benchmarks
