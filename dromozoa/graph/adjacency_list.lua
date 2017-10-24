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

local table_clone = require "dromozoa.graph.table_clone"

local class = {}
local metatable = { __index = class }

function class:add_vertex(uid)
  local ue = self.ue
  if ue[uid] == nil then
    ue[uid] = false
    return uid
  end
end

function class:remove_vertex(uid)
  self.ue[uid] = nil
end

function class:add_edge(eid, uid, vid)
  local ue = self.ue
  local nu = self.nu
  local pu = self.pu
  local ev = self.ev
  local next_eid = ue[uid]
  if not next_eid then
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
  ev[eid] = vid
end

function class:remove_edge(eid, uid)
  local ue = self.ue
  local nu = self.nu
  local pu = self.pu
  local ev = self.ev
  local next_eid = nu[eid]
  if next_eid == eid then
    ue[uid] = false
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
  ev[eid] = nil
end

function class:each_edge(uid, inv)
  local next_eid = self.ue[uid]
  if not next_eid then
    return function () end
  else
    local nu = self.nu
    local ev = self.ev
    local tail_eid = self.pu[next_eid]
    return function (_, prev_eid)
      if prev_eid ~= tail_eid then
        local eid = next_eid
        next_eid = nu[eid]
        return eid, ev[eid], inv
      end
    end
  end
end

function class:reverse_push_edges(uid, n, eids, uids, vids, invs, inv)
  local tail_eid = self.ue[uid]
  if tail_eid then
    local pu = self.pu
    local ev = self.ev
    local eid = tail_eid
    repeat
      eid = pu[eid]
      n = n + 1
      eids[n] = eid
      uids[n] = uid
      vids[n] = ev[eid]
      invs[n] = inv
    until eid == tail_eid
  end
  return n
end

function class:degree(uid)
  local tail_eid = self.ue[uid]
  if not tail_eid then
    return 0
  else
    local pu = self.pu
    local n = 0
    local eid = tail_eid
    repeat
      n = n + 1
      eid = pu[eid]
    until eid == tail_eid
    return n
  end
end

function class:clone()
  return setmetatable({
    ue = table_clone(self.ue);
    nu = table_clone(self.nu);
    pu = table_clone(self.pu);
    ev = table_clone(self.ev);
  }, metatable)
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      ue = {};
      nu = {};
      pu = {};
      ev = {};
    }, metatable)
  end;
})
