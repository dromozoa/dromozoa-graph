-- Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local linked_list = require "dromozoa.graph.linked_list"

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
  vu:remove_edge(eid, vid)
  uv:add_edge(eid, vid, uid)
  vu:add_edge(eid, uid, vid)
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
