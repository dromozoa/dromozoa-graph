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

local function up_heap(tree, n, v)
  while n > 1 do
    local m = (n - n % 2) / 2
    local u = tree[m]
    if u < v then
      tree[m] = v
      tree[n] = u
      n = m
    else
      break
    end
  end
end

local function down_heap(tree, n, u)
  while true do
    local m1 = n * 2
    local m2 = m1 + 1
    local v1 = tree[m1]
    local v2 = tree[m2]
    if v1 and u < v1 then
      if v2 and v1 < v2 then
        tree[m2] = u
        tree[n] = v2
        n = m2
      else
        tree[m1] = u
        tree[n] = v1
        n = m1
      end
    elseif v2 and u < v2 then
      tree[m2] = u
      tree[n] = v2
      n = m2
    else
      break
    end
  end
end

local class = {}
local metatable = { __index = class }

function class:add(id)
  local n = self.n + 1
  self.n = n

  local tree = self.tree
  tree[n] = id
  up_heap(tree, n, id)
end

function class:pop()
  local n = self.n
  self.n = n - 1

  local tree = self.tree
  local id = tree[n]
  local v = tree[1]
  tree[1] = id
  tree[n] = nil
  down_heap(tree, 1, id)
  return v
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      n = 0;
      tree = {};
    }, metatable)
  end;
})
