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

local adjacency_list = require "dromozoa.graph.adjacency_list"
local edges = require "dromozoa.graph.edges"
local properties = require "dromozoa.graph.properties"
local vertices = require "dromozoa.graph.vertices"

return function ()
  local self = {
    _vp = properties();
    _ep = properties();
  }

  self._v = vertices(self)
  self._e = edges(self)
  self._uv = adjacency_list(self, "u", "v")
  self._vu = adjacency_list(self, "v", "u")

  function self:_a(mode)
    if mode == "v" then
      return self._vu
    else
      return self._uv
    end
  end

  function self:create_vertex()
    return self._v:create_vertex()
  end

  function self:each_vertex(k)
    return self._v:each_vertex(k)
  end

  function self:each_vertex_property()
    return self._vp:each_property()
  end

  function self:create_edge(u, v)
    local uid = type(u) == "table" and u.id or u
    local vid = type(v) == "table" and v.id or v
    local e = self._e:create_edge(uid, vid)
    local eid = e.id
    self._uv:append_edge(uid, eid)
    self._vu:append_edge(vid, eid)
    return e
  end

  function self:each_edge(k)
    return self._e:each_edge(k)
  end

  function self:each_edge_property()
    return self._ep:each_property()
  end

  return self
end
