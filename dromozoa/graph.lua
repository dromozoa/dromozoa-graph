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
local dfs = require "dromozoa.graph.dfs"
local edge = require "dromozoa.graph.edge"
local merge = require "dromozoa.graph.merge"
local model = require "dromozoa.graph.model"
local properties = require "dromozoa.graph.properties"
local vertex = require "dromozoa.graph.vertex"
local write_graphviz = require "dromozoa.graph.write_graphviz"

local function id(value)
  if type(value) == "table" then
    return value.id
  else
    return value
  end
end

local function each(self, constructor, iterator, context)
  return coroutine.wrap(function ()
    for id in iterator, context do
      coroutine.yield(constructor(self, id))
    end
  end)
end

local class = {}

function class.new()
  local self = {
    model = model();
    vp = properties();
    ep = properties();
  }
  return self
end

function class:empty()
  return self.model:empty()
end

function class:create_vertex()
  return vertex(self, self.model:create_vertex())
end

function class:get_vertex(u)
  return vertex(self, id(u))
end

function class:each_vertex(key)
  if key == nil then
    return each(self, class.get_vertex, self.model:each_vertex())
  else
    return each(self, class.get_vertex, self.vp:each_item(key))
  end
end

function class:clear_vertex_properties(key)
  self.vp:clear_properties(key)
end

function class:create_edge(u, v)
  local uid = id(u)
  local vid = id(v)
  return edge(self, self.model:create_edge(uid, vid), uid, vid)
end

function class:get_edge(e)
  return edge(self, id(e))
end

function class:each_edge(key)
  if key == nil then
    return each(self, class.get_edge, self.model:each_edge())
  else
    return each(self, class.get_edge, self.ep:each_item(key))
  end
end

function class:clear_edge_properties(key)
  self.ep:clear_properties(key)
end

function class:merge(that)
  merge(self, that)
end

function class:dfs(visitor, start)
  dfs(self, visitor, nil, start)
end

function class:tsort(start)
  local vertices = sequence()
  self:dfs({
    back_edge = function (context, g, e, u, v)
      error("found back edge " .. e.id)
    end;
    finish_vertex = function (context, g, u)
      vertices:push(u)
    end;
  }, start)
  return vertices
end

function class:write_graphviz(out, visitor)
  return write_graphviz(self, out, visitor)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
