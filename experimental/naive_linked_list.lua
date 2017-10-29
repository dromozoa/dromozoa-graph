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

local class = {}
local metatable = { __index = class }

function class:add(value)
  local prev_node = self.last

  if not prev_node then
    local node = {
      [1] = value;
    }
    self.n = 1
    self.first = node
    self.last = node
  else
    local node = {
      [1] = value;
      [2] = prev_node;
    }
    self.n = self.n + 1
    self.last = node
    prev_node[3] = node
  end

  return value
end

function class:each(prev_node)
  if not prev_node then
    local node = self.first
    return node, node[1]
  end

  local node = prev_node[3]
  if node then
    return node, node[1]
  end
end

function class:each_bench(v)
  local node = self.first
  repeat
    v = v + node[1]
    node = node[3]
  until not node
  return v
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({ n = 0 }, metatable)
  end;
})
