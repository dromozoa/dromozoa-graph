local graph = require "dromozoa.graph"

local g = graph()

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local v4 = g:create_vertex()

g:create_edge(v1, v2)
g:create_edge(v1, v3)
g:create_edge(v2, v4)
g:create_edge(v3, v4)

for v, e in g:each_neighbor(v2, "v") do
  print(v.id, e.uid, e.vid)
end
