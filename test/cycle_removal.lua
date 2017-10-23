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

local bigraph = require "dromozoa.graph.bigraph"
local cycle_removal = require "dromozoa.graph.greedy_cycle_removal"

local filename = ...

local g = bigraph()

local handle = assert(io.open(filename))

local n = handle:read("n")
for i = 1, n do
  g:add_vertex()
end

while true do
  local u = handle:read("n")
  local v = handle:read("n")
  if not v then
    break
  end
  g:add_edge(u, v)
end

handle:close()

cycle_removal(g)
