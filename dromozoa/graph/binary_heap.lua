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

local function up_heap(heap, key, value, uid, u, i)
  while i > 1 do
    local j = (i - i % 2) / 2
    local vid = heap[j]
    if value[vid] < u then
      heap[i] = vid
      heap[j] = uid
      key[vid] = i
      key[uid] = j
      i = j
    else
      break
    end
  end
end

local function down_heap(heap, key, value, uid, u, i)
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

    if u < v then
      result = true
      heap[i] = vid
      heap[j] = uid
      key[vid] = i
      key[uid] = j

      i = j
      j = i * 2
      vid = heap[j]
    else
      break
    end
  end

  return result
end

local class = {}
local metatable = { __index = class }

function class:push(uid, u)
  local heap = self.heap
  local key = self.key
  local value = self.value

  local i = self.n + 1
  self.n = i

  heap[i] = uid
  key[uid] = i
  value[uid] = u

  return up_heap(heap, key, value, uid, u, i)
end

function class:pop()
  local heap = self.heap

  local i = 1
  local uid = heap[i]

  if uid then
    local key = self.key
    local value = self.value

    local j = self.n
    self.n = j - 1
    local vid = heap[j]

    heap[i] = vid
    heap[j] = nil
    key[uid] = nil
    key[vid] = i
    value[uid] = nil

    down_heap(heap, key, value, vid, value[vid], i)
  end

  return uid
end

function class:remove(uid)
  local heap = self.heap
  local key = self.key
  local value = self.value

  local i = key[uid]
  local j = self.n
  self.n = j - 1

  if i == j then
    heap[i] = nil
    key[uid] = nil
    value[uid] = nil
  else
    local vid = heap[j]
    local v = value[vid]

    heap[i] = vid
    heap[j] = nil
    key[uid] = nil
    key[vid] = i
    value[uid] = nil

    if not down_heap(heap, key, value, vid, v, i) then
      up_heap(heap, key, value, vid, v, i)
    end
  end
end

function class:update(uid, u)
  local heap = self.heap
  local key = self.key
  local value = self.value

  local i = key[uid]
  local v = value[uid]

  value[uid] = v

  if v < u then
    up_heap(heap, key, value, uid, u, i)
  else
    down_heap(heap, key, value, uid, u, i)
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
