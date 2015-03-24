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

local function each_property_key(ctx, k)
  return next(ctx._t, k)
end

local function each_item_table(ctx, i)
  return ctx.f(ctx.o, next(ctx.c, i and i.id))
end

local function each_item_empty()
end

local function construct(self)
  function self:clone()
    return construct {
      _t = clone(self._t);
    }
  end

  function self:clear_properties(k)
    self._t[k] = nil
  end

  function self:set_property(id, k, v)
    local t = self._t
    local c = t[k]
    if v == nil then
      if c then
        c[id] = nil
        if next(c) == nil then
          t[k] = nil
        end
      end
    else
      if not c then
        c = {}
        t[k] = c
      end
      c[id] = v
    end
  end

  function self:get_property(id, k)
    local t = self._t
    local c = t[k]
    if c then
      return c[id]
    end
  end

  function self:remove_item(id)
    local t = self._t
    for k, c in pairs(t) do
      c[id] = nil
      if next(c) == nil then
        t[k] = nil
      end
    end
  end

  function self:each_property_key()
    return each_property_key, self
  end

  function self:each_item(k, o, f)
    local c = self._t[k]
    if c then
      return each_item_table, {
        c = c;
        o = o;
        f = f;
      }
    else
      return each_item_empty
    end
  end

  return self
end

return function ()
  return construct {
    _t = {};
  }
end
