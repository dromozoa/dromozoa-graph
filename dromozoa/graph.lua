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

  function self:create_vertex()
    return self._v:create_vertex()
  end

  function self:remove_vertex(v)
    self._v:remove_vertex(type(v) == "table" and v.id or v)
  end

  function self:each_vertex()
    return self._v:each_vertex()
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

  function self:remove_edge(e)
    local eid
    if type(e) == "table" then
      eid = e.id
    else
      eid = e
      e = self._e:get_edge(e)
    end
    self._uv:remove_edge(e.uid, eid)
    self._vu:remove_edge(e.vid, eid)
    self._e:remove_edge(eid)
  end

  function self:each_edge()
    return self._e:each_edge()
  end

  function self:adjacencies(mode)
    if mode == "v" then
      return self._vu
    else
      return self._uv
    end
  end

  return self
end
