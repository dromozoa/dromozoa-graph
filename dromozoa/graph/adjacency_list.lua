-- Copyright (C) 2015,2017-2019 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local metatable = {
  __index = class;
  __name = "dromozoa.graph.adjacency_list";
}

function class:add_edge(eid, uid, vid)
  local last = self.last

  local prev_eid = last[uid]
  if prev_eid then
    self.before[eid] = prev_eid
    self.after[prev_eid] = eid
  else
    self.first[uid] = eid
  end

  last[uid] = eid
  self.target[eid] = vid
end

function class:insert_edge(next_eid, eid, uid, vid)
  local before = self.before
  local after = self.after

  local prev_eid = before[next_eid]
  if prev_eid then
    before[eid] = prev_eid
    after[prev_eid] = eid
  else
    self.first[uid] = eid
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
  if prev_eid then
    after[prev_eid] = next_eid
  else
    self.first[uid] = next_eid
  end
  if next_eid then
    before[next_eid] = prev_eid
  else
    self.last[uid] = prev_eid
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
  __call = function (_, self)
    if not self then
      self = {
        first = {};
        last = {};
        before = {};
        after = {};
        target = {};
      }
    end
    return setmetatable(self, metatable)
  end;
})
