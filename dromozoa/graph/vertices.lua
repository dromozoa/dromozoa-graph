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

local clone = require "dromozoa.graph.clone"
local vertex = require "dromozoa.graph.vertex"

local function each_vertex(ctx, v)
  return ctx:get_vertex(next(ctx._v, v and v.id))
end

local function construct(self)
  function self:clone(g)
    return construct {
      _g = g;
      _n = self._n;
      _v = clone(self._v);
    }
  end

  function self:empty()
    return not next(self._v)
  end

  function self:create_vertex()
    local id = self._n + 1
    self._n = id
    self._v[id] = true
    return vertex(self._g, id)
  end

  function self:remove_vertex(id)
    self._v[id] = nil
  end

  function self:get_vertex(id)
    if id then
      return vertex(self._g, id)
    end
  end

  function self:each_vertex(k)
    if k then
      return self._g._vp:each_item(k, self.get_vertex, self)
    else
      return each_vertex, self
    end
  end

  return self
end

return function (g)
  return construct {
    _g = g;
    _n = 0;
    _v = {};
  }
end
