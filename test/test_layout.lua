-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local color3f = require "dromozoa.vecmath.color3f"
local point2 = require "dromozoa.vecmath.point2"
local vector2 = require "dromozoa.vecmath.vector2"

local path_data = require "dromozoa.svg.path_data"

local graph = require "dromozoa.graph"
local layout = require "dromozoa.graph.layout"

local g = graph()
for i = 1, 8 do
  g:add_vertex()
end
g:add_edge(1, 1)
g:add_edge(1, 2)
g:add_edge(1, 5)

-- g:add_edge(1, 6)
g:add_edge(6, 1)

g:add_edge(2, 3)
g:add_edge(3, 4)
g:add_edge(4, 8)
g:add_edge(4, 8)
g:add_edge(5, 7)

g:add_edge(6, 7)
-- g:add_edge(7, 6)

g:add_edge(7, 8)

local last_uid = g.u.last
local x, y = layout(g)
local width = (x.max + 1) * 50
local height = (y.max + 1) * 50

local function calc_x(x)
  return x * 50 + 25
end

local function calc_y(y)
  return y * 50 + 25
end

local _ = element
local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  version = "1.1";
  width = width;
  height = height;
  _"defs" {
    _"marker" {
      id = "triangle";
      viewBox = space_separated { 0, 0, 4, 4 };
      refX = 4;
      refY = 2;
      markerWidth = 8;
      markerHeight = 8;
      orient = "auto";
      _"path" {
        d = path_data():M(0,0):L(0,4):L(4,2):Z();
        fill = "black";
        stroke = "none";
      };
    }
  };
}

local eid = g.e.first
while eid do
  local uid = g.vu.target[eid]
  local vid = g.uv.target[eid]
  if uid == vid then
    local p1 = point2(calc_x(x[uid]), calc_y(y[uid]))
    local x = 25
    local y = 10
    local p2 = point2(p1):add{x,-y}
    local p3 = point2(p1):add{2*x,0}
    local p4 = point2(p1):add{x,y}
    local p5 = point2(p1):add(vector2(x,y):normalize():scale(10))
    p1:add(vector2(x,-y):normalize():scale(10))
    svg[#svg + 1] = _"path" {
      d = path_data():M(p1):L(p2):L(p3):L(p4):L(p5);
      stroke = "black";
      fill = "none";
      ["marker-end"] = "url(#triangle)";
    }
  else
    local p = point2(calc_x(x[uid]), calc_y(y[uid]))
    local q = point2(calc_x(x[vid]), calc_y(y[vid]))
    local v = vector2():sub(q, p):normalize():scale(10)
    p:add(v)
    q:sub(v)
    svg[#svg + 1] = _"path" {
      d = path_data():M(p):L(q);
      stroke = "black";
      fill = "none";
      ["marker-end"] = "url(#triangle)";
    }
  end
  eid = g.e.after[eid]
end

local uid = g.u.first
while uid do
  local cx = calc_x(x[uid])
  local cy = calc_y(y[uid])

  local shape_fill
  local shape_stroke
  local text_fill
  if uid <= last_uid then
    shape_fill = color3f()
    shape_stroke = color3f()
    text_fill = color3f "white"
  else
    shape_fill = color3f "white"
    shape_stroke = color3f()
    text_fill = color3f(0.5, 0.5, 0.5)
  end
  local text_length
  local length_adjust
  if uid >= 10 then
    text_length = 12
    length_adjust = "spacingAndGlyphs"
  end

  svg[#svg + 1] = _"circle" {
    cx = cx;
    cy = cy;
    r = 10;
    fill = shape_fill;
    stroke = shape_stroke;
  }

  svg[#svg + 1] = _"text" {
    x = cx;
    y = cy;
    fill = text_fill;
    ["font-size"] = 12;
    ["text-anchor"] = "middle";
    ["dominant-baseline"] = "central";
    textLength = text_length;
    lengthAdjust = length_adjust;
    uid;
  }

  uid = g.u.after[uid]
end

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
