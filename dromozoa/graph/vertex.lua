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

local bfs = require "dromozoa.graph.bfs"
local dfs = require "dromozoa.graph.dfs"

local class = {}

function class.new(g, id)
  return {
    g = function () return g end;
    id = id;
  }
end

function class:remove()
  local id = self.id
  self.g()._vp:remove_item(id)
  self.g()._v:remove_vertex(id)
end

function class:impl_get_property(key)
  return self.g()._vp:get_property(self.id, key)
end

function class:impl_set_property(key, value)
  self.g()._vp:set_property(self.id, key, value)
end

function class:each_property()
  return self.g()._vp:each_property(self.id)
end

function class:each_adjacent_vertex(mode)
  return self.g():impl_get_adjacencies(mode):each_adjacent_vertex(self.id)
end

function class:count_degree(mode)
  return self.g():impl_get_adjacencies(mode):count_degree(self.id)
end

function class:bfs(visitor, mode)
  bfs(self.g(), visitor, self, mode)
end

function class:dfs(visitor, mode)
  dfs(self.g(), visitor, self, mode)
end

local metatable = {}

function metatable:__index(key)
  local fn = class[key]
  if fn == nil then
    return self:impl_get_property(key)
  else
    return fn
  end
end

function metatable:__newindex(key, value)
  self:impl_set_property(key, value)
end

return setmetatable(class, {
  __call = function (_, g, id)
    return setmetatable(class.new(g, id), metatable)
  end;
})
