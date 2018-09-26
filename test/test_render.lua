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

local dom = require "dromozoa.dom"
local svg = require "dromozoa.svg"
local vecmath = require "dromozoa.vecmath"
local utf8 = require "dromozoa.utf8"
local east_asian_width = require "dromozoa.ucd.east_asian_width"
local graph = require "dromozoa.graph"

local g = graph()
local layout = require "dromozoa.graph.layout"
local render = require "dromozoa.graph.render"
local subdivide_special_edges = require "dromozoa.graph.subdivide_special_edges"

local _ = dom.element

--
-- load graph
--

local filename = ...
if not filename then
  filename = "docs/fsm.gv"
end

local name_to_uid = {}
local u_labels = {}
local e_labels = {}

for line in io.lines(filename) do
  local uname, vname = line:match [[^%s*"(.-)"%s*%->%s*"(.-)"]]
  if not uname then
    uname, vname = line:match [[^%s*([^%s;]*)%s*%->%s*([^%s;]*)]]
  end
  if uname then
    local uid = name_to_uid[uname]
    if not uid then
      uid = g:add_vertex()
      name_to_uid[uname] = uid
      u_labels[uid] = uname
    end
    local vid = name_to_uid[vname]
    if not vid then
      vid = g:add_vertex()
      name_to_uid[vname] = vid
      u_labels[vid] = vname
    end
    local eid = g:add_edge(uid, vid)
    e_labels[eid] = line:match [[label%s*=%s*"(.-)"]]
  end
end

local last_uid = g.u.last
local last_eid = g.e.last
local revered_eids = subdivide_special_edges(g, e_labels)
local x, y, paths = layout(g, last_uid, last_eid, revered_eids)

--
-- parameters
--

local transform = vecmath.matrix3(100, 0, 50, 0, 100, 50, 0, 0, 1)
-- local transform = vecmath.matrix3(0, 200, 50, 75, 0, 50, 0, 0, 1)
local view_size = transform:transform(vecmath.vector2(x.max + 1, y.max + 1))

local font_size = 15
local line_height = 2
local max_text_length = 75

local node = render(g, last_uid, last_eid, x, y, paths, {
  matrix = transform;
  u_labels = u_labels;
  e_labels = e_labels;
  font_size = font_size;
  line_height = line_height;
  max_text_length = max_text_length;
  curve_parameter = 1;
})

--
-- write svg
--

local style = [[
/*
@font-face {
  font-family: 'Noto Sans Mono CJK JP';
  font-style: normal;
  font-weight: 400;
  src: url('https://dromozoa.s3.amazonaws.com/mirror/NotoSansCJKjp-2017-10-24/NotoSansMonoCJKjp-Regular.otf') format('opentype');
}
text {
  font-family: 'Noto Sans Mono CJK JP';
}
*/
@import url('https://fonts.googleapis.com/css?family=Noto+Sans+JP:100&subset=japanese');
text {
  font-family: 'Noto Sans JP';
  font-size: 15;
  text-anchor: middle;
  dominant-baseline: central;
  lengthAdjust: spacingAndGlyphs;
  fill: #333;
  stroke: none;
}
.u_paths path {
  fill: none;
  stroke: #333;
}
.e_paths path {
  fill: none;
  stroke: #333;
  marker-end: url(#arrow);
}
]]

local doc = dom.xml_document(_"svg" {
  version = "1.1";
  xmlns = "http://www.w3.org/2000/svg";
  width = view_size.x;
  height = view_size.y;
  _"defs" {
    _"style" {
      type = "text/css";
      style;
    };
    _"marker" {
      id = "arrow";
      viewBox = "0 0 4 4";
      refX = 4;
      refY = 2;
      markerWidth = 8;
      markerHeight = 8;
      orient = "auto";
      _"path" {
        d = svg.path_data():M(0,0):L(0,4):L(4,2):Z();
      };
    };
  };
  node;
  -- edge_paths;
  -- edge_labels;
  -- vertex_paths;
  -- vertex_labels;
})
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
