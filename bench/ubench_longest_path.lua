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

local graph = require "dromozoa.graph"
local longest_path = require "dromozoa.graph.longest_path"
local longest_path2 = require "experimental.longest_path2"

local N = 200

local function run(f, g)
  local result = f(g)
  return f, g, result
end

local g = graph()
local uid = g:add_vertex()
for i = 1, N do
  local vid1 = g:add_vertex()
  local vid2 = g:add_vertex()
  local vid3 = g:add_vertex()

  g:add_edge(uid, vid1)
  g:add_edge(uid, vid2)
  g:add_edge(vid1, vid3)
  g:add_edge(vid2, vid3)

  uid = vid3
end

local algorithms = {
  longest_path;
  longest_path2;
}

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g }
end

return benchmarks
