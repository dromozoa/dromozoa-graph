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
local graphviz_vertex_ordering = require "dromozoa.graph.graphviz_vertex_ordering"
local brandes_kopf = require "dromozoa.graph.brandes_kopf"

local g = graph()

for i = 1, 4 do
  g:add_vertex()
end
g:add_edge(1, 3)
g:add_edge(1, 4)
g:add_edge(2, 3)
local layer = {
  { 3, 4 };
  { 1, 2 };
}
local dummy_uid = 5

--[[
for i = 1, 10 do
  g:add_vertex()
end
g:add_edge(1, 3)
g:add_edge(1, 8)
g:add_edge(2, 4)
g:add_edge(2, 5)
g:add_edge(2, 6)
g:add_edge(2, 7)
g:add_edge(3, 9)
g:add_edge(4, 9)
g:add_edge(5, 10)
g:add_edge(6, 10)
g:add_edge(7, 10)
g:add_edge(8, 9)
local layer = {
  { 9, 10 };
  { 3, 4, 5, 6, 7, 8 };
  { 1, 2 };
}
local dummy_uid = 12
]]

--[[
local n0 = g:add_vertex()
local n1 = g:add_vertex()
local n2 = g:add_vertex()
local n3 = g:add_vertex()
local n4 = g:add_vertex()
local n5 = g:add_vertex()
local s0 = g:add_vertex()
local s1 = g:add_vertex()
local s2 = g:add_vertex()
local s3 = g:add_vertex()
local s4 = g:add_vertex()
g:add_edge(n0, s0)
g:add_edge(n1, s1)
g:add_edge(n1, s2)
g:add_edge(n2, s0)
g:add_edge(n2, s3)
g:add_edge(n2, s4)
g:add_edge(n3, s0)
g:add_edge(n3, s2)
g:add_edge(n4, s3)
g:add_edge(n5, s2)
g:add_edge(n5, s4)
local layer = {
  { s0, s1, s2, s3, s4 };
  { n0, n1, n2, n3, n4, n5 };
}
]]

local layer = graphviz_vertex_ordering(g, layer)

local layer_map = {}
for i = 1, #layer do
  local uids = layer[i]
  for j = 1, #uids do
    layer_map[uids[j]] = i
  end
end

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