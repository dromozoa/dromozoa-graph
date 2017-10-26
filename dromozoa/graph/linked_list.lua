-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

  local next = self.next
  local prev = self.prev

  local next_id = self.first
  if not next_id then
    self.first = id
    next[id] = id
    prev[id] = id
  else
    local prev_id = prev[next_id]
    next[prev_id] = id
    next[id] = next_id
    prev[id] = prev_id
    prev[next_id] = id
  end

  return id
end

function class:insert(next_id)
  local id = self.id + 1
  self.id = id
  self.n = self.n + 1

  local next = self.next
  local prev = self.prev
  local prev_id = prev[next_id]

  if self.first == next_id then
    self.first = id
  end

  next[prev_id] = id
  next[id] = next_id
  prev[id] = prev_id
  prev[next_id] = id

  return id
end

function class:remove(id)
  self.n = self.n - 1

  local next = self.next
  local prev = self.prev
  local next_id = next[id]

  if next_id == id then
    self.first = nil
  else
    if self.first == id then
      self.first = next_id
    end
    local prev_id = prev[id]
    next[prev_id] = next_id
    prev[next_id] = prev_id
  end

  next[id] = nil
  prev[id] = nil
end

function class:each()
  local next_id = self.first
  if not next_id then
    return function () end
  else
    local next = self.next
    local tail_id = self.prev[next_id]
    return function (_, prev_id)
      if prev_id ~= tail_id then
        local id = next_id
        next_id = next[id]
        return id
      end
    end
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      id = 0;
      n = 0;
      next = {};
      prev = {};
    }, metatable)
  end
})
