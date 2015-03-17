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

local graph = require "dromozoa.graph"
local dfs_visitor = require "dromozoa.graph.dfs_visitor"

local g = graph()

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local v4 = g:create_vertex()
local v5 = g:create_vertex()

g:create_edge(v1, v2)
g:create_edge(v2, v2)
g:create_edge(v2, v3)
g:create_edge(v3, v2)
g:create_edge(v1, v4)
g:create_edge(v5, v4)

g:dfs(dfs_visitor {
  tree_edge = function (ctx, g, e, u, v)
    print("tree_edge", u.id, v.id)
  end;
  back_edge = function (ctx, g, e, u, v)
    print("back_edge", u.id, v.id)
  end;
  forward_or_cross_edge = function (ctx, g, e, u, v)
    print("forward_or_cross_edge", u.id, v.id)
  end;
})

local g = graph()

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local v4 = g:create_vertex()
local v5 = g:create_vertex()

g:create_edge(v1, v2)
g:create_edge(v1, v3)
g:create_edge(v2, v4)
g:create_edge(v3, v5)

local result = {}
v1:dfs(dfs_visitor {
  discover_vertex = function (ctx, g, u)
    result[#result + 1] = u.id
  end;
})
assert(result[1] == 1)
assert(result[2] == 2)
assert(result[3] == 4)
assert(result[4] == 3)
assert(result[5] == 5)

local result = {}
v1:dfs(dfs_visitor {
  examine_edge = function (ctx, g, e, u, v)
    return e.id ~= 1
  end;
  discover_vertex = function (ctx, g, u)
    result[#result + 1] = u.id
  end;
})
assert(result[1] == 1)
assert(result[2] == 3)
assert(result[3] == 5)
