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

function class:get(key, handle, default)
  local data = self.dataset[key]
  if data then
    local value = data[handle]
    if value ~= nil then
      return value
    end
  end
  return default
end

function class:put(key, handle, value)
  local dataset = self.dataset
  local data = dataset[key]
  if data then
    data[handle] = value
  else
    dataset[key] = { [handle] = value }
  end
end

function class:remove(key, handle)
  local dataset = self.dataset
  local data = dataset[key]
  if data then
    data[handle] = nil
    if next(data) == nil then
      dataset[key] = nil
    end
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({ dataset = {} }, metatable)
  end;
})
