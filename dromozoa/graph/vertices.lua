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

local vertex = require "dromozoa.graph.vertex"

local class = {}

function class.new()
  return {
    n = 0;
    data = {};
  }
end

function class:empty()
  return not next(self.data)
end

function class:create_vertex(g)
  local id = self.n + 1
  self.n = id
  self.data[id] = true
  return vertex(g, id)
end

function class:remove_vertex(id)
  self.data[id] = nil
end

function class:get_vertex(g, id)
  if id then
    return vertex(g, id)
  end
end

function class:each_vertex(g, key)
  if key then
    return coroutine.wrap(function ()
      for id in g._vp:each_item(key) do
        coroutine.yield(vertex(g, id))
      end
    end)
  else
    return coroutine.wrap(function ()
      for id in pairs(self.data) do
        coroutine.yield(vertex(g, id))
      end
    end)
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
