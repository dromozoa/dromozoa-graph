local graph = require "dromozoa.graph"
local bfs_visitor = require "dromozoa.graph.bfs_visitor"

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

v1:bfs(bfs_visitor {
  tree_edge = function (ctx, g, e, u, v)
    print("tree_edge", u.id, v.id)
  end;
  gray_target = function (ctx, g, e, u, v)
    print("gray_target", u.id, v.id)
  end;
  black_target = function (ctx, g, e, u, v)
    print("black_target", u.id, v.id)
  end;
})
