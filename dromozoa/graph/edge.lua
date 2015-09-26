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

local sequence = require "dromozoa.commons.sequence"

local private_graph = function () end
local private_id = function () end

local function unpack_item(self)
  local g = self[private_graph]
  return self[private_id], g.model, g.ep, g
end

local function collapse(self, u, v, start)
  local edges = sequence()
  for _, e in v:each_adjacent_vertex(start) do
    edges:push(e)
  end
  for e in edges:each() do
    e[start] = u
  end
  self:remove()
  v:remove()
end

local class = {}

function class.new(g, id)
  return {
    [private_graph] = g;
    [private_id] = id;
  }
end

function class:remove()
  local eid, model, props, g = unpack_item(self)
  model:remove_edge(eid)
  props:remove_item(eid)
end

function class:each_property()
  local eid, model, props, g = unpack_item(self)
  return props:each_property(eid)
end

function class:collapse(start)
  if start == "v" then
    collapse(self, self.v, self.u, "v")
  else
    collapse(self, self.u, self.v, "u")
  end
end

local metatable = {}

function metatable:__index(key)
  local eid, model, props, g = unpack_item(self)
  if key == "id" then
    return eid
  elseif key == "uid" then
    return model:get_edge_uid(eid)
  elseif key == "vid" then
    return model:get_edge_vid(eid)
  elseif key == "u" then
    return g:get_vertex(model:get_edge_uid(eid))
  elseif key == "v" then
    return g:get_vertex(model:get_edge_vid(eid))
  else
    local value = props:get_property(eid, key)
    if value == nil then
      return class[key]
    end
    return value
  end
end

function metatable:__newindex(key, value)
  local eid, model, props, g = unpack_item(self)
  if key == "id" then
    error("cannot modify constant")
  elseif key == "uid" then
    model:reset_edge_uid(eid, value)
  elseif key == "vid" then
    model:reset_edge_vid(eid, value)
  elseif key == "u" then
    model:reset_edge_uid(eid, value.id)
  elseif key == "v" then
    model:reset_edge_vid(eid, value.id)
  else
    props:set_property(eid, key, value)
  end
end

return setmetatable(class, {
  __call = function (_, g, id)
    return setmetatable(class.new(g, id), metatable)
  end;
})
