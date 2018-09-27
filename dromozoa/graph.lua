-- Copyright (C) 2015,2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local layout = require "dromozoa.graph.layout"
local linked_list = require "dromozoa.graph.linked_list"
local render = require "dromozoa.graph.render"
local subdivide_special_edges = require "dromozoa.graph.subdivide_special_edges"

local class = {}
local metatable = { __index = class }

function class:add_vertex()
  return self.u:add()
end

function class:remove_vertex(uid)
  self.u:remove(uid)
end

function class:add_edge(uid, vid)
  local eid = self.e:add()
  self.uv:add_edge(eid, uid, vid)
  self.vu:add_edge(eid, vid, uid)
  return eid
end

function class:set_edge(eid, uid, vid)
  self.e:add(eid)
  self.uv:add_edge(eid, uid, vid)
  self.vu:add_edge(eid, vid, uid)
end

function class:remove_edge(eid)
  local uv = self.uv
  local vu = self.vu
  local uid = vu.target[eid]
  local vid = uv.target[eid]
  self.e:remove(eid)
  uv:remove_edge(eid, uid)
  vu:remove_edge(eid, vid)
end

function class:reverse_edge(eid)
  local uv = self.uv
  local vu = self.vu
  local uid = vu.target[eid]
  local vid = uv.target[eid]

  uv:remove_edge(eid, uid)
  uv:add_edge(eid, vid, uid)

  vu:remove_edge(eid, vid)
  vu:add_edge(eid, uid, vid)
end

function class:subdivide_edge(eid, wid)
  local uv = self.uv
  local vu = self.vu
  local uid = vu.target[eid]
  local vid = uv.target[eid]
  local new_eid = self.e:add()

  local next_eid = uv:remove_edge(eid, uid)
  if not next_eid then
    uv:add_edge(eid, uid, wid)
  else
    uv:insert_edge(next_eid, eid, uid, wid)
  end
  uv:add_edge(new_eid, wid, vid)

  local next_eid = vu:remove_edge(eid, vid)
  if not next_eid then
    vu:add_edge(new_eid, vid, wid)
  else
    vu:insert_edge(next_eid, new_eid, vid, wid)
  end
  vu:add_edge(eid, wid, uid)

  return new_eid
end

function class:render(attrs)
  local last_uid = self.u.last
  local last_eid = self.e.last
  local revered_eids = subdivide_special_edges(self, attrs.e_labels)
  local x, y, paths = layout(self, last_uid, last_eid, revered_eids)
  return render(self, last_uid, last_eid, x, y, paths, attrs)
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      u = linked_list();
      e = linked_list();
      uv = adjacency_list();
      vu = adjacency_list();
    }, metatable)
  end;
})
