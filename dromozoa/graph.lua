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
  local eid = self.eid + 1
  self.eid = eid
  self.uv:add_edge(eid, uid, vid)
  self.vu:add_edge(eid, vid, uid)
  return eid
end

function class:remove_edge(eid)
  local uid = self.vu.target[eid]
  local vid = self.uv.target[eid]
  self.uv:remove_edge(eid, uid)
  self.vu:remove_edge(eid, vid)
end

function class:remove_edges(uid)
  local uv = self.uv
  local uv_target = uv.target
  local vu = self.vu
  local vu_target = vu.target

  local eid = uv.first[uid]
  while eid do
    vu:remove_edge(eid, uv_target[eid])
    eid = uv:remove_edge(eid, uid)
  end

  local eid = vu.first[uid]
  while eid do
    uv:remove_edge(eid, vu_target[eid])
    eid = vu:remove_edge(eid, uid)
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      u = linked_list();
      eid = 0;
      uv = adjacency_list();
      vu = adjacency_list();
    }, metatable)
  end;
})
