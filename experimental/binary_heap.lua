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

local function up_heap(heap, key, value, n, vid, v)
  local result = false
  while n > 1 do
    local m = (n - n % 2) / 2
    local uid = heap[m]
    local u = value[uid]
    if u < v then
      heap[m] = vid
      heap[n] = uid
      key[uid] = n
      key[vid] = m
      n = m
      result = true
    else
      return result
    end
  end
end

local function down_heap(heap, key, value, m, uid, u)
  local result = false
  while true do
    local n = m * 2
    local vid = heap[n]
    if vid then
      local v = value[vid]

      local n2 = n + 1
      local vid2 = heap[n2]
      if vid2 then
        local v2 = value[vid2]
        if v < v2 then
          n = n2
          vid = vid2
          v = v2
        end
      end

      if u < v then
        heap[m] = vid
        heap[n] = uid
        key[uid] = n
        key[vid] = m
        m = n
        result = true
      else
        return result
      end
    else
      return result
    end
  end
end

local class = {}
local metatable = { __index = class }

function class:push(id, priority)
  local n = self.n + 1
  self.n = n

  local heap = self.heap
  local key = self.key
  local value = self.value

  heap[n] = id
  key[id] = n
  value[id] = priority

  up_heap(heap, key, value, n, id, priority)
end

function class:pop()
  local n = self.n
  self.n = n - 1

  local heap = self.heap
  local key = self.key
  local value = self.value

  local uid = heap[1]
  local vid = heap[n]

  heap[1] = vid
  heap[n] = nil
  key[uid] = nil
  key[vid] = 1
  value[uid] = nil

  down_heap(heap, key, value, 1, vid, value[vid])

  return uid
end

function class:remove(uid)
  local n = self.n
  self.n = n - 1

  local heap = self.heap
  local key = self.key
  local value = self.value

  local m = key[uid]
  if m == n then
    heap[n] = nil
    key[uid] = nil
    value[uid] = nil
  else
    local vid = heap[n]

    heap[m] = vid
    heap[n] = nil
    key[uid] = nil
    key[vid] = m
    value[uid] = nil

    local v = value[vid]
    if not down_heap(heap, key, value, m, vid, v) then
      up_heap(heap, key, value, m, vid, v)
    end
  end
end

function class:update(uid, priority)
  local heap = self.heap
  local key = self.key
  local value = self.value

  local m = key[uid]
  local v = value[uid]
  value[uid] = v
  if v < priority then
    up_heap(heap, key, value, m, uid, priority)
  else
    down_heap(heap, key, value, m, uid, priority)
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      n = 0;
      heap = {};
      key = {};
      value = {};
    }, metatable)
  end;
})
