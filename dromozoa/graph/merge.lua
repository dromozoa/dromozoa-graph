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

local clone = require "dromozoa.commons.clone"

return function (this, that)
  local map = {}
  for a in that:each_vertex() do
    local b = this:create_vertex()
    map[a.id] = b.id
    for k, v in a:each_property() do
      b[clone(k)] = clone(v)
    end
  end
  for a in that:each_edge() do
    local b = this:create_edge(map[a.uid], map[a.vid])
    for k, v in a:each_property() do
      b[clone(k)] = clone(v)
    end
  end
end
