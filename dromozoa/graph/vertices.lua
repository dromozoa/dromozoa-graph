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
local vertex = require "dromozoa.graph.vertex"

local function construct(_g, _n, _data)
  local _p = _g._vp

  local self = {}

  function self:clone(g)
    return construct(g, _n, clone(_data))
  end

  function self:empty()
    return not next(_data)
  end

  function self:create_vertex()
    local id = _n + 1
    _n = id
    _data[id] = true
    return vertex(_g, id)
  end

  function self:remove_vertex(id)
    _data[id] = nil
  end

  function self:get_vertex(id)
    if id then
      return vertex(_g, id)
    end
  end

  function self:each_vertex(key)
    if key then
      return _p:each_item(key, self.get_vertex, self)
    else
      return function (_, i)
        if i then
          return self:get_vertex(next(_data, i.id))
        else
          return self:get_vertex(next(_data))
        end
      end
    end
  end

  return self
end

return function (g)
  return construct(g, 0, {})
end
