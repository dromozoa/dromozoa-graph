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

local pairs = require "dromozoa.commons.pairs"
local visit = require "dromozoa.commons.visit"

local function write_attributes(out, attributes, prolog, epilog)
  if attributes ~= nil then
    if prolog ~= nil then
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
    if epilog ~= nil then
      out:write(epilog)
    end
  end
end

local function write(out, graph, visitor)
  out:write("digraph g {\n")
  if visitor == nil then
    for u in graph:each_vertex() do
      if u:isolated() then
        out:write(u.id, ";\n")
      end
    end
    for e in graph:each_edge() do
      out:write(e.uid, " -> ", e.vid, ";\n")
    end
  else
    write_attributes(out, visit(visitor, "graph_attributes", graph), "graph", ";\n")
    write_attributes(out, visit(visitor, "default_node_attributes", graph), "node", ";\n")
    for u in graph:each_vertex() do
      local attributes = visit(visitor, "node_attributes", graph, u)
      if attributes ~= nil or u:isolated() then
        out:write(u.id)
        write_attributes(out, attributes)
        out:write(";\n")
      end
    end
    write_attributes(out, visit(visitor, "default_edge_attributes", graph), "edge", ";\n")
    for e in graph:each_edge() do
      out:write(e.uid, " -> ", e.vid)
      write_attributes(out, visit(visitor, "edge_attributes", graph, e))
      out:write(";\n")
    end
  end
  out:write("}\n")
  return out
end

return {
  write = write;
}
