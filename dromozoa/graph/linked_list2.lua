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

  local prev = self.prev

  local first_id = self.first
  if not first_id then
    self.first = id
    prev[id] = id
    return id
  end

  local next = self.next

  local last_id = prev[first_id]
  prev[first_id] = id
  prev[id] = last_id
  next[last_id] = id

  return id
end

function class:next_impl(prev_id)
  if not prev_id then
    return self.first
  end
  return self.next[prev_id]
end

function class:each(f)
  local next = self.next
  local id = self.first
  repeat
    f(id)
    id = next[id]
  until not id
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      id = 1;
      n = 0;
      next = { [1] = 1 };
      prev = { [1] = 1 };
    }, metatable)
  end;
})
