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

local clone = require "dromozoa.commons.clone"

local function construct(self, _dataset)
  function self:clone()
    return construct({}, clone(_dataset))
  end

  function self:clear_properties(key)
    _dataset[key] = nil
  end

  function self:remove_item(id)
    for key, data in pairs(_dataset) do
      data[id] = nil
      if next(data) == nil then
        _dataset[key] = nil
      end
    end
  end

  function self:each_item(key, fn, context)
    local data = _dataset[key]
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

  function self:set_property(id, key, value)
    local data = _dataset[key]
    if data then
      if value ~= nil then
        data[id] = value
      else
        data[id] = nil
        if next(data) == nil then
          _dataset[key] = nil
        end
      end
    else
      if value ~= nil then
        _dataset[key] = { [id] = value }
      end
    end
  end

  function self:get_property(id, key)
    local data = _dataset[key]
    if data then
      return data[id]
    end
  end

  return self
end

return function ()
  return construct({}, {})
end
