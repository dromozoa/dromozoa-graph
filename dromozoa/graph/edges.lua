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

local edge = require "dromozoa.graph.edge"

local function each_edge(ctx, e)
  local id, u = next(ctx._u, e and e.id)
  if id then
    return edge(ctx._g, id, u, ctx._v[id])
  end
end

return function (g)
  local self = {
    _g = g;
    _n = 0;
    _u = {};
    _v = {};
  }

  function self:create_edge(u, v)
    local id = self._n + 1
    self._n = id
    self._u[id] = u
    self._v[id] = v
    local g = self._g
    g._a:create_neighbor(u, v, id)
    g._b:create_neighbor(v, u, id)
    return edge(g, id, u, v)
  end

  function self:get_edge(id)
    if id then
      return edge(self._g, id, self._u[id], self._v[id])
    end
  end

  function self:each_edge()
    return each_edge, self
  end

  return self
end
