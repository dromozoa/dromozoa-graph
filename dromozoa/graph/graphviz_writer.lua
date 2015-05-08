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

local function write_attributes(out, attributes)
  out:write(" [")
  for k, v in pairs(attributes) do
    out:write(k, "=", v, ";")
  end
  out:write("]")
end

return {
  write = function (g, out, visitor)
    out:write("digraph \"graph\" {\n")
    local attributes = visitor:graph(g)
    if attributes then
      out:write("  graph")
      write_attributes(out, attributes)
      out:write("\n")
    end
    for u in g:each_vertex() do
      local attributes = visitor:vertex(g, u)
      if attributes then
        out:write("  ", u.id)
        write_attributes(out, attributes)
        out:write("\n")
      end
    end
    for e in g:each_edge() do
      local attributes = visitor:edge(g, e, u, v)
      out:write("  ", e.uid, " -> ", e.vid)
      if attributes then
        write_attributes(out, attributes)
      end
      out:write("\n")
    end
    out:write("}\n")
  end
}
