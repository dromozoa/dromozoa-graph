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
  repeat
    local j = (i - i % 2) / 2
    local vid = heap[j]
    if value[vid] < u then
      heap[i] = vid
      heap[j] = uid
      key[vid] = i
      key[uid] = j
      if j == 1 then
        break
      end
      i = j
    else
      break
    end
  until false
end

local function up_heap_(heap, key, value, uid, u, i)
  if i > 1 then
    local j = (i - i % 2) / 2
    local vid = heap[j]
    if value[vid] < u then
      heap[i] = vid
      heap[j] = uid
      key[vid] = i
      key[uid] = j
      return up_heap(heap, key, value, uid, u, j)
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

function class:push(uid, u)
  local i = self.n + 1
  self.n = i

  local heap = self.heap
  local key = self.key
  local value = self.value

  value[uid] = u

  if i == 1 then
    heap[i] = uid
    key[uid] = i
    return
  end

  local j = (i - i % 2) / 2
  local vid = heap[j]
  local v = value[vid]

  repeat
    if u <= v then
      heap[i] = uid
      key[uid] = i
      return
    end

    heap[i] = vid
    key[vid] = i

    if j == 1 then
      heap[j] = uid
      key[uid] = j
      return
    end

    local k = (j - j % 2) / 2
    local wid = heap[k]
    local w = value[wid]

    if u <= w then
      heap[j] = uid
      key[uid] = j
      return
    end

    i = j
    j = k
    vid = wid
    v = w

  until false

  -- v < w < u
  -- w < ? < ?


  -- repeat
  --   local j = (i - i % 2) / 2
  --   local vid = heap[j]
  --   if value[vid] < u then
  --     heap[i] = vid
  --     heap[j] = uid
  --     key[vid] = i
  --     key[uid] = j
  --     if j == 1 then
  --       break
  --     end
  --     i = j
  --   else
  --     break
  --   end
  -- until false
end

function class:pop()
  local n = self.n
  self.n = n - 1

  local heap = self.heap
  local key = self.key
  local value = self.value

  local uid = heap[1]
  if not uid then
    return nil
  end

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
      up_heap(heap, key, value, vid, v, m)
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
    up_heap(heap, key, value, uid, priority, m)
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
