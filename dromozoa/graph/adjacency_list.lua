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

local table_remove = table.remove

local function each_adjacent_vertex_table(ctx)
  local i = ctx._i + 1
  ctx._i = i
  local e = ctx._g._e:get_edge(ctx._r[i])
  if e then
    return e[ctx._b], e
  end
end

local function each_adjacent_vertex_value(ctx, v)
  if not v then
    local e = ctx._r
    return e[ctx._b], e
  end
end

local function each_adjacent_vertex_empty()
  return nil
end

return function (g, a, b)
  local self = {
    _g = g;
    _a = a;
    _b = b;
    _t = {};
  }

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
      for i = #r, 1, -1 do
        if r[i] == eid then
          table_remove(r, i)
        end
      end
      if #r == 1 then
        t[uid] = r[1]
      end
    else
      if r == eid then
        t[uid] = nil
      end
    end

  end

  function self:each_adjacent_vertex(uid)
    local r = self._t[uid]
    if r then
      if type(r) == "table" then
        return each_adjacent_vertex_table, {
          _g = self._g;
          _b = self._b;
          _r = r;
          _i = 0;
        }
      else
        return each_adjacent_vertex_value, {
          _g = self._g;
          _b = self._b;
          _r = r;
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
