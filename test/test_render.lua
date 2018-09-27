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
local graph = require "dromozoa.graph"

local _ = dom.element
local g = graph()

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

local node, size = g:render {
  -- matrix = vecmath.matrix3(100, 0, 50, 0, 100, 50, 0, 0, 1);
  matrix = vecmath.matrix3(0, 80, 50, 50, 0, 25, 0, 0, 1);
  u_labels = u_labels;
  e_labels = e_labels;
  max_text_length = 72;
  curve_parameter = 1;
}

local style = [[
@import url('https://fonts.googleapis.com/css?family=Noto+Sans+JP:100&subset=japanese');
text {
  font-family: 'Noto Sans JP';
}

text {
  font-size: 16;
  text-anchor: middle;
  dominant-baseline: central;
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
  marker-end: url('#arrow');
}
]]

local doc = dom.xml_document(_"svg" {
  version = "1.1";
  xmlns = "http://www.w3.org/2000/svg";
  width = size.x;
  height = size.y;
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
})

local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
