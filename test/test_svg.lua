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

local widths = {
  ["N"]  = 1; -- neutral
  ["Na"] = 1; -- narrow
  ["H"]  = 1; -- halfwidth
  ["A"]  = 2; -- ambiguous
  ["W"]  = 2; -- wide
  ["F"]  = 2; -- fullwidth
}

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

--
-- parameters
--

local transform = vecmath.matrix3(100, 0, 50, 0, 100, 50, 0, 0, 1)

local x, y, reversed_eids = layout(g)
local view_size = transform:transform(vecmath.vector2(x.max + 1, y.max + 1))

local font_size = 15
local text_length = 60

--
-- svg
--

local function text_width(s)
  local width = 0
  for _, c in utf8.codes(s) do
    width = width + widths[east_asian_width(c)]
  end
  return width
end

local _ = dom.element

local vertices = _"g" {}
local edges = _"g" {}

local uid = g.u.first
while uid do
  if uid <= last_uid then
    local name = uid_to_name[uid]
    if not name then
      name = tostring(uid)
    end
    local p = vecmath.point2(x[uid], y[uid])
    transform:transform(p)

    local text = _"text" {
      x = p.x;
      y = p.y;
      name;
      ["text-anchor"] = "middle";
      ["dominant-baseline"] = "central";
    }

    local shape = _"rect" {
      x = p.x - text_length / 2 - font_size / 2;
      y = p.y - font_size * 2 / 2;
      width = text_length + font_size;
      height = font_size * 2;
      rx = font_size * 2 / 2;
      ry = font_size * 2 / 2;
      fill = "none";
      stroke = "#333";
    }

    local width = text_width(name) * font_size / 2
    if width >= text_length then
      text.textLength = text_length
      text.lengthAdjust = "spacingAndGlyphs"
    end

    vertices[#vertices + 1] = text
    vertices[#vertices + 1] = shape
  end
  uid = g.u.after[uid]
end

--
-- write svg
--

local style = [[
@font-face {
  font-family: 'Noto Sans Mono CJK JP';
  font-style: normal;
  font-weight: 400;
  src: url('https://dromozoa.s3.amazonaws.com/mirror/NotoSansCJKjp-2017-10-24/NotoSansMonoCJKjp-Regular.otf') format('opentype');
}
text {
  font-family: 'Noto Sans Mono CJK JP';
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
  };
  edges;
  vertices;
})
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
