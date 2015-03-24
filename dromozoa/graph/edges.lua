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
local edge = require "dromozoa.graph.edge"

local function each_edge(ctx, e)
  local id, uid = next(ctx._u, e and e.id)
  if id then
    return edge(ctx._g, id, uid, ctx._v[id])
  end
end

local function construct(self)
  function self:clone(g)
    return construct {
      _g = g;
      _n = self._n;
      _u = clone(self._u);
      _v = clone(self._v);
    }
  end

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

  function self:each_edge(k)
    if k then
      return self._g._ep:each_item(k, self, self.get_edge)
    else
      return each_edge, self
    end
  end

  return self
end

return function (g)
  return construct {
    _g = g;
    _n = 0;
    _u = {};
    _v = {};
  }
end
