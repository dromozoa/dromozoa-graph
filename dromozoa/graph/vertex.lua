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

local metatable = {}

function metatable:__index(k)
  return self._g._vp:get_property(self.id, k)
end

function metatable:__newindex(k, v)
  self._g._vp:set_property(self.id, k, v)
end

return function (g, id)
  local self = {
    _g = g;
    id = id;
  }

  function self:remove()
    self._g._v:remove_vertex(self.id)
  end

  function self:each_adjacent_vertex(mode)
    return self._g:_a(mode):each_adjacent_vertex(self.id)
  end

  function self:count_degree(mode)
    return self._g:_a(mode):count_degree(self.id)
  end

  return setmetatable(self, metatable)
end
