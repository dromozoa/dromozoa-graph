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

--
-- load graph
--

local filename = ...
if not filename then
  filename = "docs/fsm.gv"
end

local name_to_uid = {}
local uid_to_name = {}
local eid_to_name = {}

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
      uid_to_name[uid] = uname
    end
    local vid = name_to_uid[vname]
    if not vid then
      vid = g:add_vertex()
      name_to_uid[vname] = vid
      uid_to_name[vid] = vname
    end
    local eid = g:add_edge(uid, vid)
    eid_to_name[eid] = line:match [[label%s*=%s*"(.-)"]]
  end
end

local last_uid = g.u.last
local last_eid = g.e.last
local revered_eids = {}

local eid = g.e.first
while eid do
  local uid = g.vu.target[eid]
  local vid = g.uv.target[eid]
  if uid == vid then
    local new_eid = g:subdivide_edge(eid, g:add_vertex())
    g:reverse_edge(new_eid)
    revered_eids[#revered_eids + 1] = new_eid
  else
    local name = eid_to_name[eid]
    if name then
      g:subdivide_edge(eid, g:add_vertex())
    end
  end
  if eid == last_eid then
    break
  end
  eid = g.e.after[eid]
end

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

--
-- svg
--

local widths = {
  ["N"]  = 0.5; -- neutral
  ["Na"] = 0.5; -- narrow
  ["H"]  = 0.5; -- halfwidth
  ["A"]  = 0.75; -- ambiguous
  ["W"]  = 1; -- wide
  ["F"]  = 1; -- fullwidth
}

local function make_text(p, text, font_size, max_text_length)
  local text_length = 0
  for _, c in utf8.codes(text) do
    text_length = text_length + widths[east_asian_width(c)]
  end
  text_length = text_length * font_size
  if text_length > max_text_length then
    text_length = max_text_length
  end
  return dom.element "text" {
    x = p[1];
    y = p[2];
    ["font-size"] = font_size;
    ["text-anchor"] = "middle";
    ["dominant-baseline"] = "central";
    textLength = text_length;
    lengthAdjust = "spacingAndGlyphs";
    text;
  }
end

local function make_rect(p, u, r)
  return dom.element "path" {
    d = svg.path_data():rect(p, u, r);
  }
end

local function make_ellipse(p, r)
  return dom.element "path" {
    d = svg.path_data():ellipse(p, r);
  }
end

local _ = dom.element

local vertices = _"g" {}
local edges = _"g" {}

local uid_to_shape = {}

local uid = g.u.first
while uid do
  if uid <= last_uid then
    local name = uid_to_name[uid]
    if not name then
      name = tostring(uid)
    end
    local p = vecmath.point2(x[uid], y[uid])
    transform:transform(p)

    local text = make_text(p, name, font_size, max_text_length)
    text.fill = "#333"

    local v = font_size * (line_height - 1) / 2
    local u = vecmath.vector2(text.textLength / 2 + v, font_size / 2 + v)
    local r = vecmath.vector2(v, v)
    local shape = make_rect(p, u, r)
    shape.fill = "none"
    shape.stroke = "#333"

    uid_to_shape[uid] = shape
    vertices[#vertices + 1] = _"g" {
      shape;
      text;
    }
  end
  uid = g.u.after[uid]
end

local eid = g.e.first
while eid do
  if eid <= last_eid then
    local path_eids = paths[eid]

    local uid = g.vu.target[path_eids[1]]

    local path_beziers = {}
    local n = #path_eids
    for i = 1, n do
      local eid = path_eids[i]
      local uid = g.vu.target[eid]
      local vid = g.uv.target[eid]
      local p1 = transform:transform(vecmath.point2(x[uid], y[uid]))
      local p2 = transform:transform(vecmath.point2(x[vid], y[vid]))
      local p3 = vecmath.point2(p1):add(p2):scale(0.5)
      if i == 1 then
        path_beziers[#path_beziers + 1] = vecmath.bezier(p1, p3)
      end
      if i == n then
        path_beziers[#path_beziers + 1] = vecmath.bezier(p2, p3)
      else
        local wid = g.uv.target[path_eids[i + 1]]
        local p4 = transform:transform(vecmath.point2(x[wid], y[wid]))
        local p5 = vecmath.point2(p2):add(p4):scale(0.5)
        path_beziers[#path_beziers + 1] = vecmath.bezier(p3, p2, p5)
      end
    end

    local uid = g.vu.target[path_eids[1]]
    local vid = g.uv.target[path_eids[#path_eids]]

    local ushape = uid_to_shape[uid]
    local ub = ushape.d:bezier({})
    local b1 = path_beziers[1]
    for i = 1, #ub do
      local b2 = ub[i]
      local r = vecmath.bezier_clipping(b1, b2)
      local t = r[1][1]
      if t then
        b1:clip(t, 1)
        break
      end
    end

    local vshape = uid_to_shape[vid]
    local vb = vshape.d:bezier({})
    local b1 = path_beziers[#path_beziers]
    for i = 1, #vb do
      local b2 = vb[i]
      local r = vecmath.bezier_clipping(b1, b2)
      local t = r[1][1]
      if t then
        b1:clip(0, t)
        break
      end
    end

    local pd = svg.path_data()

    local b = path_beziers[1]
    pd:M(b:get(1, vecmath.point2()))
    for i = 1, #path_beziers do
      local b = path_beziers[i]
      if b:size() == 2 then
        pd:L(b:get(2, vecmath.point2()))
      elseif b:size() == 3 then
        pd:Q(
            b:get(2, vecmath.point2()),
            b:get(3, vecmath.point2()))
      elseif b:size() == 4 then
        pd:C(
            b:get(2, vecmath.point2()),
            b:get(3, vecmath.point2()),
            b:get(4, vecmath.point2()))
      end
    end

    edges[#edges + 1] = _"path" {
      d = pd;
      fill = "none";
      stroke = "#333";
      ["marker-end"] = "url(#arrow)";
    }

    local name = eid_to_name[eid]
    if name then
      local m = n / 2
      m = m - m % 1
      local eid = path_eids[m]
      local vid = g.uv.target[eid]
      local p = transform:transform(vecmath.point2(x[vid], y[vid]))
      local text = make_text(p, name, font_size, max_text_length)
      text.fill = "#333"
      edges[#edges + 1] = text
    end
  end

  eid = g.e.after[eid]
end

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
  edges;
  vertices;
})
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
