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
local x_map, y_map = layout(g)

local paths = {}

local eid = g.e.first
while eid do
  if eid <= last_eid then
    local eid = eid
    local uid = g.vu.target[eid]
    while uid > last_uid do
      eid = g.vu.first[uid]
      uid = g.vu.target[eid]
    end
    local vid = g.uv.target[eid]

    local eids = { eid }
    local uids = { uid, vid }
    local path = {
      eids = eids;
      uids = uids;
    }
    paths[eid] = path

    while vid > last_uid do
      eid = g.uv.first[vid]
      vid = g.uv.target[eid]
      eids[#eids + 1] = eid
      uids[#uids + 1] = vid
      paths[eid] = path
    end
  end
  eid = g.e.after[eid]
end

local unit = 100
local r = 20

local function transform(x, y)
  -- return (x + 0.5) * unit, (y + 0.5) * unit
  return (y + 0.5) * unit, (x + 0.5) * unit
  -- return (y + 0.5) * unit, (x + 0.5) * unit * 0.75
end

local width, height = transform(x_map.max + 0.5, y_map.max + 0.5)

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
  local x1 = p1[1]
  local y1 = p1[2]
  local x2 = p2[1]
  local y2 = p2[2]
  local dx = x2 - x1
  local dy = y2 - y1
  local d = math.sqrt(dx * dx + dy * dy)
  local s = (d - r) / d
  return x2 - dx * s, y2 - dy * s
end

local function move_last_point(p1, p2)
  local x1 = p1[1]
  local y1 = p1[2]
  local x2 = p2[1]
  local y2 = p2[2]
  local dx = x2 - x1
  local dy = y2 - y1
  local d = math.sqrt(dx * dx + dy * dy)
  local s = (d - r) / d
  return x1 + dx * s, y1 + dy * s
end

local eid = g.e.first
while eid do
  if eid <= last_eid then
    local path = paths[eid]
    local uids = path.uids
    local eids = path.eids

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
        points[#points + 1] = { x_map[uid], y_map[uid] }
      end

      local d = path_data()
      local m = #points
      if m == 2 then
        local p1 = { transform(unpack(points[1])) }
        local p2 = { transform(unpack(points[2])) }
        d:M(move_first_point(p1, p2)):L(move_last_point(p1, p2))
      else
        local a = 0.5
        local b = 1 - a

        local p1 = { transform(unpack(points[1])) }
        local p2 = { transform(unpack(points[2])) }
        d:M(move_first_point(p1, p2))

        local x1, y1 = unpack(points[1])
        local x2, y2 = unpack(points[2])
        local ax, ay = transform(x1 * a + x2 * b, y1 * a + y2 * b, x2)
        local bx, by = transform(x2, y1 * b + y2 * a)
        d:C(ax, ay, bx, by, transform(x2, y2))

        for i = 2, m - 1 do
          d:L(transform(unpack(points[i])))
        end

        local p1 = { transform(unpack(points[m - 1])) }
        local p2 = { transform(unpack(points[m])) }
        local x1, y1 = unpack(points[m - 1])
        local x2, y2 = unpack(points[m])
        local ax, ay = transform(x1, y1 * a + y2 * b)
        local bx, by = transform(x1 * b + x2 * a, y1 * b + y2 * a)
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
