local graph = require "dromozoa.graph"

local g = graph()

local u = g:create_vertex()
local v = g:create_vertex()
local w = g:create_vertex()

g:create_edge(u.id, v.id)
g:create_edge(u.id, w.id)

for e in g:each_neighbor(u) do
  print(e.u.id, e.v.id)
end
