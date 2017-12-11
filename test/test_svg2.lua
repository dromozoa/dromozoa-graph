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

local east_asian_width = require "dromozoa.ucd.east_asian_width"
local element = require "dromozoa.dom.element"
local xml_document = require "dromozoa.dom.xml_document"

local graph = require "dromozoa.graph"
local brandes_kopf = require "dromozoa.graph.brandes_kopf"
local initialize_layer = require "dromozoa.graph.initialize_layer"
local introduce_dummy_vertices = require "dromozoa.graph.introduce_dummy_vertices"
local longest_path = require "dromozoa.graph.longest_path"
local vertex_promotion = require "dromozoa.graph.vertex_promotion"

local labels = {
  "μ's";
  "一年生";
  "二年生";
  "三年生";
  "高坂穂乃果";
  "南ことり";
  "小泉花陽";
  "絢瀬絵里";
  "西木野真姫";
  "矢澤にこ";
  "園田海未";
  "星空凛";
  "東條希";
  "Printemps";
  "BiBi";
  "lily white";
}

local widths = {
  ["N"]  = 1; -- neutral
  ["Na"] = 1; -- narrow
  ["H"]  = 1; -- halfwidth
  ["A"]  = 2; -- ambiguous
  ["W"]  = 2; -- wide
  ["F"]  = 2; -- fullwidth
}
local function estimate_text_width(s)
  local width = 0
  for _, c in utf8.codes(s) do
    width = width + widths[east_asian_width(c)]
  end
  return width
end

local g = graph()
local text_width = 0

for i = 1, #labels do
  g:add_vertex()
  local width = estimate_text_width(labels[i])
  if text_width < width then
    text_width = width
  end
end
g:add_edge(1, 2)
g:add_edge(1, 3)
g:add_edge(1, 4)
g:add_edge(2, 7)
g:add_edge(2, 9)
g:add_edge(2, 12)
g:add_edge(3, 5)
g:add_edge(3, 6)
g:add_edge(3, 11)
g:add_edge(4, 8)
g:add_edge(4, 10)
g:add_edge(4, 13)
g:add_edge(5, 14)
g:add_edge(6, 14)
g:add_edge(7, 14)
g:add_edge(8, 15)
g:add_edge(9, 15)
g:add_edge(10, 15)
g:add_edge(11, 16)
g:add_edge(12, 16)
g:add_edge(13, 16)

local layer_map = longest_path(g)
local layer_map = vertex_promotion(g, layer_map)
local dummy_uid = introduce_dummy_vertices(g, layer_map)
local layer = initialize_layer(g, layer_map)
local x = brandes_kopf(g, layer_map, layer, dummy_uid)

local gw = 0
local gh = 0

local uid = g.u.first
while uid do
  local x = x[uid]
  local y = layer_map[uid]

  if gw < x then
    gw = x
  end
  if gh < y then
    gh = y
  end

  uid = g.u.after[uid]
end

local unit = 16
local sqrt2 = math.sqrt(2)
local rect_w = text_width * unit
local rect_h = unit
local ellipse_rx = rect_w / sqrt2
local ellipse_ry = rect_h / sqrt2
local margin_x = unit * 2
local margin_y = unit * 4

local view_w = (ellipse_rx * 2 + margin_x) * (gw + 1) + margin_x
local view_h = (ellipse_ry * 2 + margin_y) * gh + margin_y

local function calc_x(x)
  return x * (ellipse_rx * 2 + margin_x) + (ellipse_rx + margin_x)
end

local function calc_y(y)
  return view_h - ((y - 1) * (ellipse_ry * 2 + margin_y) + (ellipse_ry + margin_y))
end

local _ = element

local edges = _"g"

local eid = g.e.first
while eid do
  local uid = g.vu.target[eid]
  local vid = g.uv.target[eid]

  edges[#edges + 1] = _"line" {
    x1 = calc_x(x[uid]);
    y1 = calc_y(layer_map[uid]);
    x2 = calc_x(x[vid]);
    y2 = calc_y(layer_map[vid]);
    stroke = "black";
  }
  eid = g.e.after[eid]
end

local vertices = _"g"

local uid = g.u.first
while uid do
  local cx = calc_x(x[uid])
  local cy = calc_y(layer_map[uid])
  vertices[#vertices + 1] = _"g" {
    _"ellipse" {
      cx = cx;
      cy = cy;
      rx = ellipse_rx;
      ry = ellipse_ry;
      stroke = "black";
      fill = "white";
    };
    _"text" {
      x = cx;
      y = cy;
      stroke = "none";
      fill = "black";
      labels[uid];
    };
  }
  uid = g.u.after[uid]
end

local style = _"style" { [[
@font-face {
  font-family: 'Noto Sans Mono CJK JP';
  font-style: normal;
  font-weight: 400;
  src: url('https://dromozoa.s3.amazonaws.com/mirror/NotoSansCJKjp-2017-04-03/NotoSansMonoCJKjp-Regular.otf') format('opentype');
}
text {
  font-family: 'Noto Sans Mono CJK JP';
  font-weight: 400;
  dominant-baseline: central;
  text-anchor: middle;
}
]] }

local doc = xml_document(_"svg" {
  version = "1.1";
  width = view_w;
  height = view_h;
  xmlns = "http://www.w3.org/2000/svg";
  style;
  edges;
  vertices;
})
doc:serialize(io.stdout)
io.write("\n")

