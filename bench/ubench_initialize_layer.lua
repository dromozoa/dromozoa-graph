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
local introduce_dummy_vertices = require "dromozoa.graph.introduce_dummy_vertices"
local initialize_layer = require "experimental.initialize_layer"
local initialize_layer2 = require "experimental.initialize_layer2"

local M = 29
local N = 29

local function run(f, g, layer_map)
  local layer = f(g, layer_map)
  return f, g, layer_map, layer
end

local g = graph()
g:add_vertex()
for i = 2, M do
  g:add_vertex()
  g:add_edge(i - 1, i)
end
for i = 2, N do
  g:add_edge(1, M)
end

local layer_map = longest_path(g)
introduce_dummy_vertices(g, layer_map)

-- io.write("digraph {\n")
-- local eid = g.e.first
-- while eid do
--   local uid = g.vu.target[eid]
--   local vid = g.uv.target[eid]
--   io.write(uid, "->", vid, ";\n")
--   eid = g.e.after[eid]
-- end
-- io.write("}\n")

local algorithms = {
  initialize_layer,
  initialize_layer2,
}

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g, layer_map }
end

return benchmarks
