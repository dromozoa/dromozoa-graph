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

local vertex = require "dromozoa.graph.vertex"

local metatable = {}

function metatable:__index(k, v)
  if k == "u" then
    local u = vertex(self._g, self._u)
    self.u = u
    return u
  elseif k == "v" then
    local v = vertex(self._g, self._v)
    self.v = v
    return v
  else
    return self._g._ep:get_property(self.id, k)
  end
end

function metatable:__newindex(k, v)
  return self._g._ep:set_property(self.id, k, v)
end

return function (g, id, u, v)
  local self = {
    _g = g;
    id = id;
    _u = u;
    _v = v;
  }

  return setmetatable(self, metatable)
end
