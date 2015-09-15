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
local edge = require "dromozoa.graph.edge"

local class = {}

function class.new(g)
  return {
    g = function () return g end;
    n = 0;
    u = {};
    v = {};
  }
end

function class:clone(g)
  local that = clone(self)
  that.g = function () return g end
  return that
end

function class:create_edge(uid, vid)
  local id = self.n + 1
  self.n = id
  self.u[id] = uid
  self.v[id] = vid
  return edge(self.g(), id, uid, vid)
end

function class:remove_edge(id)
  self.u[id] = nil
  self.v[id] = nil
end

function class:reset_edge(id, uid, vid)
  self.u[id] = uid
  self.v[id] = vid
end

function class:get_edge(id)
  if id then
    return edge(self.g(), id, self.u[id], self.v[id])
  end
end

function class:each_edge(key)
  if key then
    return self.g()._ep:each_item(key, class.get_edge, self)
  else
    return coroutine.wrap(function ()
      for id, uid in pairs(self.u) do
        coroutine.yield(edge(self.g(), id, uid, self.v[id]))
      end
    end)
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
