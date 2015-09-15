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
local vertex = require "dromozoa.graph.vertex"

local class = {}

function class.new(g)
  return {
    g = function () return g end;
    n = 0;
    data = {};
  }
end

function class:clone(g)
  local that = clone(self)
  that.g = function () return g end
  return that
end

function class:empty()
  return not next(self.data)
end

function class:create_vertex()
  local id = self.n + 1
  self.n = id
  self.data[id] = true
  return vertex(self.g(), id)
end

function class:remove_vertex(id)
  self.data[id] = nil
end

function class:get_vertex(id)
  if id then
    return vertex(self.g(), id)
  end
end

function class:each_vertex(key)
  if key then
    return self.g()._vp:each_item(key, class.get_vertex, self)
  else
    return function (_, i)
      if i then
        return self:get_vertex(next(self.data, i.id))
      else
        return self:get_vertex(next(self.data))
      end
    end
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, g)
    return setmetatable(class.new(g), metatable)
  end;
})
