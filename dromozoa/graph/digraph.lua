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
local clone = require "dromozoa.graph.clone"

local class = {}
local metatable = { __index = class }

function class:add_vertex()
  local uid = self.uid + 1
  self.uid = uid
  self.uv:add_vertex(uid)
  return uid
end

function class:remove_vertex(uid)
  self.uv:remove_vertex(uid)
end

function class:add_edge(uid, vid)
  local eid = self.eid + 1
  self.eid = eid
  self.uv:add_edge(eid, uid, vid)
  self.eu[eid] = uid
  return eid
end

function class:remove_edge(eid)
  local eu = self.eu
  local uid = eu[eid]
  self.uv:remove_edge(eid, uid)
  eu[eid] = nil
end

function class:each_edge(uid)
  return self.uv:each_edge(uid)
end

function class:reverse_push_edges(uid, n, eids, uids, vids, invs)
  return self.uv:reverse_push_edges(uid, n, eids, uids, vids, invs)
end

function class:degree(uid)
  return self.uv:degree(uid)
end

function class:clone()
  local uv = self.uv:clone()
  return setmetatable({
    uid = self.uid;
    eid = self.eid;
    uv = uv;
    ue = uv.ue;
    ev = uv.ev;
    eu = clone(self.eu);
  }, metatable)
end

return setmetatable(class, {
  __call = function ()
    local uv = adjacency_list()
    return setmetatable({
      uid = 0;
      eid = 0;
      uv = uv;
      ue = uv.ue;
      ev = uv.ev;
      eu = {};
    }, metatable)
  end;
})
