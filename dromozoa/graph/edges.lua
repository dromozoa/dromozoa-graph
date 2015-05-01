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

local clone = require "dromozoa.graph.clone"
local edge = require "dromozoa.graph.edge"

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
