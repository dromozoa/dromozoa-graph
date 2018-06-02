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
  return (x + 0.5) * unit, (y + 0.5) * unit
end

local width, height = transform(x_map.max + 0.5, y_map.max + 0.5)

local _ = element
local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  version = "1.1";
  width = width;
  height = height;
  _"defs" {
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
  };
}

local eid = g.e.first
while eid do
  if eid <= last_eid then
    local path = paths[eid]
    local uids = path.uids
    local eids = path.eids

    local n = #uids
    local uid = uids[1]
    if uid == uids[2] then
    else
      local points = { { transform(x_map[uid], y_map[uid]) } }
      for i = 2, n - 1 do
        local uid = uids[i]
        points[#points + 1] = { transform(x_map[uid], y_map[uid]) }
      end
      local uid = uids[n - 1]
      local vid = uids[n]
      local x1, y1 = transform(x_map[uid], y_map[uid])
      local x2, y2 = transform(x_map[vid], y_map[vid])
      local dx = x2 - x1
      local dy = y2 - y1
      local d = math.sqrt(dx * dx + dy * dy)
      local s = (d - r) / d
      points[#points + 1] = { x1 + dx * s, y1 + dy * s }

      local m = #points
      local d
      if m == 2 then
        d = path_data():M(unpack(points[1])):L(unpack(points[2]))
      else
        d = path_data():M(unpack(points[1]))
        for i = 1, m - 1 do
          local p = {
            points[i - 1];
            points[i];
            points[i + 1];
            points[i + 2];
          }
          if i == 1 then
            p[1] = points[1]
          end
          if i == m - 1 then
            p[4] = points[m]
          end
          if i == m then
            p[3] = points[m]
            p[4] = points[m]
          end
          local v = 8
          local x1 = (-p[1][1] + p[2][1] * v + p[3][1]) / v
          local y1 = (-p[1][2] + p[2][2] * v + p[3][2]) / v
          local x2 = (p[2][1] + p[3][1] * v - p[4][1]) / v
          local y2 = (p[2][2] + p[3][2] * v - p[4][2]) / v
          d:C(x1, y1, x2, y2, unpack(p[3]))
        end

        -- d = path_data():M(unpack(points[1]))
        -- for i = 2, m - 1 do
        --   local x1, y1 = unpack(points[i - 1])
        --   local x2, y2 = unpack(points[i])
        --   local x3, y3 = unpack(points[i + 1])

        --   local a = 0.5
        --   local b = 1 - a

        --   local ax = x1 * b + x2 * a
        --   local ay = y1 * b + y2 * a
        --   local bx = x2 * a + x3 * b
        --   local by = y2 * a + y3 * b
        --   d:L(ax, ay):L(bx, by)
        -- end
        -- d:L(unpack(points[m]))
      end

      svg[#svg + 1] = _"path" {
        d = d;
        stroke = colors.black;
        ["stroke-width"] = 1;
        fill = "none";
        ["marker-end"] = "url(#triangle)";
      }
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
      fill = colors.white;
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
