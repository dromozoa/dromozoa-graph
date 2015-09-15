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

local clone = require "dromozoa.commons.clone"
local edge = require "dromozoa.graph.edge"

local class = {}

function class.new(g)
  return {
    g = function () return g end;
    n = 0;
    u = {};
    v = {};
  }
end

function class:clone(g)
  local that = clone(self)
  that.g = function () return g end
  return that
end

function class:create_edge(uid, vid)
  local id = self.n + 1
  self.n = id
  self.u[id] = uid
  self.v[id] = vid
  return edge(self.g(), id, uid, vid)
end

function class:remove_edge(id)
  self.u[id] = nil
  self.v[id] = nil
end

function class:reset_edge(id, uid, vid)
  self.u[id] = uid
  self.v[id] = vid
end

function class:get_edge(id)
  if id then
    return edge(self.g(), id, self.u[id], self.v[id])
  end
end

function class:each_edge(key)
  if key then
    return self.g()._ep:each_item(key, class.get_edge, self)
  else
    return function (_, i)
      if i then
        return self:get_edge(next(self.u, i.id))
      else
        return self:get_edge(next(self.u))
      end
    end
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, g)
    return setmetatable(class.new(g), metatable)
  end;
})

--[[
local function construct(_g, _n, _u, _v)
  local _p = _g._ep

  local self = {}

  function self:clone(g)
    return construct(g, _n, clone(_u), clone(_v))
  end

  function self:create_edge(uid, vid)
    local id = _n + 1
    _n = id
    _u[id] = uid
    _v[id] = vid
    return edge(_g, id, uid, vid)
  end

  function self:remove_edge(id)
    _u[id] = nil
    _v[id] = nil
  end

  function self:reset_edge(id, uid, vid)
    _u[id] = uid
    _v[id] = vid
  end

  function self:get_edge(id)
    if id then
      return edge(_g, id, _u[id], _v[id])
    end
  end

  function self:each_edge(key)
    if key then
      return _p:each_item(key, self.get_edge, self)
    else
      return function (_, i)
        if i then
          return self:get_edge(next(_u, i.id))
        else
          return self:get_edge(next(_u))
        end
      end
    end
  end

  return self
end

return function (g)
  return construct(g, 0, {}, {})
end
]]
