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

local function create_edge(eid, uid, ue, eu, nu, pu)
  eu[eid] = uid
  local next_eid = ue[uid]
  if next_eid == 0 then
    ue[uid] = eid
    nu[eid] = eid
    pu[eid] = eid
  else
    local prev_eid = pu[next_eid]
    nu[prev_eid] = eid
    nu[eid] = next_eid
    pu[eid] = prev_eid
    pu[next_eid] = eid
  end
end

local function remove_edge(eid, ue, eu, nu, pu)
  local uid = eu[eid]
  eu[eid] = nil
  local next_eid = nu[eid]
  if next_eid == eid then
    assert(ue[uid] == eid)
    ue[uid] = 0
  else
    if ue[uid] == eid then
      ue[uid] = next_eid
    end
    local prev_eid = pu[eid]
    nu[prev_eid] = next_eid
    pu[next_eid] = prev_eid
  end
  nu[eid] = nil
  pu[eid] = nil
end

local function reset_edge(eid, uid, ue, eu, nu, pu)
  remove_edge(eid, ue, eu, nu, pu)
  create_edge(eid, uid, ue, eu, nu, pu)
end

local function each_adjacent_vertex(uid, ue, ev, nu)
  local start_eid = ue[uid]
  if start_eid == 0 then
    return function () end
  else
    return coroutine.wrap(function ()
      local eid = start_eid
      repeat
        coroutine.yield(ev[eid], eid)
        eid = nu[eid]
      until eid == start_eid
    end)
  end
end

local function count_degree(uid, ue, nu)
  local start_eid = ue[uid]
  if start_eid == 0 then
    return 0
  else
    local count = 0
    local eid = start_eid
    repeat
      count = count + 1
      eid = nu[eid]
    until eid == start_eid
    return count
  end
end

local class = {}

function class.new()
  return {
    vn = 0;
    ue = {};
    ve = {};
    en = 0;
    eu = {};
    ev = {};
    nu = {};
    nv = {};
    pu = {};
    pv = {};
  }
end

function class:create_vertex()
  local uid = self.vn + 1
  self.vn = uid
  self.ue[uid] = 0
  self.ve[uid] = 0
  return uid
end

function class:remove_vertex(uid)
  self.ue[uid] = nil
  self.ve[uid] = nil
end

function class:empty()
  return next(self.ue) == nil
end

function class:each_vertex()
  return next, self.ue, nil
end

function class:create_edge(uid, vid)
  local eid = self.en + 1
  self.en = eid
  create_edge(eid, uid, self.ue, self.eu, self.nu, self.pu)
  create_edge(eid, vid, self.ve, self.ev, self.nv, self.pv)
  return eid
end

function class:remove_edge(eid)
  remove_edge(eid, self.ue, self.eu, self.nu, self.pu)
  remove_edge(eid, self.ve, self.ev, self.nv, self.pv)
end

function class:reset_edge_uid(eid, uid)
  reset_edge(eid, uid, self.ue, self.eu, self.nu, self.pu)
end

function class:reset_edge_vid(eid, vid)
  reset_edge(eid, vid, self.ve, self.ev, self.nv, self.pv)
end

function class:get_edge_uid(eid)
  return self.eu[eid]
end

function class:get_edge_vid(eid)
  return self.ev[eid]
end

function class:each_edge()
  return next, self.eu, nil
end

function class:each_adjacent_vertex(uid, start)
  if start == "v" then
    return each_adjacent_vertex(uid, self.ve, self.eu, self.nv)
  else
    return each_adjacent_vertex(uid, self.ue, self.ev, self.nu)
  end
end

function class:count_degree(uid, start)
  if start == "v" then
    return count_degree(uid, self.ve, self.nv)
  else
    return count_degree(uid, self.ue, self.nu)
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
