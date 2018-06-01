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
local color4d = require "dromozoa.css.color4d"
local colors = require "dromozoa.css.colors"
local path_data = require "dromozoa.svg.path_data"

local graph = require "dromozoa.graph"
local layout = require "dromozoa.graph.layout"

local g = graph()

local utexts = {}
local function add_vertex(utext)
  local uid = g:add_vertex()
  utexts[uid] = utext
  return uid
end

local u0 = add_vertex("LR_0")
local u1 = add_vertex("LR_1")
local u2 = add_vertex("LR_2")
local u3 = add_vertex("LR_3")
local u4 = add_vertex("LR_4")
local u5 = add_vertex("LR_5")
local u6 = add_vertex("LR_6")
local u7 = add_vertex("LR_7")
local u8 = add_vertex("LR_8")

local etexts = {}
local function add_edge(uid, vid, etext)
  local eid = g:add_edge(uid, vid)
  etexts[eid] = etext
  return eid
end

add_edge(u0, u2, "SS(B)")
add_edge(u0, u1, "SS(S)")
add_edge(u1, u3, "S($end)")
add_edge(u2, u6, "SS(b)")
add_edge(u2, u5, "SS(a)")
add_edge(u2, u4, "S(A)")
add_edge(u5, u7, "S(b)")
add_edge(u5, u5, "S(a)")
add_edge(u6, u6, "S(b)")
add_edge(u6, u5, "S(a)")
add_edge(u7, u8, "S(b)")
add_edge(u7, u5, "S(a)")
add_edge(u8, u6, "S(b)")
add_edge(u8, u5, "S(a)")

local dummy_uid, x, y = layout(g)

-- local edges = {}
-- local eid = g.e.first
-- while eid do
--   eid = g.e.after[eid]
-- end

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
  if uid == vid then
--    local x = calc_x(x[uid])
--    local y = calc_y(y[uid])
--    svg[#svg + 1] = _"path" {
--      d = path_data():M(x, y):A(10, 10, 0, 0, 0, x + 20, y):A(10, 10, 0, 0, 0, x, y);
--      stroke = colors.black;
--      fill = "none";
--      ["marker-end"] = "url(#triangle)";
--    }
  else
    local x1 = calc_x(x[uid])
    local y1 = calc_y(y[uid])
    local x2 = calc_x(x[vid])
    local y2 = calc_y(y[vid])
    local x3 = (x1 + x2) * 0.5
    local y3 = (y1 + y2) * 0.5
    svg[#svg + 1] = _"line" {
      x1 = x1;
      y1 = y1;
      x2 = x2;
      y2 = y2;
      stroke = colors.black;
      fill = "none";
      ["marker-end"] = "url(#triangle)";
    }
    --[[
    svg[#svg + 1] = _"path" {
      d = path_data():M(x1, y1):Q(x1, y3, x3, y3):Q(x2, y3, x2, y2);
      stroke = colors.black;
      fill = "none";
      ["marker-end"] = "url(#triangle)";
    }
    ]]
  end
  eid = g.e.after[eid]
end

local uid = g.u.first
while uid do
  local cx = calc_x(x[uid])
  local cy = calc_y(y[uid])
  if uid < dummy_uid then
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
