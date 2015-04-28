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

local function each_edge(ctx, e)
  local id, uid = next(ctx._u, e and e.id)
  if id then
    return edge(ctx._g, id, uid, ctx._v[id])
  end
end

local function construct(self, g, n, u, v)
  local p = g._ep

  function self:clone(g)
    return construct({}, g, n, clone(u), clone(v))
  end

  function self:create_edge(uid, vid)
    local id = n
    n = id + 1
    u[id] = uid
    v[id] = vid
    return edge(g, id, uid, vid)
  end

  function self:remove_edge(id)
    u[id] = nil
    v[id] = nil
  end

  function self:reset_edge(id, uid, vid)
    u[id] = uid
    v[id] = vid
  end

  function self:get_edge(id)
    if id then
      return edge(g, id, u[id], v[id])
    end
  end

  function self:each_edge(key)
    if key then
      return p:each_item(key, self.get_edge, self)
    else
      return function (_, i)
        if i then
          return self:get_edge(next(u, i.id))
        else
          return self:get_edge(next(u))
        end
      end
    end
  end

  return self
end

return function (g)
  return construct({}, g, 1, {}, {})
end
