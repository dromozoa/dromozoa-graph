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

local properties = require "dromozoa.graph.properties"
local vertex = require "dromozoa.graph.vertex"

local function each_vertex(ctx, v)
  local id = next(ctx._v, v:get_id())
  if id then
    return vertex(ctx._g, id)
  else
    return nil
  end
end

return function (g)
  local self = {
    _g = g;
    _id = 0;
    _v = {};
    _p = properties();
  }

  function self:new_id()
    local id = self._id + 1
    self._id = id
    return id
  end

  function self:new_vertex()
    local id = self:new_id()
    self._v[id] = true
    return vertex(self._g, id)
  end

  function self:set_vertex_property(id, k, v)
    self._p:set_property(id, k, v)
    return self
  end

  function self:get_vertex_property(id, k)
    return self._p:get_property(id, k)
  end

  function self:each_vertex()
    return each_vertex, self, vertex()
  end

  return self
end
