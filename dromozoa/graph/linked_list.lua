-- Copyright (C) 2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

function class:add()
  local id = self.id + 1
  self.id = id
  self.n = self.n + 1

  local prev_id = self.last
  if prev_id then
    self.before[id] = prev_id
    self.after[prev_id] = id
  else
    self.first = id
  end

  self.last = id

  return id
end

function class:insert(next_id)
  local id = self.id + 1
  self.id = id
  self.n = self.n + 1

  local before = self.before
  local after = self.after

  local prev_id = before[next_id]
  if prev_id then
    before[id] = prev_id
    after[prev_id] = id
  else
    self.first = id
  end

  before[next_id] = id
  after[id] = next_id

  return id
end

function class:remove(id)
  self.n = self.n - 1

  local before = self.before
  local after = self.after

  local prev_id = before[id]
  local next_id = after[id]
  if prev_id then
    after[prev_id] = next_id
  else
    self.first = next_id
  end
  if next_id then
    before[next_id] = prev_id
  else
    self.last = prev_id
  end

  before[id] = nil
  after[id] = nil

  return next_id
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      id = 0;
      n = 0;
      before = {};
      after = {};
    }, metatable)
  end;
})
