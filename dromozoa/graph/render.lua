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
local east_asian_width = require "dromozoa.ucd.east_asian_width"
local utf8 = require "dromozoa.utf8"
local path_data = require "dromozoa.svg.path_data"
local matrix3 = require "dromozoa.vecmath.matrix3"
local point2 = require "dromozoa.vecmath.point2"
local bezier = require "dromozoa.vecmath.bezier"
local bezier_clipping = require "dromozoa.vecmath.bezier_clipping"

local widths = {
  ["N"]  = 0.5;  -- neutral
  ["Na"] = 0.5;  -- narrow
  ["H"]  = 0.5;  -- halfwidth
  ["A"]  = 0.75; -- ambiguous
  ["W"]  = 1;    -- wide
  ["F"]  = 1;    -- fullwidth
}

local function make_text(p, text, font_size, max_text_length)
  local text_length = 0
  for _, c in utf8.codes(text) do
    text_length = text_length + widths[east_asian_width(c)]
  end
  text_length = text_length * font_size

  local length_adjust
  if text_length < font_size then
    text_length = font_size
  elseif text_length > max_text_length then
    text_length = max_text_length
    length_adjust = "spacingAndGlyphs"
  end

  return element "text" {
    x = p[1];
    y = p[2];
    textLength = text_length;
    lengthAdjust = length_adjust;
    text;
  }
end

local function clip_path(u_path_beziers, v_path_beziers, e_path_beziers)
  local first = 1
  local last = #e_path_beziers

  for i = 1, last do
    local eb = e_path_beziers[i]
    for j = 1, #u_path_beziers do
      local ub = u_path_beziers[j]
      local r = bezier_clipping(eb, ub)
      local t = r[1][1]
      if t then
        eb:clip(t, 1)
        eb = nil
        break
      end
    end
    if not eb then
      first = i
      break
    end
    e_path_beziers[i] = nil
  end

  for i = last, first, -1 do
    local eb = e_path_beziers[i]
    for j = 1, #v_path_beziers do
      local vb = v_path_beziers[j]
      local r = bezier_clipping(eb, vb)
      local t = r[1][1]
      if t then
        eb:clip(0, t)
        eb = nil
        break
      end
    end
    if not eb then
      last = i
      break
    end
    e_path_beziers[i] = nil
  end

  return first, last
end

return function (g, last_uid, last_eid, x, y, paths, attrs)
  local matrix = attrs.matrix or matrix3(100, 0, 50, 0, 100, 50, 0, 0, 1)
  local u_labels = attrs.u_labels
  local e_labels = attrs.e_labels
  local font_size = attrs.font_size or 16
  local line_height = attrs.line_height or 1.5
  local max_text_length = attrs.max_text_length or 80
  local curve_parameter = attrs.curve_parameter or 1

  local font_hs = font_size / 2
  local rect_r = font_hs * (line_height - 1)
  local rect_hh = font_hs + rect_r
  local curve_a = curve_parameter / 2
  if curve_a < 0 then
    curve_a = 0
  elseif curve_a > 0.5 then
    curve_a = 0.5
  end

  local u = g.u
  local u_after = u.after
  local e = g.e
  local e_after = e.after
  local uv_target = g.uv.target
  local vu_target = g.vu.target

  local u_beziers = {}
  local u_paths = element "g" { class = "u_paths" }
  local u_texts = element "g" { class = "u_texts" }
  local e_paths = element "g" { class = "e_paths" }
  local e_texts = element "g" { class = "e_texts" }

  local p1 = point2()
  local p2 = point2()
  local p3 = point2()
  local p4 = point2()

  local uid = u.first
  while uid do
    if uid <= last_uid then
      local label = u_labels and u_labels[uid] or tostring(uid)
      matrix:transform(p1:set(x[uid], y[uid]))
      local text = make_text(p1, label, font_size, max_text_length)
      text["data-uid"] = uid
      local d = path_data():rect(p1[1], p1[2], text.textLength / 2 + rect_r, rect_hh, rect_r, rect_r)
      u_beziers[uid] = d:bezier {}
      u_paths[#u_paths + 1] = element "path" { d = d, ["data-uid"] = uid }
      u_texts[#u_texts + 1] = text
    end
    uid = u_after[uid]
  end

  local eid = e.first
  while eid do
    if eid <= last_eid then
      local path_eids = paths[eid]
      local path_eid = path_eids[1]
      local uid = vu_target[path_eid]
      local vid = uv_target[path_eid]
      local m = #path_eids

      matrix:transform(p2:set(x[uid], y[uid]))
      matrix:transform(p3:set(x[vid], y[vid]))

      local path_beziers = {}
      local n = 0
      if curve_a == 0 then
        n = n + 1
        path_beziers[n] = bezier(p2, p3)
        for i = 2, m do
          p2, p3 = p3, p2
          local vid = uv_target[path_eids[i]]
          matrix:transform(p3:set(x[vid], y[vid]))
          n = n + 1
          path_beziers[n] = bezier(p2, p3)
        end
      else
        p1:interpolate(p3, p2, curve_a)
        n = n + 1
        path_beziers[n] = bezier(p2, p1)
        for i = 2, m do
          p2, p3 = p3, p2
          local vid = uv_target[path_eids[i]]
          matrix:transform(p3:set(x[vid], y[vid]))
          p4:interpolate(p2, p3, curve_a)
          n = n + 1
          path_beziers[n] = bezier(p1, p2, p4)
          if curve_a == 0.5 then
            p1, p4 = p4, p1
          else
            p1:interpolate(p3, p2, curve_a)
            n = n + 1
            path_beziers[n] = bezier(p4, p1)
          end
        end
        n = n + 1
        path_beziers[n] = bezier(p1, p3)
      end

      local first, last = clip_path(u_beziers[uid], u_beziers[uv_target[path_eids[m]]], path_beziers)
      local b = path_beziers[first]
      local d = path_data():M(b:get(1, p1))
      for i = first, last do
        local b = path_beziers[i]
        if b:size() == 2 then
          d:L(b:get(2, p1))
        else
          d:Q(b:get(2, p1), b:get(3, p2))
        end
      end
      e_paths[#e_paths + 1] = element "path" { d = d, ["data-eid"] = eid }

      local label = e_labels and e_labels[eid]
      if label then
        local i = m / 2
        local uid = vu_target[path_eids[i - i % 1 + 1]]
        matrix:transform(p1:set(x[uid], y[uid]))
        local text = make_text(p1, label, font_size, max_text_length)
        text["data-eid"] = eid
        e_texts[#e_texts + 1] = text
      end
    end
    eid = e_after[eid]
  end

  return element "g" { u_paths, u_texts, e_paths, e_texts }, matrix
end
