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

function class.new(mode)
  return {
    mode = mode;
    handle = 0;
    next = {};
    edge = {};
    data = {};
  }
end

function class:append_edge(uid, eid)
  local handle = self.data[uid]
  if handle == nil then
    local h = self.handle + 1
    self.handle = h
    self.next[h] = h
    self.edge[h] = eid
    self.data[uid] = h
  else
    local h = self.handle + 1
    self.handle = h

    local next = self.next

    local p = handle
    local n = next[handle]
    next[p] = h
    next[h] = n
    self.edge[h] = eid
    self.data[uid] = h
  end
end

function class:remove_edge(uid, eid)
  local handle = self.data[uid]
  if handle ~= nil then
    local next = self.next
    local edge = self.edge
    local data = self.data
    local p = handle
    handle = next[handle]
    local h = handle
    repeat
      if edge[h] == eid then
        local n = next[h]
        next[p] = n
        next[h] = nil
        edge[h] = nil
        if h == n then
          data[uid] = nil
        elseif h == handle then
          data[uid] = n
        end
        return
      end
      p = h
      h = next[h]
    until h == handle
  end
  error("could not remove edge " .. eid)
end

function class:each_adjacent_vertex(g, uid)
  local handle = self.data[uid]
  if handle ~= nil then
    local next = self.next
    local edge = self.edge
    local mode = self.mode
    handle = next[handle]
    return coroutine.wrap(function ()
      local h = handle
      repeat
        local e = g:get_edge(edge[h])
        coroutine.yield(e[mode], e)
        h = next[h]
      until h == handle
    end)
  else
    return function () end
  end
end

function class:count_degree(uid)
  local count = 0
  local handle = self.data[uid]
  if handle ~= nil then
    local next = self.next
    local h = handle
    repeat
      count = count + 1
      h = next[h]
    until h == handle
  end
  return count
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, mode)
    return setmetatable(class.new(mode), metatable)
  end;
})
