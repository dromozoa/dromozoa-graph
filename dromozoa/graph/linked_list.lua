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

function class:insert(prev_handle)
  local n = self.n
  local p = self.p
  local next_handle

  local handle = self.h + 1
  self.h = handle

  if not prev_handle then
    next_handle = self.f
    if not next_handle then
      self.f = handle
      p[handle] = handle
      n[handle] = handle
      return handle
    end
    prev_handle = p[next_handle]
  else
    next_handle = n[prev_handle]
  end

  n[prev_handle] = handle
  n[handle] = next_handle
  p[handle] = prev_handle
  p[next_handle] = handle

  return handle
end

function class:remove(handle)
  local n = self.n
  local p = self.p

  local next_handle = n[handle]

  if next_handle == handle then
    self.f = nil
  else
    if self.f == handle then
      self.f = next_handle
    end
    local prev_handle = p[handle]
    n[prev_handle] = next_handle
    p[next_handle] = prev_handle
  end

  n[handle] = nil
  p[handle] = nil
end

function class:each()
  local next_handle = self.f

  if not next_handle then
    return function () end
  else
    local n = self.n
    local tail_handle = self.p[next_handle]
    return function (_, prev_handle)
      if prev_handle ~= tail_handle then
        local handle = next_handle
        next_handle = n[handle]
        return handle
      end
    end
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      h = 0;
      n = {};
      p = {};
    }, metatable)
  end
})
