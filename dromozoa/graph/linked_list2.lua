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

  local next = self.next
  local prev = self.prev
  local next_id = 1
  local prev_id = prev[next_id]

  next[prev_id] = id
  next[id] = next_id
  prev[id] = prev_id
  prev[next_id] = id

  return id
end

function class:next_impl(prev_id)
  if not prev_id then
    prev_id = 1
  end

  local id = self.next[prev_id]
  if id ~= 1 then
    return id
  end
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
