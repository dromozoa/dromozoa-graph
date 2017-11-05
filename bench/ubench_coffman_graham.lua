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
local coffman_graham = require "experimental.coffman_graham"
local coffman_graham2 = require "experimental.coffman_graham2"
local coffman_graham3 = require "experimental.coffman_graham3"
local coffman_graham4 = require "experimental.coffman_graham4"

local N = ...
local N = tonumber(N or 200)

local function run(f, g)
  local result = f(g)
  return f, g, result
end

local g = graph()
local uid1 = g:add_vertex()
local uid2 = g:add_vertex()
local uid3 = g:add_vertex()
local uid4 = g:add_vertex()

for i = 1, N do
  local vid1 = g:add_vertex()
  local vid2 = g:add_vertex()
  local vid3 = g:add_vertex()
  local vid4 = g:add_vertex()

  g:add_edge(uid1, vid1)
  g:add_edge(uid2, vid2)
  g:add_edge(uid3, vid1)
  g:add_edge(uid3, vid2)
  g:add_edge(uid3, vid3)
  g:add_edge(uid4, vid1)
  g:add_edge(uid4, vid2)
  g:add_edge(uid4, vid4)

  uid1 = vid1
  uid2 = vid2
  uid3 = vid3
  uid4 = vid4
end

-- io.write("digraph {\n")
-- local eid = g.e.first
-- while eid do
--   local uid = g.vu.target[eid]
--   local vid = g.uv.target[eid]
--   io.write(uid, "->", vid, ";\n")
--   eid = g.e.after[eid]
-- end
-- io.write("}\n")

local algorithms = {
  -- coffman_graham;
  -- coffman_graham2;
  coffman_graham3;
  coffman_graham4;
}

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g }
end

return benchmarks
