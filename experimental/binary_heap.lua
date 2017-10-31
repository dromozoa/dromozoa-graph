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
  while n > 1 do
    local m = (n - n % 2) / 2
    local uid = heap[m]
    if value[uid] < v then
      heap[m] = vid
      heap[n] = uid
      key[vid] = m
      key[uid] = n
      n = m
    else
      return
    end
  end
end

local function down_heap(heap, key, value, i, uid, u)
  local result

  local j = i * 2
  local vid = heap[j]
  while vid do
    local v = value[vid]

    local k = j + 1
    local wid = heap[k]
    if wid then
      local w = value[wid]
      if v < w then
        j = k
        vid = wid
        v = w
      end
    end

    if not (u < v) then
      return result
    end

    result = true

    heap[i] = vid
    heap[j] = uid
    key[uid] = j
    key[vid] = i

    i = j
    j = i * 2
    vid = heap[j]
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
