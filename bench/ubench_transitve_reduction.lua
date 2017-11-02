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
local transitive_reduction2 = require "experimental.transitive_reduction2"
local transitive_reduction3 = require "experimental.transitive_reduction3"
local transitive_reduction4 = require "experimental.transitive_reduction4"

local N, exec = ...
local N = tonumber(N or 16)

local function run(f, g)
  local remove = f(g)
  return f, g, remove
end

local g = graph()
for i = 1, N * N do
  g:add_vertex()
end
for i = 1, N - 1 do
  for j = 1, N - 1 do
    local aid = i + (j - 1) * N
    local bid = aid + 1
    local cid = aid + N
    local did = cid + 1
    g:add_edge(aid, bid)
    g:add_edge(aid, cid)
    g:add_edge(aid, did)
  end
  local j = N
  local aid = i + (j - 1) * N
  local bid = aid + 1
  g:add_edge(aid, bid)
end
local i = N
for j = 1, N - 1 do
  local aid = i + (j - 1) * N
  local cid = aid + N
  g:add_edge(aid, cid)
end

local algorithms = {
  transitive_reduction2;
  transitive_reduction4;
}

if exec then
  run(algorithms[tonumber(exec)], g)
  return
end

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g }
end

return benchmarks
