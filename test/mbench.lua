-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local graph = require "dromozoa.graph"
-- local gettimeofday = require "dromozoa.ubench.gettimeofday"
-- local root = require "dromozoa.graph.root"

local vn = 0
local en = 0

local function append(g, u, i)
  i = i - 1
  if i == 0 then
    return g
  else
    for j = 1, 8 do
      local v = g:create_vertex()
      vn = vn + 1
      g:create_edge(u.id, v.id)
      en = en + 1
      g:create_edge(v.id, u.id)
      en = en + 1
      append(g, v, i)
    end
  end
end

collectgarbage()
collectgarbage()
local memory1 = collectgarbage("count")

-- local tv1 = gettimeofday()
local g = graph()
append(g, g:create_vertex(), 7)
vn = vn + 1
-- local tv2 = gettimeofday()

collectgarbage()
collectgarbage()
local memory2 = collectgarbage("count")

print(memory2 - memory1)
-- print((tv2.tv_sec - tv1.tv_sec) + (tv2.tv_usec - tv1.tv_usec) * 0.000001)

print(vn, en, 28 * (vn * 2 + en * 4) / 1024)
