local graph = require "dromozoa.graph"

local g = graph()

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local v4 = g:create_vertex()

local e1 = g:create_edge(v1, v2)
local e2 = g:create_edge(v1, v3)
local e3 = g:create_edge(v2, v4)
local e4 = g:create_edge(v3, v4)

for v in g:each_vertex() do
  print(v.id, v:count_neighbor(), v:count_neighbor("v"))
end

print("--")

for v, e in g:each_neighbor(v1) do
  print(v.id, e.uid, e.vid)
end
