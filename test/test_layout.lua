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

local element = require "dromozoa.dom.element"
local space_separated = require "dromozoa.dom.space_separated"
local xml_document = require "dromozoa.dom.xml_document"
local color4d = require "dromozoa.css.color4d"
local colors = require "dromozoa.css.colors"
local path_data = require "dromozoa.svg.path_data"

local graph = require "dromozoa.graph"
local layout = require "dromozoa.graph.layout"

local g = graph()
for i = 1, 8 do
  g:add_vertex()
end
g:add_edge(1, 2)
g:add_edge(1, 5)
g:add_edge(1, 6)
g:add_edge(2, 3)
g:add_edge(3, 4)
g:add_edge(4, 8)
g:add_edge(4, 8)
g:add_edge(5, 7)
g:add_edge(6, 7)
g:add_edge(7, 8)

local dummy_min, layer_map, x = layout(g)

local function calc_x(x)
  return x * 50 + 50
end

local function calc_y(y)
  return 300 - y * 50
end

local _ = element
local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  version = "1.1";
  width = 300;
  height = 300;
  _"defs" {
    _"marker" {
      id = "triangle";
      viewBox = space_separated { 0, 0, 4, 2 };
      refX = 4;
      refY = 1;
      markerWidth = 8;
      markerHeight = 8;
      orient = "auto";
      _"path" {
        d = path_data():M(0,0):L(0,2):L(4,1):Z();
        fill = colors.black;
        stroke = "none";
      };
    }
  };
}

local eid = g.e.first
while eid do
  local uid = g.vu.target[eid]
  local vid = g.uv.target[eid]
  local x1 = calc_x(x[uid])
  local y1 = calc_y(layer_map[uid])
  local x2 = calc_x(x[vid])
  local y2 = calc_y(layer_map[vid])
  svg[#svg + 1] = _"line" {
    x1 = x1;
    y1 = y1;
    x2 = x2;
    y2 = y2;
    stroke = colors.black;
    ["marker-end"] = "url(#triangle)";
  }
  eid = g.e.after[eid]
end

local uid = g.u.first
while uid do
  local cx = calc_x(x[uid])
  local cy = calc_y(layer_map[uid])
  if uid < dummy_min then
    svg[#svg + 1] = _"circle" {
      cx = cx;
      cy = cy;
      r = 2;
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
      r = 2;
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
