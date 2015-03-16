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
  local id, uid = next(ctx._u, e and e.id)
  if id then
    return edge(ctx._g, id, uid, ctx._v[id])
  end
end

local function each_edge_with_property(ctx, e)
  return ctx.e:get_edge(ctx.p:next_id(ctx.k, e and e.id))
end

return function (g)
  local self = {
    _g = g;
    _n = 0;
    _u = {};
    _v = {};
  }

  function self:create_edge(uid, vid)
    local id = self._n + 1
    self._n = id
    self._u[id] = uid
    self._v[id] = vid
    return edge(self._g, id, uid, vid)
  end

  function self:remove_edge(id)
    self._u[id] = nil
    self._v[id] = nil
  end

  function self:get_edge(id)
    if id then
      return edge(self._g, id, self._u[id], self._v[id])
    end
  end

  function self:each_edge()
    return each_edge, self
  end

  function self:each_edge_with_property(k)
    return each_edge_with_property, {
      e = self,
      p = self._g._ep;
      k = k;
    }
  end

  return self
end
