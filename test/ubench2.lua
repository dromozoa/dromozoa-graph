-- Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local adjacency_list = require "dromozoa.graph.adjacency_list"
local topological_sort_recursive = require "experimental.topological_sort_recursive"
local topological_sort_recursive2 = require "experimental.topological_sort_recursive2"
local topological_sort_recursive3 = require "experimental.topological_sort_recursive3"
local topological_sort_recursive4 = require "experimental.topological_sort_recursive4"
local topological_sort_stack = require "experimental.topological_sort_stack"

local layer, count, mode = ...
local layer = tonumber(layer or 6) -- 6 or 14
local count = tonumber(count or 4) -- 4 or 2

local g = adjacency_list()
local vn = 0
local eid = 0

local function make(g, l)
  if l == 1 then
    local vid_first = vn + 1
    local vid_last = vn + count
    local uid = vid_last + 1
    vn = uid
    for vid = vid_first, vid_last do
      eid = eid + 1
      g:add_edge(eid, uid, vid)
    end
    return uid
  else
    local vids = {}
    for i = 1, count do
      vids[i] = make(g, l - 1)
    end
    local uid = vn + 1
    vn = uid
    for i = 1, count do
      eid = eid + 1
      g:add_edge(eid, uid, vids[i])
    end
    return uid
  end
end

local sid = make(g, layer)

local function run(f, g, sid)
  local order = {}
  f(g, sid, {}, order)
  return f, g, sid, order
end

local function check(f, g, sid)
  local order = {}
  f(g, sid, {}, order)
  for i = 1, sid do
    assert(order[i] == i)
  end
end

local algorithms = {
  topological_sort_recursive;
  topological_sort_recursive2;
  topological_sort_recursive3;
  topological_sort_recursive4;
  topological_sort_stack;
}

for i = 1, #algorithms do
  check(algorithms[i], g, sid)
end

io.stderr:write(sid, "\n")

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g, sid }
end

return benchmarks
