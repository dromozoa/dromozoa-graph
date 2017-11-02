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

local graph = require "dromozoa.graph"
local topological_sort = require "dromozoa.graph.topological_sort"
local topological_sort2 = require "experimental.topological_sort_recursive5"

local layer, count, do_check = ...
local layer = tonumber(layer or 6) -- 6 or 14
local count = tonumber(count or 4) -- 4 or 2

local g = graph()
local vn = 0
local eid = 0

local function make(g, l)
  if l == 1 then
    local vid_first = vn + 1
    local vid_last = vn + count
    local uid = vid_last + 1
    vn = uid
    for vid = vid_first, vid_last do
      local new_vid = g:add_vertex()
      assert(vid == new_vid)
    end
    local new_uid = g:add_vertex()
    assert(uid == new_uid)
    for vid = vid_first, vid_last do
      eid = eid + 1
      local new_eid = g:add_edge(uid, vid)
      assert(eid == new_eid)
    end
    return uid
  else
    local vids = {}
    for i = 1, count do
      vids[i] = make(g, l - 1)
    end
    local uid = vn + 1
    vn = uid
    local new_uid = g:add_vertex()
    assert(uid == new_uid)
    for i = 1, count do
      eid = eid + 1
      local new_eid = g:add_edge(uid, vids[i])
      assert(eid == new_eid)
    end
    return uid
  end
end

make(g, layer)

local function run(f, g)
  local order = f(g.u, g.uv)
  return f, g, order
end

local function check(f, g)
  local order = f(g.u, g.uv)
  for i = 1, g.u.n do
    assert(order[i] == i)
  end
end

io.stderr:write(g.u.n, "\n")

local algorithms = {
  topological_sort;
  topological_sort2;
}

if do_check and do_check ~= "false" then
  for i = 1, #algorithms do
    check(algorithms[i], g)
  end
end

local benchmarks = {}

for i = 1, #algorithms do
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], g }
end

return benchmarks
