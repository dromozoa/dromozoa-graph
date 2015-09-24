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

local bfs = require "dromozoa.graph.bfs"
local dfs = require "dromozoa.graph.dfs"

local private_graph = function () end
local private_id = function () end

local function unpack_item(self)
  local g = self[private_graph]
  return self[private_id], g.model, g.vp, g
end

local class = {}

function class.new(g, id)
  return {
    [private_graph] = g;
    [private_id] = id;
  }
end

function class:remove()
  local uid, model, props, g = unpack_item(self)
  model:remove_vertex(uid)
  props:remove_item(uid)
end

function class:each_property()
  local uid, model, props, g = unpack_item(self)
  return props:each_property(uid)
end

function class:each_adjacent_vertex(start)
  local uid, model, props, g = unpack_item(self)
  return coroutine.wrap(function ()
    for vid, eid in model:each_adjacent_vertex(uid, start) do
      coroutine.yield(g:get_vertex(vid), g:get_edge(eid))
    end
  end)
end

function class:count_degree(start)
  local uid, model, props, g = unpack_item(self)
  return model:count_degree(uid, start)
end

function class:bfs(visitor, start)
  local uid, model, props, g = unpack_item(self)
  return bfs(g, visitor, self, start)
end

function class:dfs(visitor, start)
  local uid, model, props, g = unpack_item(self)
  return dfs(g, visitor, self, start)
end

local metatable = {}

function metatable:__index(key)
  local uid, model, props, g = unpack_item(self)
  if key == "id" then
    return uid
  else
    local value = props:get_property(uid, key)
    if value == nil then
      return class[key]
    end
    return value
  end
end

function metatable:__newindex(key, value)
  local uid, model, props, g = unpack_item(self)
  if key == "id" then
    error("cannot modify constant")
  end
  props:set_property(uid, key, value)
end

return setmetatable(class, {
  __call = function (_, g, id)
    return setmetatable(class.new(g, id), metatable)
  end;
})
