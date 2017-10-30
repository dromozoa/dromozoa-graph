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
  return self.v:add()
end

function class:remove_vertex(uid)
  self.v:remove(uid)
end

function class:add_edge(uid, vid)
  local e = self.e
  local eid = e.id + 1
  e.id = eid
  e.n = e.n + 1
  self.uv:add_edge(eid, uid, vid)
  self.vu:add_edge(eid, vid, uid)
  return eid
end

function class:remove_edge(eid)
  local e = self.e
  e.n = e.n - 1
  local uid = self.eu[eid]
  local vid = self.ev[eid]
  self.uv:remove_edge(eid, uid)
  self.vu:remove_edge(eid, vid)
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      u = linked_list();
      e = { id = 0, n = 0 };
      uv = adjacency_list();
      vu = adjacency_list();
    }, metatable)
  end;
})
