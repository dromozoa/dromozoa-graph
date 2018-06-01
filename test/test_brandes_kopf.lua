-- Copyright (C) 2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local xml_document = require "dromozoa.dom.xml_document"
local element = require "dromozoa.dom.element"
local colors = require "dromozoa.css.colors"

local graph = require "dromozoa.graph"
local make_dummy_vertices = require "dromozoa.graph.make_dummy_vertices"
local make_layers = require "dromozoa.graph.make_layers"
local brandes_kopf = require "dromozoa.graph.brandes_kopf"
local write_dot = require "write_dot"

local g = graph()
for i = 1, 11 do
  g:add_vertex()
end
g:add_edge(1, 2)
g:add_edge(1, 3)
g:add_edge(2, 4)
g:add_edge(2, 5)
g:add_edge(2, 6)
g:add_edge(2, 7)
g:add_edge(2, 8)
g:add_edge(3, 9)
g:add_edge(3, 10)
g:add_edge(3, 11)
local dummy_uid = 12

local layer = {
  { 1 };
  { 2, 3 };
  { 4, 5, 6, 7, 8, 9, 10, 11 };
}

local expect = {
  4,
  3, 5.5,
  0, 1, 2, 3, 4, 5, 6, 7,
}

local layer_map = {}
for i = 1, #layer do
  local uids = layer[i]
  for j = 1, #uids do
    layer_map[uids[j]] = i
  end
end

local x = brandes_kopf(g, layer_map, layer, dummy_uid)

local uid = g.u.first
while uid do
  assert(x[uid] == expect[uid])
  uid = g.u.after[uid]
end

local g = graph()

for i = 1, 23 do
  g:add_vertex()
end

g:add_edge(1, 13)
g:add_edge(1, 21)
g:add_edge(1, 4)
g:add_edge(1, 3)
g:add_edge(2, 3)
g:add_edge(2, 20)
g:add_edge(3, 4)
g:add_edge(3, 5)
g:add_edge(3, 23)
g:add_edge(4, 6)
g:add_edge(5, 7)
g:add_edge(6, 8)
g:add_edge(6, 16)
g:add_edge(6, 23)
g:add_edge(7, 9)
g:add_edge(8, 10)
g:add_edge(8, 11)
g:add_edge(9, 12)
g:add_edge(10, 13)
g:add_edge(10, 14)
g:add_edge(10, 15)
g:add_edge(11, 15)
g:add_edge(11, 16)
g:add_edge(12, 20)
g:add_edge(13, 17)
g:add_edge(14, 17)
g:add_edge(14, 18)
g:add_edge(16, 18)
g:add_edge(16, 19)
g:add_edge(16, 20)
g:add_edge(18, 21)
g:add_edge(19, 22)
g:add_edge(21, 23)
g:add_edge(22, 23)

local layer = {
  { 23 };
  { 21, 22 };
  { 17, 18, 19, 20 };
  { 13, 14, 15, 16 };
  { 10, 11, 12 };
  { 8, 9 };
  { 6, 7 };
  { 4, 5 };
  { 3 };
  { 1, 2 };
}

local layer_map = {}
for i = 1, #layer do
  local L = layer[i]
  for j = 1, #L do
    layer_map[L[j]] = i
  end
end

local dummy_uid = g.u.last + 1
make_dummy_vertices(g, layer_map, {})

local layer = make_layers(g, layer_map)

-- fix
local order = layer[3]
assert(order[5] == 20)
assert(order[6] == 55)
order[5] = 55
order[6] = 20

write_dot("test1.dot", g)

local x = brandes_kopf(g, layer_map, layer, dummy_uid)

local expect = {
  [0.0] = { 13, 17 };
  [1.5] = { 21 };
  [2.0] = { 10, 14, 18 };
  [2.5] = { 1, 8 };
  [3.0] = { 11, 15 };
  [4.0] = { 4, 6, 16, 19, 22 };
  [4.5] = { 23 };
  [6.0] = { 3, 5, 7, 9, 12, 20 };
  [7.0] = { 2 };
}

local expect_map = {}
for k, v in pairs(expect) do
  for i = 1, #v do
    expect_map[v[i]] = k
  end
end

local uid = g.u.first
while uid do
  assert(x[uid] >= 0)
  if uid < dummy_uid then
    assert(x[uid] == expect_map[uid])
  end
  uid = g.u.after[uid]
end

local function calc_x(x)
  return x * 50 + 50
end

local function calc_y(y)
  return 600 - y * 50
end

local _ = element
local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  version = "1.1";
  width = 600;
  height = 600;
}

local eid = g.e.first
while eid do
  local uid = g.vu.target[eid]
  local vid = g.uv.target[eid]
  svg[#svg + 1] = _"line" {
    x1 = calc_x(x[uid]);
    y1 = calc_y(layer_map[uid]);
    x2 = calc_x(x[vid]);
    y2 = calc_y(layer_map[vid]);
    stroke = colors.black;
  }
  eid = g.e.after[eid]
end

local uid = g.u.first
while uid do
  local cx = calc_x(x[uid])
  local cy = calc_y(layer_map[uid])
  if uid < dummy_uid then
    svg[#svg + 1] = _"circle" {
      cx = cx;
      cy = cy;
      r = 5;
      stroke = colors.black;
      fill = colors.black;
    }
    svg[#svg + 1] = _"text" {
      x = cx + 5;
      y = cy - 5;
      fill = colors.black;
      uid;
    }
  else
    svg[#svg + 1] = _"circle" {
      cx = cx;
      cy = cy;
      r = 5;
      stroke = colors.black;
      fill = colors.white;
    }
  end
  uid = g.u.after[uid]
end

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
