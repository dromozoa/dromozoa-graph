-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local pairs = require "dromozoa.commons.pairs"

local class = {}

function class.new()
  return {}
end

function class:clear_properties(key)
  self[key] = nil
end

function class:remove_item(id)
  for key, data in pairs(self) do
    data[id] = nil
    if next(data) == nil then
      self[key] = nil
    end
  end
end

function class:each_item(key, fn, context)
  local data = self[key]
  if data then
    return function (_, i)
      if i then
        return fn(context, next(data, i.id))
      else
        return fn(context, next(data))
      end
    end
  else
    return function () end
  end
end

function class:each_item2(key)
  local data = self[key]
  if data then
    return coroutine.wrap(function ()
      for id in pairs(data) do
        coroutine.yield(id)
      end
    end)
  else
    return nil
  end
end

function class:set_property(id, key, value)
  local data = self[key]
  if data then
    if value ~= nil then
      data[id] = value
    else
      data[id] = nil
      if next(data) == nil then
        self[key] = nil
      end
    end
  else
    if value ~= nil then
      self[key] = { [id] = value }
    end
  end
end

function class:get_property(id, key)
  local data = self[key]
  if data then
    return data[id]
  end
end

function class:each_property(id)
  return function (_, i)
    for key, data in next, self, i do
      local value = data[id]
      if value ~= nil then
        return key, value
      end
    end
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
