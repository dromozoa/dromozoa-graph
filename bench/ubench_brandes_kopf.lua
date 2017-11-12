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
local brandes_kopf2 = require "experimental.brandes_kopf2"
local brandes_kopf3 = require "experimental.brandes_kopf3"
local brandes_kopf4 = require "experimental.brandes_kopf4"

local M = 8
local N = 16

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
  local vid2
  local vid1
  for j = 1, M do
    local vid = g:add_vertex()
    local uid = vids[j]
    if j > 2 then
      if j % 2 == 1 then
        g:add_edge(uid, vid2)
      end
    end
    if j > 1 then
      g:add_edge(uid, vid1)
    end
    g:add_edge(uid, vid)
    vids[j] = vid
    vid2 = vid1
    vid1 = vid
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

--[====[
local x = brandes_kopf(g, layer_map, layer, dummy_uid)

local function calc_x(x)
  return x * 50 + 50
end

local function calc_y(y)
  return 600 - y * 50
end

io.write([[<svg version="1.1" width="600" height="600" xmlns="http://www.w3.org/2000/svg">]])

local eid = g.e.first
while eid do
  local uid = g.vu.target[eid]
  local vid = g.uv.target[eid]
  local x1 = calc_x(x[uid])
  local y1 = calc_y(layer_map[uid])
  local x2 = calc_x(x[vid])
  local y2 = calc_y(layer_map[vid])
  io.write(([[<line x1="%.17g" y1="%.17g" x2="%.17g" y2="%.17g" stroke="black"/>]]):format(x1, y1, x2, y2))
  eid = g.e.after[eid]
end

local uid = g.u.first
while uid do
  local cx = calc_x(x[uid])
  local cy = calc_y(layer_map[uid])
  if uid < dummy_uid then
    io.write(([[<circle cx="%.17g" cy="%.17g" r="5" stroke="black" fill="black"/>]]):format(cx, cy))
    io.write(([[<text x="%.17g" y="%.17g" stroke="none" fill="black">%s</text>]]):format(cx + 5, cy - 5, uid))
  else
    io.write(([[<circle cx="%.17g" cy="%.17g" r="5" stroke="black" fill="white"/>]]):format(cx, cy))
  end
  uid = g.u.after[uid]
end
io.write("</svg>\n")
]====]

local function run(f, g, layer_map, layer, dummy_uid)
  local x = f(g, layer_map, layer, dummy_uid)
  return f, g, layer_map, layer, dummy_uid, x
end

local algorithms = {
  brandes_kopf;
  brandes_kopf2;
  brandes_kopf3;
  brandes_kopf4;
}

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g, layer_map, layer, dummy_uid }
end

return benchmarks
