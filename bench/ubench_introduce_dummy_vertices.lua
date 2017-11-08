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
local introduce_dummy_vertices = require "experimental.introduce_dummy_vertices"
local introduce_dummy_vertices2 = require "experimental.introduce_dummy_vertices2"

local M = 10
local N = 50

local function run(f, g, layer_map)
  local dummy_map = f(clone(g), clone(layer_map))
  return f, g, layer_map, dummy_map
end

local g = graph()
local uid = g:add_vertex()
for i = 1, N do
  local vids = {}
  local vid = uid
  for j = 1, M do
    local wid = g:add_vertex()
    g:add_edge(vid, wid)
    vid = wid
  end
  g:add_edge(uid, vid)
  uid = vid
end

-- io.write("digraph {\n")
-- local eid = g.e.first
-- while eid do
--   local uid = g.vu.target[eid]
--   local vid = g.uv.target[eid]
--   io.write(uid, "->", vid, ";\n")
--   eid = g.e.after[eid]
-- end
-- io.write("}\n")

local layer_map = longest_path(g)

local algorithms = {
  function (g, layer_map) return {} end;
  introduce_dummy_vertices;
  introduce_dummy_vertices2;
}

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g, layer_map }
end

return benchmarks
