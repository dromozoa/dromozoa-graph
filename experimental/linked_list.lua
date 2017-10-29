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

function class:add(value)
  local prev_id = self.last

  if not prev_id then
    self.id = 1
    self.n = 1
    self.first = 1
    self.last = 1
    self.value[1] = value
  else
    local id = self.id + 1
    self.id = id
    self.n = self.n + 1
    self.last = id
    self.next[prev_id] = id
    self.prev[id] = prev_id
    self.value[id] = value
  end

  return id
end

function class:each(prev_id)
  if not prev_id then
    local id = self.first
    return id, self.value[id]
  end

  local id = self.next[prev_id]
  if id then
    return id, self.value[id]
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      n = 0;
      next = {};
      prev = {};
      value = {};
    }, metatable)
  end;
})
