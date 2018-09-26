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

local matrix3 = require "dromozoa.vecmath.matrix3"
local point2 = require "dromozoa.vecmath.point2"

local bezier = require "dromozoa.vecmath.bezier"
local bezier_clipping = require "dromozoa.vecmath.bezier_clipping"

local path_data = require "dromozoa.svg.path_data"

local _ = element

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
  if text_length > max_text_length then
    text_length = max_text_length
  end
  return _"text" {
    x = p[1];
    y = p[2];
    textLength = text_length;
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
  local u_labels = attrs.u_labels or {}
  local e_labels = attrs.e_labels or {}
  local font_size = attrs.font_size or 16
  local line_height = attrs.line_height or 1.5
  local max_text_length = attrs.max_text_length or 70
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

  local u_path_map = {}
  local u_paths = _"g" { class = "u_paths" }
  local u_texts = _"g" { class = "u_texts" }
  local e_paths = _"g" { class = "e_paths" }
  local e_texts = _"g" { class = "e_texts" }

  local uid = u.first
  while uid do
    if uid <= last_uid then
      local label = u_labels[uid]
      if not label then
        label = tostring(uid)
      end
      local p = matrix:transform(point2(x[uid], y[uid]))
      local text = make_text(p, label, font_size, max_text_length)
      local path = _"path" {
        d = path_data():rect(p[1], p[2], text.textLength / 2 + rect_r, rect_hh, rect_r, rect_r);
      }
      u_path_map[uid] = path
      u_paths[#u_paths + 1] = path
      u_texts[#u_texts + 1] = text
    end
    uid = u_after[uid]
  end

  local eid = e.first
  while eid do
    if eid <= last_eid then
      local path_eids = paths[eid]
      local path_beziers = {}

      if curve_a == 0 then
        local p1 = point2()
        local p2 = point2()
        for i = 1, #path_eids do
          local path_eid = path_eids[i]
          local uid = vu_target[path_eid]
          local vid = uv_target[path_eid]
          matrix:transform(p1:set(x[uid], y[uid]))
          matrix:transform(p2:set(x[vid], y[vid]))
          path_beziers[i] = bezier(p1, p2)
        end
      elseif curve_a >= 0.5 then
        local p1 = point2()
        local p2 = point2()
        local p3 = point2()
        local n = #path_eids

        local path_eid = path_eids[1]
        local uid = vu_target[path_eid]
        local vid = uv_target[path_eid]
        matrix:transform(p1:set(x[uid], y[uid]))
        matrix:transform(p2:set(x[vid], y[vid]))
        p2:interpolate(p2, p1, 0.5)
        path_beziers[1] = bezier(p1, p2)

        for i = 1, n - 1 do
          local j = i + 1
          local path_eid = path_eids[i]
          local uid = vu_target[path_eid]
          local vid = uv_target[path_eid]
          local wid = uv_target[path_eids[j]]
          matrix:transform(p1:set(x[uid], y[uid]))
          matrix:transform(p2:set(x[vid], y[vid]))
          matrix:transform(p3:set(x[wid], y[wid]))
          p1:interpolate(p2, p1, 0.5)
          p3:interpolate(p2, p3, 0.5)
          path_beziers[j] = bezier(p1, p2, p3)
        end

        local path_eid = path_eids[n]
        local uid = vu_target[path_eid]
        local vid = uv_target[path_eid]
        matrix:transform(p1:set(x[uid], y[uid]))
        matrix:transform(p2:set(x[vid], y[vid]))
        p1:interpolate(p1, p2, 0.5)
        path_beziers[n + 1] = bezier(p1, p2)
      else
        local p1 = point2()
        local p2 = point2()
        local p3 = point2()
        local n = #path_eids

        local path_eid = path_eids[1]
        local uid = vu_target[path_eid]
        local vid = uv_target[path_eid]
        matrix:transform(p1:set(x[uid], y[uid]))
        matrix:transform(p2:set(x[vid], y[vid]))
        p2:interpolate(p2, p1, curve_a)
        path_beziers[1] = bezier(p1, p2)

        for i = 1, n - 1 do
          local j = i + 1
          local path_eid = path_eids[i]
          local uid = vu_target[path_eid]
          local vid = uv_target[path_eid]
          local wid = uv_target[path_eids[j]]
          matrix:transform(p1:set(x[uid], y[uid]))
          matrix:transform(p2:set(x[vid], y[vid]))
          matrix:transform(p3:set(x[wid], y[wid]))
          p1:interpolate(p2, p1, curve_a)
          p3:interpolate(p2, p3, curve_a)
          path_beziers[#path_beziers + 1] = bezier(p1, p2, p3)
          if j < n then
            matrix:transform(p1:set(x[wid], y[wid]))
            p1:interpolate(p2, p1, curve_a)
            path_beziers[#path_beziers + 1] = bezier(p3, p1)
          end
        end

        local path_eid = path_eids[n]
        local uid = vu_target[path_eid]
        local vid = uv_target[path_eid]
        matrix:transform(p1:set(x[uid], y[uid]))
        matrix:transform(p2:set(x[vid], y[vid]))
        p1:interpolate(p1, p2, curve_a)
        path_beziers[#path_beziers + 1] = bezier(p1, p2)
      end

      local uid = vu_target[path_eids[1]]
      local vid = uv_target[path_eids[#path_eids]]
      local first, last = clip_path(
          u_path_map[uid].d:bezier({}),
          u_path_map[vid].d:bezier({}),
          path_beziers)

      local b = path_beziers[first]
      local pd = path_data():M(b:get(1, point2()))
      for i = first, last do
        local b = path_beziers[i]
        if b:size() == 2 then
          pd:L(b:get(2, point2()))
        else
          assert(b:size() == 3)
          pd:Q(
              b:get(2, point2()),
              b:get(3, point2()))
        end
      end

      local path = _"path" { d = pd }
      e_paths[#e_paths + 1] = path

      local label = e_labels[eid]
      if label then
        local m = #path_eids / 2
        m = m - m % 1
        local path_eid = path_eids[m]
        local vid = g.uv.target[eid]
        local p = matrix:transform(point2(x[vid], y[vid]))
        local text = make_text(p, label, font_size, max_text_length)
        e_texts[#e_texts + 1] = text
      end
    end
    eid = e_after[eid]
  end

  return _"g" { u_paths, u_texts, e_paths, e_texts }
end
