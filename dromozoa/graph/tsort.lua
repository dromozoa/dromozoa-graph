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

local function tsort_visitor(_result)
  local self = {}

  function self:back_edge(g, e, u, v)
    error("found back edge " .. e.id)
  end

  function self:finish_vertex(g, u)
    _result[#_result + 1] = u
  end

  return self
end

return function (g, mode)
  local result = {}
  g:dfs(tsort_visitor(result), mode)
  return result
end
