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
local introduce_dummy_vertices = require "dromozoa.graph.introduce_dummy_vertices"
local initialize_layer = require "dromozoa.graph.initialize_layer"
local longest_path = require "dromozoa.graph.longest_path"

local brandes_kopf = require "experimental.brandes_kopf"

local M = 4
local N = 4

local g = graph()
local uid = g:add_vertex()
local wid = g:add_vertex()

local vids = {}

for i = 1, M do
  local vid = g:add_vertex()
  if i > 1 then
    g:add_edge(uid, wid)
  end
  g:add_edge(uid, vid)
  vids[i] = vid
end

for i = 1, N do
  local prev_uid
  local prev_vid
  for j = 1, M do
    local vid = g:add_vertex()
    local uid = vids[j]
    if j > 1 then
      -- g:add_edge(prev_uid, vid)
      g:add_edge(uid, prev_vid)
    end
    g:add_edge(uid, vid)
    vids[j] = vid
    prev_uid = uid
    prev_vid = vid
  end
end

for i = 1, M do
  local uid = vids[i]
  g:add_edge(uid, wid)
end

local layer_map = longest_path(g)
local dummy_uid = introduce_dummy_vertices(g, layer_map)
local layer = initialize_layer(g, layer_map)

-- io.write("digraph {\n")
-- local eid = g.e.first
-- while eid do
--   local uid = g.vu.target[eid]
--   local vid = g.uv.target[eid]
--   io.write(uid, "->", vid, ";\n")
--   eid = g.e.after[eid]
-- end
-- io.write("}\n")

local function run(f, g, layer_map, layer, dummy_uid)
  local x = f(g, layer_map, layer, dummy_uid)
  return f, g, layer_map, layer, dummy_uid, x
end

local algorithms = {
  brandes_kopf;
}

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g, layer_map, layer, dummy_uid }
end

return benchmarks
