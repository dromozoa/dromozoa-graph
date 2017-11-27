-- Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local linked_list = require "dromozoa.graph.linked_list"

local class = {}
local metatable = { __index = class }

function class:add_vertex()
  return self.u:add()
end

function class:remove_vertex(uid)
  self.u:remove(uid)
end

function class:add_edge(uid, vid)
  local uv = self.uv
  local uv_last = uv.last

  local prev_vid = uv_last[uid]
  if not prev_vid then
    uv.first[uid] = vid
  else
    uv.before[vid] = prev_vid
    uv.after[prev_vid] = vid
  end

  uv_last[uid] = vid
  self.vu[vid] = uid
end

function class:insert_edge(next_vid, vid)
  local uv = self.uv
  local uv_before = uv.before
  local uv_after = uv.after
  local vu = self.vu

  local uid = vu[next_vid]

  local prev_vid = uv_before[next_vid]
  if not prev_vid then
    uv.first[uid] = vid
  else
    uv_before[vid] = prev_vid
    uv_after[prev_vid] = vid
  end

  uv_before[next_vid] = vid
  uv_after[vid] = next_vid
  vu[vid] = uid
end

function class:remove_edge(uid, vid)
  local uv = self.uv
  local uv_before = uv.before
  local uv_after = uv.after

  local prev_vid = uv_before[vid]
  local next_vid = uv_after[vid]
  if not prev_vid then
    uv.first[uid] = next_vid
  else
    uv_after[prev_vid] = next_vid
  end
  if not next_vid then
    uv.last[uid] = prev_vid
  else
    uv_before[next_vid] = prev_vid
  end

  uv_before[vid] = nil
  uv_after[vid] = nil
  self.vu[vid] = nil

  return next_vid
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      u = linked_list();
      uv = {
        first = {};
        last = {};
        before = {};
        after = {};
      };
      vu = {};
    }, metatable)
  end;
})
