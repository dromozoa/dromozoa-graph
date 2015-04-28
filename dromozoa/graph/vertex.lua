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
  return self:get_property(key)
end

function metatable:__newindex(key, value)
  self:set_property(key, value)
end

return function (g, id)
  local p = g._vp
  local v = g._v

  local self = {
    id = id;
  }

  function self:remove()
    p:remove_item(id)
    v:remove_vertex(id)
  end

  function self:get_property(k)
    return p:get_property(id, k)
  end

  function self:set_property(k, v)
    p:set_property(id, k, v)
  end

  function self:each_adjacent_vertex(mode)
    return g:_a(mode):each_adjacent_vertex(id)
  end

  function self:count_degree(mode)
    return g:_a(mode):count_degree(id)
  end

  function self:bfs(visitor, mode)
    bfs(g, visitor, self, mode)
  end

  function self:dfs(visitor, mode)
    dfs(g, visitor, self, mode)
  end

  return setmetatable(self, metatable)
end
