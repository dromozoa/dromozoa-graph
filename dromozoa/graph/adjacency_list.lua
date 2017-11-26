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

function class:add_edge(eid, uid, vid)
  local last = self.last

  local prev_eid = last[uid]
  if not prev_eid then
    self.first[uid] = eid
  else
    self.before[eid] = prev_eid
    self.after[prev_eid] = eid
  end

  last[uid] = eid
  self.target[eid] = vid
end

function class:insert_edge(next_eid, eid, uid, vid)
  local before = self.before
  local after = self.after

  local prev_eid = before[next_eid]
  if not prev_eid then
    self.first[uid] = eid
  else
    before[eid] = prev_eid
    after[prev_eid] = eid
  end

  before[next_eid] = eid
  after[eid] = next_eid
  self.target[eid] = vid
end

function class:remove_edge(eid, uid)
  local before = self.before
  local after = self.after

  local prev_eid = before[eid]
  local next_eid = after[eid]
  if not prev_eid then
    self.first[uid] = next_eid
  else
    after[prev_eid] = next_eid
  end
  if not next_eid then
    self.last[uid] = prev_eid
  else
    before[next_eid] = prev_eid
  end

  before[eid] = nil
  after[eid] = nil
  self.target[eid] = nil

  return next_eid
end

function class:degree(uid)
  local after = self.after

  local result = 0
  local eid = self.first[uid]
  while eid do
    result = result + 1
    eid = after[eid]
  end

  return result
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      first = {};
      last = {};
      before = {};
      after = {};
      target = {};
    }, metatable)
  end;
})
