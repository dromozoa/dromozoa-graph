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

local class = {}
local metatable = { __index = class }

function class:add_vertex()
  local uid = self.uid + 1
  self.uid = uid
  self.uv:add_vertex(uid)
  self.vu:add_vertex(uid)
  return uid
end

function class:remove_vertex(uid)
  self.uv:remove_vertex(uid)
  self.vu:remove_vertex(uid)
end

function class:add_edge(uid, vid)
  local eid = self.eid + 1
  self.eid = eid
  self.uv:add_edge(eid, uid, vid)
  self.vu:add_edge(eid, vid, uid)
  return eid
end

function class:remove_edge(eid)
  local uid = self.eu[eid]
  local vid = self.ev[eid]
  self.uv:remove_edge(eid, uid)
  self.vu:remove_edge(eid, vid)
end

function class:each_edge(uid)
  local uv = self.uv:each_edge(uid)
  local vu = self.vu:each_edge(uid, true)
  return function (state, prev_eid)
    if uv then
      local eid, vid = uv(state, prev_eid)
      if eid then
        return eid, vid, false
      else
        uv = nil
        return vu(state)
      end
    end
    return vu(state, prev_eid)
  end
end

function class:reverse_push_edges(uid, n, eids, uids, vids, invs)
  n = self.vu:reverse_push_edges(uid, n, eids, uids, vids, invs, true)
  return self.uv:reverse_push_edges(uid, n, eids, uids, vids, invs, false)
end

function class:degree(uid)
  return self.uv:degree(uid) + self.vu:degree(uid)
end

return setmetatable(class, {
  __call = function ()
    local uv = adjacency_list()
    local vu = adjacency_list()
    return setmetatable({
      uid = 0;
      eid = 0;
      uv = uv;
      vu = vu;
      ue = uv.ue;
      ev = uv.ev;
      eu = vu.ev;
    }, metatable)
  end;
})
