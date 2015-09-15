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

local class = {}

function class.new(g, id, uid, vid)
  return {
    g = function () return g end;
    id = id;
    uid = uid;
    vid = vid;
  }
end

function class:remove()
  local id = self.id
  self.g()._uv:remove_edge(self.uid, id)
  self.g()._vu:remove_edge(self.vid, id)
  self.g()._ep:remove_item(id)
  self.g().edges:remove_edge(id)
end

function class:collapse()
  local v = self.v
  local that = {}
  for _, e in v:each_adjacent_vertex() do
    that[#that + 1] = e
  end
  for i = 1, #that do
    local e = that[i]
    local id = e.id
    local uid = self.uid
    self.g().edges:reset_edge(id, uid, e.vid)
    self.g()._uv:remove_edge(e.uid, id)
    self.g()._uv:append_edge(uid, id)
  end
  v:remove()
  self:remove()
end

function class:impl_get_u()
  local u = self.g().vertices:get_vertex(self.uid)
  rawset(self, "u", u)
  return u
end

function class:impl_get_v()
  local v = self.g().vertices:get_vertex(self.vid)
  rawset(self, "v", v)
  return v
end

function class:impl_get_property(key)
  return self.g()._ep:get_property(self.id, key)
end

function class:impl_set_property(key, value)
  self.g()._ep:set_property(self.id, key, value)
end

function class:each_property()
  return self.g()._ep:each_property(self.id)
end

local metatable = {}

function metatable:__index(key)
  local fn = class[key]
  if fn == nil then
    if key == "u" then
      return self:impl_get_u()
    elseif key == "v" then
      return self:impl_get_v()
    else
      return self:impl_get_property(key)
    end
  else
    return fn
  end
end

function metatable:__newindex(key, value)
  self:impl_set_property(key, value)
end

return setmetatable(class, {
  __call = function (_, g, id, uid, vid)
    return setmetatable(class.new(g, id, uid, vid), metatable)
  end;
})
