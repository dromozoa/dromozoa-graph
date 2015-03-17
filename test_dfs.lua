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
