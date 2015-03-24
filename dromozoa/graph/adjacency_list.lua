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

local copy = require "dromozoa.graph.copy"

local function each_adjacent_vertex_table(ctx)
  local i = ctx.i + 1
  ctx.i = i
  local e = ctx.e:get_edge(ctx.r[i])
  if e then
    return e[ctx.b], e
  end
end

local function each_adjacent_vertex_value(ctx, v)
  if not v then
    return ctx.v, ctx.e
  end
end

local function each_adjacent_vertex_empty()
end

local function construct(self)
  function self:clone(g)
    return construct {
      _g = g;
      _a = copy(self._a);
      _b = copy(self._b);
      _t = copy(self._t);
    }
  end

  function self:append_edge(uid, eid)
    local t = self._t
    local r = t[uid]
    if r then
      if type(r) == "table" then
        r[#r + 1] = eid
      else
        t[uid] = { r, eid }
      end
    else
      t[uid] = eid
    end
  end

  function self:remove_edge(uid, eid)
    local t = self._t
    local r = t[uid]
    if type(r) == "table" then
      local n = #r
      for i = 1, n do
        if r[i] == eid then
          table.remove(r, i)
          if n == 2 then
            t[uid] = r[1]
          end
          return
        end
      end
    else
      if r == eid then
        t[uid] = nil
        return
      end
    end
    error "could not remove_edge"
  end

  function self:each_adjacent_vertex(uid)
    local r = self._t[uid]
    if r then
      if type(r) == "table" then
        return each_adjacent_vertex_table, {
          e = self._g._e;
          b = self._b;
          r = r;
          i = 0;
        }
      else
        local e = self._g._e:get_edge(r)
        return each_adjacent_vertex_value, {
          e = e;
          v = e[self._b];
        }
      end
    else
      return each_adjacent_vertex_empty
    end
  end

  function self:count_degree(uid)
    local r = self._t[uid]
    if r then
      if type(r) == "table" then
        return #r
      else
        return 1
      end
    else
      return 0
    end
  end

  return self
end

return function (g, a, b)
  return construct {
    _g = g;
    _a = a;
    _b = b;
    _t = {};
  }
end
