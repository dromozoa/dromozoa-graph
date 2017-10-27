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

function class:clone()
  local uv = self.uv:clone()
  local vu = self.vu:clone()
  return setmetatable({
    u = clone(self.u);
    e = clone(self.e);
    uv = uv;
    vu = vu;
    ue = uv.ue;
    ev = uv.ev;
    eu = vu.ev;
  }, metatable)
end

function class:reverse_edge(eid)
  local uv = self.uv
  local vu = self.vu
  local uid = self.eu[eid]
  local vid = self.ev[eid]
  uv:remove_edge(eid, uid)
  vu:remove_edge(eid, vid)
  uv:add_edge(eid, vid, uid)
  vu:add_edge(eid, uid, vid)
end

return setmetatable(class, {
  __call = function ()
    local uv = adjacency_list()
    local vu = adjacency_list()
    return setmetatable({
      u = linked_list();
      e = { id = 0, n = 0 };

      uv = uv;
      vu = vu;
      ue = uv.ue;
      ev = uv.ev;
      eu = vu.ev;
    }, metatable)
  end;
})
