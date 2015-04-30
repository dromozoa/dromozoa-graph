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

local metatable = {}

function metatable:__index(key)
  return self:impl_get_property(key)
end

function metatable:__newindex(key, value)
  self:impl_set_property(key, value)
end

return function (_g, _id)
  local _v = _g._v
  local _p = _g._vp

  local self = {
    id = _id;
  }

  function self:remove()
    _p:remove_item(_id)
    _v:remove_vertex(_id)
  end

  function self:impl_get_property(key)
    return _p:get_property(_id, key)
  end

  function self:impl_set_property(key, value)
    _p:set_property(_id, key, value)
  end

  function self:each_adjacent_vertex(mode)
    return _g:impl_get_adjacencies(mode):each_adjacent_vertex(_id)
  end

  function self:count_degree(mode)
    return _g:impl_get_adjacencies(mode):count_degree(_id)
  end

  function self:bfs(visitor, mode)
    bfs(_g, visitor, self, mode)
  end

  function self:dfs(visitor, mode)
    dfs(_g, visitor, self, mode)
  end

  return setmetatable(self, metatable)
end
