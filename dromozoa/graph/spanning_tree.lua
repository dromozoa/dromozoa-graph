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

function class:add_edge(eid, uid, vid)
  local vu = self.vu
  self.uv:add_edge(eid, uid, vid)
  vu.first[vid] = eid
  vu.target[eid] = uid
end

function class:remove_edge(eid)
  local uv = self.uv
  local vu = self.vu
  local vu_target = vu.target
  local uid = vu_target[eid]
  local vid = uv.target[eid]
  uv:remove_edge(eid, uid)
  vu.first[vid] = nil
  vu_target[eid] = nil
end

return setmetatable(class, {
  __call = function (g)
    local vu_first = {}
    local vu_before = {}
    return setmetatable({
      uv = adjacency_list();
      vu = {
        first = vu_first;
        last = vu_first;
        before = vu_before;
        after = vu_before;
        target = {};
      }
    }, metatable)
  end;
})
