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

local class = {}

function class.new()
  return {
    vn = 0;
    ue = {};
    ve = {};
    en = 0;
    eu = {};
    ev = {};
    uv = {};
    vu = {};
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

local function create_edge(uid, eid, ue, eu, uv)
  local ueid = ue[uid]
  ue[uid] = eid
  eu[eid] = uid
  if ueid == 0 then
    uv[eid] = eid
  else
    uv[eid] = ueid
    uv[ueid] = eid
  end
end

function class:create_edge(uid, vid)
  local eid = self.en + 1
  self.en = eid
  create_edge(uid, eid, self.ue, self.eu, self.uv)
  create_edge(vid, eid, self.ve, self.ev, self.vu)
  return eid
end

local function each_adjacent_vertex(uid, ue, ev, uv)
  local ueid = ue[uid]
  if ueid == 0 then
    return function () end
  else
    ueid = uv[ueid]
    return coroutine.wrap(function ()
      local eid = ueid
      repeat
        coroutine.yield(ev[eid], eid)
        eid = uv[eid]
      until eid == ueid
    end)
  end
end

function class:each_adjacent_vertex(uid, mode)
  if mode == "v" then
    return each_adjacent_vertex(uid, self.ve, self.eu, self.vu)
  else
    return each_adjacent_vertex(uid, self.ue, self.ev, self.uv)
  end
end

function class:each_adjacent_uv(uid)
  return each_adjacent_vertex(uid, self.ue, self.ev, self.uv)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
