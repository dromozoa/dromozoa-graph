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

local class = {}
local metatable = { __index = class }

function class:add_node(uid, vid)
  local last = self.last

  local prev_vid = last[uid]
  if not prev_vid then
    self.first[uid] = vid
  else
    self.before[vid] = prev_vid
    self.after[prev_vid] = vid
  end

  last[uid] = vid
  self.parent[vid] = uid
end

function class:insert_node(next_vid, vid)
  local before = self.before
  local after = self.after
  local parent = self.parent

  local uid = parent[next_vid]

  local prev_vid = before[next_vid]
  if not prev_vid then
    self.first[uid] = vid
  else
    before[vid] = prev_vid
    after[prev_vid] = vid
  end

  before[next_vid] = vid
  after[vid] = next_vid
  parent[vid] = uid
end

function class:remove_node(vid)
  local before = self.before
  local after = self.after
  local parent = self.parent

  local uid = parent[vid]

  local prev_vid = before[vid]
  local next_vid = after[vid]
  if not prev_vid then
    self.first[uid] = next_vid
  else
    after[prev_vid] = next_vid
  end
  if not next_vid then
    self.last[uid] = prev_vid
  else
    before[next_vid] = prev_vid
  end

  before[vid] = nil
  after[vid] = nil
  parent[vid] = nil

  return next_vid
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      first = {};
      last = {};
      before = {};
      after = {};
      parent = {};
    }, metatable)
  end;
})
