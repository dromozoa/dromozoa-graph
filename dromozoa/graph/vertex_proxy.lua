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

local private_root = function () end

local class = {}

function class.new(root, id)
  return {
    [private_root] = root;
    id = id;
  }
end

function class:remove()
  local uid = self.id
  local root = self[private_root]
  local model = root.model
  local props = root.vp
  model:remove_vertex(uid)
  props:remove_item(uid)
end

function class:each_adjacent_vertex(mode)
  local uid = self.id
  local root = self[private_root]
  local model = root.model
  return coroutine.wrap(function ()
    for vid, eid in model:each_adjacent_vertex(uid, mode) do
      coroutine.yield(root:get_vertex(vid), root:get_edge(eid))
    end
  end)
end

function class:count_degree(mode)
  local uid = self.id
  local root = self[private_root]
  local model = root.model
  return model:count_degree(uid, mode)
end

local metatable = {}

function metatable:__index(key)
  local uid = self.id
  local root = self[private_root]
  local props = root.vp
  local value = props:get_property(uid, key)
  if value == nil then
    return class[key]
  end
  return value
end

function metatable:__newindex(key, value)
  local uid = self.id
  local root = self[private_root]
  local props = root.vp
  props:set_property(uid, key, value)
end

return setmetatable(class, {
  __call = function (_, root, id)
    return setmetatable(class.new(root, id), metatable)
  end;
})
