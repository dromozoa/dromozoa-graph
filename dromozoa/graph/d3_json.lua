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

local json = require "dromozoa.commons.json"
local visit = require "dromozoa.graph.visit"

local function write_attributes(out, attributes)
  if attributes == nil then
    out:write("{}")
  else
    json.write(out, attributes)
  end
end

local function write(out, g, visitor)
  local map = {}

  out:write("{\"nodes\":[")

  local first = true
  local n = 0
  for u in g:each_vertex() do
    if first then
      first = false
    else
      out:write(",")
    end
    local attrbutes = visit(visitor, "node_attributes", g, u)
    if attrbutes == nil then
      io.write("{}")
    else
      json.write(out, attrbutes)
    end
    map[u.id] = n
    n = n + 1
  end
  out:write("],\"links\":[")

  local first = true
  for e in g:each_edge() do
    if first then
      first = false
    else
      out:write(",")
    end
    local attrbutes = visit(visitor, "link_attributes", g, e)
    if attrbutes == nil then
      attrbutes = {}
    end
    attrbutes.source = map[e.uid]
    attrbutes.target = map[e.vid]
    json.write(out, attrbutes)
  end

  out:write("]}")
  return out
end

return {
  write = write;
}
