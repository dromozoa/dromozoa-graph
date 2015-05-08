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
local dfs = require "dromozoa.graph.dfs"
local edges = require "dromozoa.graph.edges"
local write_graphviz = require "dromozoa.graph.write_graphviz"
local properties = require "dromozoa.graph.properties"
local tsort = require "dromozoa.graph.tsort"
local vertices = require "dromozoa.graph.vertices"

local function construct(self)
  local _vp = self._vp
  local _ep = self._ep
  local _v = self._v
  local _e = self._e
  local _uv = self._uv
  local _vu = self._vu

  function self:clone()
    local that = {
      _vp = _vp:clone();
      _ep = _ep:clone();
    }
    that._v = _v:clone(that)
    that._e = _e:clone(that)
    that._uv = _uv:clone(that)
    that._vu = _vu:clone(that)
    return construct(that)
  end

  function self:empty()
    return _v:empty()
  end

  function self:create_vertex()
    return _v:create_vertex()
  end

  function self:get_vertex(id)
    return _v:get_vertex(id)
  end

  function self:each_vertex(key)
    return _v:each_vertex(key)
  end

  function self:clear_vertex_properties(key)
    _vp:clear_properties(key)
  end

  function self:create_edge(u, v)
    local uid, vid
    if type(u) == "table" then uid = u.id else uid = u end
    if type(v) == "table" then vid = v.id else vid = v end
    local e = _e:create_edge(uid, vid)
    local eid = e.id
    _uv:append_edge(uid, eid)
    _vu:append_edge(vid, eid)
    return e
  end

  function self:get_edge(id)
    return _e:get_edge(id)
  end

  function self:each_edge(key)
    return _e:each_edge(key)
  end

  function self:clear_edge_properties(key)
    _ep:clear_properties(key)
  end

  function self:dfs(visitor, mode)
    dfs(self, visitor, nil, mode)
  end

  function self:tsort(mode)
    return tsort(self, mode)
  end

  function self:write_graphviz(out, visitor)
    write_graphviz(self, out, visitor)
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
  local self = {
    _vp = properties();
    _ep = properties();
  }
  self._v = vertices(self)
  self._e = edges(self)
  self._uv = adjacency_list(self, "v")
  self._vu = adjacency_list(self, "u")
  return construct(self)
end
