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
local vecmath = require "dromozoa.vecmath"

local graph = require "dromozoa.graph"
local layout = require "dromozoa.graph.layout"

local unpack = table.unpack or unpack

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

local last_uid = g.u.last
local last_eid = g.e.last
local x_map, y_map, reversed_eids = layout(g)

local reversed = {}
for i = 1, #reversed_eids do
  reversed[reversed_eids[i]] = true
end

local paths = {}

local eid = g.e.first
while eid do
  if eid <= last_eid then
    local uid = g.vu.target[eid]
    local vid = g.uv.target[eid]
    if reversed[eid] then
      local uids = { vid, uid }
      while uid > last_uid do
        uid = g.vu.target[g.vu.first[uid]]
        uids[#uids + 1] = uid
      end
      local n = #uids
      for i = 1, n / 2 do
        local j = n - i + 1
        uids[i], uids[j] = uids[j], uids[i]
      end
      paths[eid] = {
        reversed = true;
        uids = uids;
      }
    else
      local uids = { uid, vid }
      while vid > last_uid do
        vid = g.uv.target[g.uv.first[vid]]
        uids[#uids + 1] = vid
      end
      paths[eid] = {
        uids = uids;
      }
    end
  end
  eid = g.e.after[eid]
end

local unit = 100
local r = 20

local x_max = x_map.max
local y_max = y_map.max

--[[
  unit_x
  unit_y

  circle(r)
  rect(w,h,r)

  transform_matrix

  path_class
  text_class
]]

-- local transform_matrix = vecmath.matrix3(
--   unit, 0,    unit * 0.5,
--   0,    unit, unit * 0.5,
--   0,    0,    1
-- )

local transform_matrix = vecmath.matrix3(
   0,    unit, unit * 0.5,
  -unit, 0,    unit * (x_map.max + 0.5),
   0,    0,    1
)

local function transform(x, y)
  local p = vecmath.point3(x, y, 1)
  transform_matrix:transform(p)
  return p.x / p.z, p.y / p.z
end

local tl = vecmath.point3(-0.5, -0.5, 1)
local tr = vecmath.point3(-0.5, y_max + 0.5, 1)
local bl = vecmath.point3(x_max + 0.5, -0.5, 1)
local br = vecmath.point3(x_max + 0.5, y_max + 0.5, 1)

transform_matrix:transform(tl)
transform_matrix:transform(tr)
transform_matrix:transform(bl)
transform_matrix:transform(br)

local width = math.max(tl.x, tr.x, bl.x, br.x) - math.min(tl.x, tr.x, bl.x, br.x)
local height = math.max(tl.y, tr.y, bl.y, br.y) - math.min(tl.y, tr.y, bl.y, br.y)

local _ = element

local defs = _"defs" {
  _"marker" {
    id = "triangle";
    viewBox = space_separated { 0, 0, 7, 7 };
    refX = 7;
    refY = 3.5;
    markerWidth = 7;
    markerHeight = 7;
    orient = "auto";
    _"polygon" {
      points = space_separated { 0, 0, 7, 3, 7, 4, 0, 7 };
      fill = colors.black;
      stroke = "none";
    };
  }
}

local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  ["xmlns:xlink"] ="http://www.w3.org/1999/xlink";
  version = "1.1";
  width = width;
  height = height;
  defs;
}

local function move_first_point(p1, p2)
  local p1 = vecmath.point2(p1)
  local p2 = vecmath.point2(p2)
  local v = vecmath.vector2():sub(p2, p1)
  p1:add(v:normalize():scale(r))
  return p1.x, p1.y
end

local function move_last_point(p1, p2)
  local p1 = vecmath.point2(p1)
  local p2 = vecmath.point2(p2)
  local v = vecmath.vector2():sub(p1, p2)
  p2:add(v:normalize():scale(r))
  return p2.x, p2.y
end

local eid = g.e.first
while eid do
  if eid <= last_eid then
    local path = paths[eid]
    local uids = path.uids

    local uid = uids[1]
    if uid == uids[2] then
      local d = path_data()

      local x = x_map[uid]
      local y = y_map[uid]
      local p1 = { transform(x, y) }
      local p2 = { transform(x - 0.5, y - 0.075) }
      local p3 = { transform(x - 0.5, y + 0.075) }
      local p4 = { transform(x, y) }
      d:M(move_first_point(p1, p2))
      local x1, y1 = unpack(p2)
      local x2, y2 = unpack(p3)
      d:C(x1, y1, x2, y2, move_last_point(p3, p4))

      svg[#svg + 1] = _"path" {
        d = d;
        stroke = colors.black;
        ["stroke-width"] = 1;
        fill = "none";
        ["marker-end"] = "url(#triangle)";
      }

      local etext = etexts[eid]
      if etext then
        local p = { transform(x - 0.5 * 0.9, y) }
        svg[#svg + 1] = _"text" {
          x = p[1];
          y = p[2];
          ["font-size"] = 10;
          ["text-anchor"] = "middle";
          etext;
        }
      end
    else
      local points = {}
      for i = 1, #uids do
        local uid = uids[i]
        local p = vecmath.point3(x_map[uid], y_map[uid], 1)
        transform_matrix:transform(p)
        points[#points + 1] = vecmath.point2(p)
      end

      local a = 0.5
      local b = 1 - a
      local v = vecmath.vector3(0, b, 0)
      transform_matrix:transform(v)

      local d = path_data()
      local m = #points
      if m == 2 then
        local p1 = points[1]
        local p2 = points[2]
        d:M(move_first_point(p1, p2)):L(move_last_point(p1, p2))
      else
        local p1 = vecmath.point2(points[1])
        local p2 = vecmath.point2(points[2])
        d:M(move_first_point(p1, p2))

        local p1 = vecmath.point2(points[1])
        local p2 = vecmath.point2(points[2])
        local q1 = vecmath.point2():interpolate(p1, p2, b)

        local v1 = vecmath.vector2(v)
        if vecmath.vector2():sub(p2, p1):angle(v1) > math.pi * 0.5 then
          v1:negate()
        end
        local q2 = vecmath.point2():sub(p2, v1)

        local ax, ay = q1.x, q1.y
        local bx, by = q2.x, q2.y
        d:C(ax, ay, bx, by, p2.x, p2.y)

        for i = 2, m - 1 do
          d:L(unpack(points[i]))
        end

        local p1 = vecmath.point2(points[m - 1])
        local p2 = vecmath.point2(points[m])
        local q1 = vecmath.point2():interpolate(p1, p2, b)

        local v1 = vecmath.vector2(v)
        if vecmath.vector2():sub(p2, p1):angle(v1) > math.pi * 0.5 then
          v1:negate()
        end
        local q2 = vecmath.point2():add(p1, v1)

        local x1, y1 = unpack(points[m - 1])
        local x2, y2 = unpack(points[m])
        local ax, ay = q2.x, q2.y
        local bx, by = q1.x, q1.y
        d:C(ax, ay, bx, by, move_last_point(p1, p2))
      end

      defs[#defs + 1] = _"path" {
        id = "e" .. eid;
        d = d;
        stroke = colors.black;
        ["stroke-width"] = 1;
        fill = "none";
        ["marker-end"] = "url(#triangle)";
      }

      svg[#svg + 1] = _"use" {
        ["xlink:href"] = "#e" .. eid;
      }

      local etext = etexts[eid]
      if etext then
        svg[#svg + 1] = _"text" {
          ["font-size"] = 10;
          -- ["text-anchor"] = "middle";
          _"textPath" {
            ["xlink:href"] = "#e" .. eid;
            startOffset = "5%";
            _"tspan" {
              dy = -3;
              etext;
            };
          };
        }
      end
    end
  end
  eid = g.e.after[eid]
end

local uid = g.u.first
while uid do
  if uid <= last_uid then
    local cx, cy = transform(x_map[uid], y_map[uid])
    svg[#svg + 1] = _"circle" {
      cx = cx;
      cy = cy;
      r = r;
      stroke = colors.black;
      fill = "none"; -- colors.white;
    }
    svg[#svg + 1] = _"text" {
      x = cx;
      y = cy;
      fill = colors.black;
      ["font-size"] = 10;
      ["dominant-baseline"] = "middle";
      ["text-anchor"] = "middle";
      utexts[uid];
    }
  end
  uid = g.u.after[uid]
end

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
