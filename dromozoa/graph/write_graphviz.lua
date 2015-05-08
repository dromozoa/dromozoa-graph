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

local function writer(_g, _out)
  local self = {}

  function self:write_attributes(prolog, epilog, attributes)
    if attributes then
      _out:write(prolog, " [")
      for k, v in pairs(attributes) do
        _out:write(k, " = ", v, ";")
      end
      _out:write("]", epilog)
    end
  end

  function self:write(visitor)
    _out:write("digraph \"graph\" {\n")
    self:write_attributes("graph", ";\n", visitor:graph_attributes(g))
    self:write_attributes("node", ";\n", visitor:node_attributes(g))
    self:write_attributes("edge", ";\n", visitor:edge_attributes(g))
    for u in _g:each_vertex() do
      self:write_attributes(u.id, ";\n", visitor:each_node_attributes(g, u))
    end
    for e in _g:each_edge() do
      _out:write(e.uid, " -> ", e.vid)
      self:write_attributes("", "", visitor:each_edge_attributes(g, e))
      _out:write(";\n")
    end
    _out:write("}\n")
  end

  return self
end

return function (g, out, visitor)
  writer(g, out):write(visitor)
  return out
end
