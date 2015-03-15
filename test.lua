local graph = require "dromozoa.graph"

local g = graph()

g:new_vertex():set_property("color", 1)
g:new_vertex():set_property("foo", 2)
g:new_vertex():set_property("color", 3)

for v in g:each_vertex() do
  print(v:get_id(), v:get_property("color"), v:get_property("foo"))
end
