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

local edge = require "dromozoa.graph.edge_proxy"
local model = require "dromozoa.graph.model"
local properties = require "dromozoa.graph.properties"
local vertex = require "dromozoa.graph.vertex_proxy"

local function each(self, constructor, iterator, context)
  return coroutine.wrap(function ()
    for id in iterator, context do
      coroutine.yield(constructor(self, id))
    end
  end)
end

local class = {}

function class.new()
  local this = {
    model = model();
    vp = properties();
    ep = properties();
  }
  return this
end

function class:empty()
  return self.model:empty()
end

function class:get_vertex(uid)
  return vertex(self, uid)
end

function class:create_vertex()
  return self:get_vertex(self.model:create_vertex())
end

function class:each_vertex(key)
  if key == nil then
    return each(self, class.get_vertex, self.model:each_vertex())
  else
    return each(self, class.get_vertex, self.vp:each_item(key))
  end
end

function class:get_edge(eid)
  return edge(self, eid, self.model:get_edge(eid))
end

function class:create_edge(uid, vid)
  return self:get_edge(self.model:create_edge(uid, vid))
end

function class:each_edge(key)
  if key == nil then
    return each(self, class.get_edge, self.model:each_edge())
  else
    return each(self, class.get_edge, self.ep:each_item(key))
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
