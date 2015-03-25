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
  if k == "u" then
    local u = self._g._v:get_vertex(self.uid)
    rawset(self, "u", u)
    return u
  elseif k == "v" then
    local v = self._g._v:get_vertex(self.vid)
    rawset(self, "v", v)
    return v
  else
    return self._g._ep:get_property(self.id, k)
  end
end

function metatable:__newindex(k, v)
  return self._g._ep:set_property(self.id, k, v)
end

return function (g, id, uid, vid)
  local self = {
    _g = g;
    id = id;
    uid = uid;
    vid = vid;
  }

  function self:remove()
    local g = self._g
    local id = self.id
    g._ep:remove_item(id)
    g._uv:remove_edge(self.uid, id)
    g._vu:remove_edge(self.vid, id)
    g._e:remove_edge(id)
  end

  function self:collapse()
    local that = {}
    for v, e in self.v:each_adjacent_vertex() do
      that[#that + 1] = e
    end
    local g = self._g
    local uid = self.uid
    local uv = g._uv
    for i = 1, #that do
      local e = that[i]
      local id = e.id
      g._e:reset_edge(id, uid, e.vid)
      uv:remove_edge(e.uid, id)
      uv:append_edge(uid, id)
    end
    self.v:remove()
    self:remove()
  end

  return setmetatable(self, metatable)
end
