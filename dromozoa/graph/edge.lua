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
local private_id = function () end

local function unpack_item(self)
  local root = self[private_root]
  return self[private_id], root, root.model, root.ep
end

local class = {}

function class.new(root, id)
  return {
    [private_root] = root;
    [private_id] = id;
  }
end

function class:remove()
  local eid, root, model, props = unpack_item(self)
  model:remove_edge(eid)
  props:remove_item(eid)
end

function class:each_property()
  local eid, root, model, props = unpack_item(self)
  return props:each_property(eid)
end

function class:collapse(start)
  local eid, root, model, props = unpack_item(self)
  local vid = model:collapse_edge(eid, start)
  self:remove()
  root:get_vertex(vid):remove()
end

local metatable = {}

function metatable:__index(key)
  local eid, root, model, props = unpack_item(self)
  if key == "id" then
    return eid
  elseif key == "uid" then
    return model:get_edge_uid(eid)
  elseif key == "vid" then
    return model:get_edge_vid(eid)
  elseif key == "u" then
    return root:get_vertex(model:get_edge_uid(eid))
  elseif key == "v" then
    return root:get_vertex(model:get_edge_vid(eid))
  else
    local value = props:get_property(eid, key)
    if value == nil then
      return class[key]
    end
    return value
  end
end

function metatable:__newindex(key, value)
  local eid, root, model, props = unpack_item(self)
  if key == "id" then
    error("cannot modify constant")
  elseif key == "uid" then
    model:reset_edge(eid, value, model:get_edge_vid(eid))
  elseif key == "vid" then
    model:reset_edge(eid, model:get_edge_uid(eid), value)
  elseif key == "u" then
    model:reset_edge(eid, value.id, model:get_edge_vid(eid))
  elseif key == "v" then
    model:reset_edge(eid, model:get_edge_uid(eid), value.id)
  else
    props:set_property(eid, key, value)
  end
end

return setmetatable(class, {
  __call = function (_, root, id)
    return setmetatable(class.new(root, id), metatable)
  end;
})
