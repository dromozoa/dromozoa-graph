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

local function write_attributes(out, attributes, prolog, epilog)
  if attributes then
    if prolog then
      out:write(prolog)
    end
    out:write(" [")
    local first = true
    for k, v in pairs(attributes) do
      if first then
        first = false
      else
        out:write(", ")
      end
      out:write(k, " = ", v)
    end
    out:write("]")
    if epilog then
      out:write(epilog)
    end
  end
end

return function (g, out, visitor)
  out:write("digraph g {\n")
  if visitor then
    write_attributes(out, visitor:graph_attributes(g), "graph", ";\n")
    for u in g:each_vertex() do
      write_attributes(out, visitor:node_attributes(g, u), u.id, ";\n")
    end
    for e in g:each_edge() do
      out:write(e.uid, " -> ", e.vid)
      write_attributes(out, visitor:edge_attributes(g, e))
      out:write(";\n")
    end
  else
    for e in g:each_edge() do
      out:write(e.uid, " -> ", e.vid, ";\n")
    end
  end
 return out:write("}\n")
end
