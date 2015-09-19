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

local function create_edge(uid, eid, ue, eu, nu, pu)
  local ueid = ue[uid]
  ue[uid] = eid
  eu[eid] = uid
  if ueid == 0 then
    nu[eid] = eid
  else
    nu[eid] = nu[ueid]
    nu[ueid] = eid
  end
end

local function remove_edge(eid, ue, eu, nu, pu)
  local uid = eu[eid]
  local next_eid = nu[eid]
  if next_eid == eid then
    assert(ue[uid] == eid)
    ue[uid] = 0
  else
    local prev_eid
    local this_eid = eid
    repeat
      prev_eid = this_eid
      this_eid = next_eid
      next_eid = nu[next_eid]
    until this_eid == eid
    if ue[uid] == eid then
      ue[uid] = prev_eid
    end
    nu[prev_eid] = next_eid
  end
  eu[eid] = nil
  nu[eid] = nil
end

local function reset_edge(uid, eid, ue, eu, nu, pu)
  if uid ~= eu[eid] then
    remove_edge(eid, ue, eu, nu)
    create_edge(uid, eid, ue, eu, nu)
  end
end

local function each_adjacent_vertex(uid, ue, ev, nu)
  local ueid = ue[uid]
  if ueid == 0 then
    return function () end
  else
    ueid = nu[ueid]
    return coroutine.wrap(function ()
      local eid = ueid
      repeat
        coroutine.yield(ev[eid], eid)
        eid = nu[eid]
      until eid == ueid
    end)
  end
end

local function count_degree(uid, ue, nu)
  local ueid = ue[uid]
  if ueid == 0 then
    return 0
  else
    local count = 0
    local eid = ueid
    repeat
      count = count + 1
      eid = nu[eid]
    until eid == ueid
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
  create_edge(uid, eid, self.ue, self.eu, self.nu, self.pu)
  create_edge(vid, eid, self.ve, self.ev, self.nv, self.pv)
  return eid
end

function class:remove_edge(eid)
  remove_edge(eid, self.ue, self.eu, self.nu, self.pu)
  remove_edge(eid, self.ve, self.ev, self.nv, self.pv)
end

function class:reset_edge(eid, uid, vid)
  reset_edge(uid, eid, self.ue, self.eu, self.nu, self.pu)
  reset_edge(vid, eid, self.ve, self.ev, self.nv, self.pv)
end

function class:get_edge(eid)
  return self.eu[eid], self.ev[eid]
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
