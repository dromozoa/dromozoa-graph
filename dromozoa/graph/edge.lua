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

function metatable:__index(key)
  if key == "u" then
    return self:impl_get_u()
  elseif key == "v" then
    return self:impl_get_v()
  else
    return self:impl_get_property(key)
  end
end

function metatable:__newindex(key, value)
  self:impl_set_property(key, value)
end

return function (_g, _id, _uid, _vid)
  local _v = _g._v
  local _e = _g._e
  local _p = _g._ep
  local _uv = _g._uv
  local _vu = _g._vu

  local self = {
    id = _id;
    uid = _uid;
    vid = _vid;
  }

  function self:remove()
    _uv:remove_edge(_uid, _id)
    _vu:remove_edge(_vid, _id)
    _p:remove_item(_id)
    _e:remove_edge(_id)
  end

  function self:collapse()
    local v = self.v
    local that = {}
    for _, e in v:each_adjacent_vertex() do
      that[#that + 1] = e
    end
    for i = 1, #that do
      local e = that[i]
      local id = e.id
      _e:reset_edge(id, _uid, e.vid)
      _uv:remove_edge(e.uid, id)
      _uv:append_edge(_uid, id)
    end
    v:remove()
    self:remove()
  end

  function self:impl_get_u()
    local u = _v:get_vertex(_uid)
    rawset(self, "u", u)
    return u
  end

  function self:impl_get_v()
    local v = _v:get_vertex(_vid)
    rawset(self, "v", v)
    return v
  end

  function self:impl_get_property(key)
    return _p:get_property(_id, key)
  end

  function self:impl_set_property(key, value)
    _p:set_property(_id, key, value)
  end

  return setmetatable(self, metatable)
end
