local graph = require "dromozoa.graph"

local g = graph()

local u = g:create_vertex()
local v = g:create_vertex()

g:create_edge(u, v).color = 17
u, v = v, g:create_vertex()
g:create_edge(u, v).color = 23
u, v = v, g:create_vertex()
g:create_edge(u, v).color = 37

for e in g:each_edge() do
  print(e.u.id, e.v.id, e.color)
end
