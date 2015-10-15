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

local sequence_writer = require "dromozoa.commons.sequence_writer"
local xml = require "dromozoa.commons.xml"
local graph = require "dromozoa.graph"

local g = graph()

local v1 = g:create_vertex()
local v2 = g:create_vertex()
local v3 = g:create_vertex()
local v4 = g:create_vertex()
local v5 = g:create_vertex()
local v6 = g:create_vertex()
local v7 = g:create_vertex()

g:create_edge(v1, v2)
g:create_edge(v3, v5)
g:create_edge(v3, v6)
g:create_edge(v1, v4)
g:create_edge(v2, v5)
g:create_edge(v5, v4)

local attributes = {}

function attributes:graph_attributes()
  return { rankdir = "LR" }
end

function attributes:default_node_attributes()
  return {
    style = "filled";
    fillcolor = "gray";
  }
end

function attributes:node_attributes(u)
  if u.id % 2 == 1 then
    return nil
  else
    return {
      color = "blue";
      label = "<node <font color=\"red\">" .. xml.escape(u.id) .. "</font>>";
    }
  end
end

function attributes:default_edge_attributes()
  return {
    color = "blue";
    fontcolor = "red";
  }
end

function attributes:edge_attributes(e)
  return {
    label = "<edge<br/>" .. xml.escape(e.id) .. ">";
  }
end

local data = g:write_graphviz(sequence_writer()):concat()
assert(not data:find("\n" .. v1.id .. ";"))
assert(data:find("\n" .. v7.id .. ";"))
local data = g:write_graphviz(sequence_writer(), attributes):concat()
assert(not data:find("\n" .. v1.id .. ";"))
assert(data:find("\n" .. v7.id .. ";"))
local out = assert(io.open("test.dot", "w"))
out:write(data)
out:close()
