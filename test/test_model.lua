-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local json = require "dromozoa.commons.json"
local model = require "dromozoa.graph.model"
local root = require "dromozoa.graph"

local g = root()

print(g:empty())

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local v4 = g:create_vertex()
local v5 = g:create_vertex()
local e1 = g:create_edge(v1.id, v2.id)
local e2 = g:create_edge(v2.id, v3.id)
-- json.write(io.stdout, g):write("\n")
local e3 = g:create_edge(v2.id, v4.id)
-- g:create_edge(v3, v4)
-- g:create_edge(v3, v5)
-- g:create_edge(v1, v5)

-- for v, e in g:each_adjacent_vertex(v2) do
--   print(v, e)
-- end

assert(g:count_vertex() == 5)
assert(g:count_edge() == 3)

json.write(io.stdout, g):write("\n")
-- g:remove_edge(e3)
-- json.write(io.stdout, g):write("\n")
-- e1:remove()
json.write(io.stdout, g):write("\n")

for v, e in v2:each_adjacent_vertex() do
  print(v.id, e.id)
end
print(v2:count_degree())

print(g:empty())

print("--")

for u in g:each_vertex() do
  print(u)
end

print("--")

for e in g:each_edge() do
  print(e)
end

print("--")

v1:dfs({
  tree_edge = function (_, e, u, v)
    print("tree_edge", u.id, v.id)
  end;
  back_edge = function (_, e, u, v)
    print("back_edge", u.id, v.id)
  end;
  forward_or_cross_edge = function (_, e, u, v)
    print("forward_or_cross_edge", u.id, v.id)
  end;
})

print("--")

local g = root()
local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local e1 = g:create_edge(v1, v1)
print(json.encode(g))
local e2 = g:create_edge(v1, v2)
print(json.encode(g))
local e3 = g:create_edge(v1, v3)
print(json.encode(g))

print(v1:count_degree("u"))
print(v1:count_degree("v"))

