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
  local n = self.n + 1
  self.n = n
  self[n] = value
  return n
end

function class:each(i)
  if not i then
    return 1, self[1]
  end

  i = i + 1
  if i <= self.n then
    return i, self[i]
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      n = 0;
    }, metatable)
  end;
})
