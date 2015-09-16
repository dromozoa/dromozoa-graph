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
local adjacency_list = require "dromozoa.graph.adjacency_list2"
local dfs = require "dromozoa.graph.dfs"
local edges = require "dromozoa.graph.edges"
local merge = require "dromozoa.graph.merge"
local write_graphviz = require "dromozoa.graph.write_graphviz"
local properties = require "dromozoa.graph.properties"
local tsort = require "dromozoa.graph.tsort"
local vertices = require "dromozoa.graph.vertices"

local function construct(self)
  local _vp = self._vp
  local _ep = self._ep
  local _uv = self._uv
  local _vu = self._vu

  function self:clone()
    return construct(clone(self))
  end

  function self:empty()
    return self.vertices:empty()
  end

  function self:create_vertex()
    return self.vertices:create_vertex(self)
  end

  function self:get_vertex(id)
    return self.vertices:get_vertex(self, id)
  end

  function self:each_vertex(key)
    return self.vertices:each_vertex(self, key)
  end

  function self:clear_vertex_properties(key)
    _vp:clear_properties(key)
  end

  function self:create_edge(u, v)
    local uid, vid
    if type(u) == "table" then uid = u.id else uid = u end
    if type(v) == "table" then vid = v.id else vid = v end
    local e = self.edges:create_edge(self, uid, vid)
    local eid = e.id
    _uv:append_edge(uid, eid)
    _vu:append_edge(vid, eid)
    return e
  end

  function self:get_edge(id)
    return self.edges:get_edge(self, id)
  end

  function self:each_edge(key)
    return self.edges:each_edge(self, key)
  end

  function self:clear_edge_properties(key)
    _ep:clear_properties(key)
  end

  function self:merge(that)
    merge(self, that)
  end

  function self:dfs(visitor, mode)
    dfs(self, visitor, nil, mode)
  end

  function self:tsort(mode)
    return tsort(self, mode)
  end

  function self:write_graphviz(out, visitor)
    return write_graphviz(self, out, visitor)
  end

  function self:impl_get_adjacencies(mode)
    if mode == "v" then
      return _vu
    else
      return _uv
    end
  end

  return self
end

return function ()
  return construct({
    _vp = properties();
    _ep = properties();
    vertices = vertices();
    edges = edges();
    _uv = adjacency_list("v");
    _vu = adjacency_list("u");
  })
end
