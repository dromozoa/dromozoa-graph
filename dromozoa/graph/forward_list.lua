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

function class:add()
  local id = self.id + 1
  self.id = id
  self.n = self.n + 1

  local prev_id = self.tail
  if not prev_id then
    self.head = id
    self.tail = id
  else
    self.tail = id
    self[prev_id] = id
  end

  return id
end

function class:add_first()
  local id = self.id + 1
  self.id = id
  self.n = self.n + 1

  local next_id = self.head
  if not next_id then
    self.head = id
    self.tail = id
  else
    self.head = id
    self[id] = next_id
  end

  return id
end

function class:insert_after(prev_id)
  local id = self.id + 1
  self.id = id
  self.n = self.n + 1

  local next_id = self[prev_id]
  if not next_id then
    self.tail = id
    self[prev_id] = id
  else
    self[prev_id] = id
    self[id] = next_id
  end

  return next_id
end

function class:remove_first()
  self.n = self.n - 1

  local id = self.head
  local next_id = self[id]
  if not next_id then
    self.head = nil
    self.tail = nil
  else
    self.head = next_id
    self[id] = nil
  end

  return next_id
end

function class:remove_after(prev_id)
  self.n = self.n - 1

  local id = self[prev_id]
  local next_id = self[id]
  if not next_id then
    self.tail = prev_id
    self[prev_id] = nil
    self[id] = nil
  else
    self[prev_id] = next_id
    self[id] = nil
  end

  return next_id
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      id = 0;
      n = 0;
    }, metatable)
  end
})
