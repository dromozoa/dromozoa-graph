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

local function each_neightbor(ctx)
  local i = ctx._i + 1
  ctx._i = 1
  local e = ctx._g._e:get_edge(ctx._r[i])
  if e then
    if e._u == ctx._u then
      return e.v, e
    else
      return e.u, e
    end
  end
end

return function (g)
  local self = {
    _g = g;
    _t = {};
  }

  function self:create_neighbor(u, v, e)
    local t = self._t
    local r = t[u]
    if r then
      r[#r + 1] = e
    else
      t[u] = { e }
    end
  end

  function self:each_neighbor(u)
    return each_neighbor, {
      _g = self._g;
      _r = self._t[u];
      _u = u;
      _i = 0;
    }
  end

  return self
end
