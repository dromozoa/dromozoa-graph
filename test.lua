local graph = require "dromozoa.graph"

local g = graph()

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()

assert(v1:count_degree("u") == 0)
assert(v1:count_degree("v") == 0)

local result = {}
for v, e in v1:each_adjacent_vertex() do result[#result + 1] = { v, e } end
assert(#result == 0)

local e1 = g:create_edge(v1, v1)

assert(v1:count_degree("u") == 1)
assert(v1:count_degree("v") == 1)

local result = {}
for v, e in v1:each_adjacent_vertex() do result[#result + 1] = { v, e } end
assert(#result == 1)
assert(result[1][1].id == 1)

local e2 = g:create_edge(v1, v2)

assert(v1:count_degree("u") == 2)
assert(v1:count_degree("v") == 1)

local result = {}
for v, e in v1:each_adjacent_vertex() do result[#result + 1] = { v, e } end
assert(#result == 2)
assert(result[1][1].id == 1)
assert(result[2][1].id == 2)

local e3 = g:create_edge(v1, v3)

assert(v1:count_degree("u") == 3)
assert(v1:count_degree("v") == 1)

local result = {}
for v, e in v1:each_adjacent_vertex() do result[#result + 1] = { v, e } end
assert(#result == 3)
assert(result[1][1].id == 1)
assert(result[2][1].id == 2)
assert(result[3][1].id == 3)

assert(v2:count_degree("u") == 0)
assert(v2:count_degree("v") == 1)
e2.removed = true
e2:remove()
assert(v2:count_degree("u") == 0)
assert(v2:count_degree("v") == 0)

v1.start = true
local count = 0
for v in g:each_vertex("start") do
  assert(v.id == 1)
  count = count + 1
end
assert(count == 1)

e1.color = 1
e3.color = 3
local count = 0
for e in g:each_edge("color") do
  assert(e.id == e.color)
  count = count + 1
end
assert(count == 2)

v3.accept = true
v1.start = nil
local count = 0
for k in g:each_vertex_property_key() do
  assert(k == "accept")
  count = count + 1
end
assert(count == 1)

local count = 0
for k in g:each_edge_property_key() do
  assert(k == "color")
  count = count + 1
end
assert(count == 1)

g:clear_edge_properties("color")

local count = 0
for k in g:each_edge_property_key() do
  count = count + 1
end
assert(count == 0)
