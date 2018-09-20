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

local x, y, reversed_eids = layout(g)

-- self edge
-- multi edge
-- labelled edge
-- label vertex

--
-- parameters
--

local transform = vecmath.matrix3(100, 0, 50, 0, 100, 50, 0, 0, 1)
local view_size = transform:transform(vecmath.vector2(x.max + 1, y.max + 1))

local font_size = 15
local line_height = 2
local max_text_length = 75

-- shape type

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

local reversed = {}
for i = 1, #reversed_eids do
  reversed[reversed_eids[i]] = true
end

local eid = g.e.first
while eid do
  if eid <= last_eid then
    local uid = g.vu.target[eid]
    local vid = g.uv.target[eid]
    if uid ~= vid then

      local is_multi = false
      local eid2 = g.uv.first[vid]
      while eid2 do
        local uid2 = g.uv.target[eid2]
        if uid2 == uid then
          is_multi = true
          break
        end
        eid2 = g.uv.after[eid2]
      end

      local path_points = {}
      if is_multi then
        local px = x[uid]
        local py = y[uid]
        local qx = x[vid]
        local qy = y[vid]

        local u = vecmath.vector2()
        if py < qy then
          u = vecmath.vector2(0.25, 0)
        else
          u = vecmath.vector2(-0.25, 0)
        end

        local p1 = vecmath.point2(px, py)
        local p3 = vecmath.point2(qx, qy)
        local p2 = vecmath.point2(p1):add(p3):scale(0.5):add(u)

        path_points[1] = transform:transform(p1)
        path_points[2] = transform:transform(p2)
        path_points[3] = transform:transform(p3)
      else
        local path = {}
        if reversed[eid] then
          path[1] = vid
          path[2] = uid
          local n = 2
          while uid > last_uid do
            n = n + 1
            uid = g.vu.target[g.vu.first[uid]]
            path[n] = uid
          end
          local m = n + 1
          for i = 1, n / 2 do
            local j = m - i
            path[i], path[j] = path[j], path[i]
          end
        else
          path[1] = uid
          path[2] = vid
          local n = 2
          while vid > last_uid do
            n = n + 1
            vid = g.uv.target[g.uv.first[vid]]
            path[n] = vid
          end
        end
        for i = 1, #path do
          local uid = path[i]
          path_points[i] = transform:transform(vecmath.point2(x[uid], y[uid]))
        end
      end

      local path_beziers = {}
      local p = path_points[1]
      for i = 2, #path_points do
        local q = path_points[i]
        path_beziers[i - 1] = vecmath.bezier(p, q)
        p = q
      end

      local ub = uid_to_shape[uid].d:bezier({})
      local vb = uid_to_shape[vid].d:bezier({})

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
      pd:M(b:get(1, vecmath.point2())):L(b:get(2, vecmath.point2()))
      for i = 2, #path_beziers do
        local b = path_beziers[i]
        pd:L(b:get(2, vecmath.point2()))
      end

      edges[#edges + 1] = _"path" {
        d = pd;
        fill = "none";
        stroke = "#333";
        ["marker-end"] = "url(#arrow)";
      }
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
