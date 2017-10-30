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

local layer, count, mode = ...
local layer = tonumber(layer)
local count = tonumber(count)

local v = 1
local e = 0

local uv = {
  first = {};
  last = {};
  before = {};
  after = {};
  edge = {};
}

local vu = {
  first = {};
  last = {};
  before = {};
  after = {};
  edge = {};
}

local function add_edge_cycle(g, e, u, v)
  local next_e = g.first[u]
  if not next_e then
    g.first[u] = e
    g.before[e] = e
    g.after[e] = e
    g.edge[e] = v
  else
    local prev_e = g.before[next_e]
    g.before[e] = prev_e
    g.before[next_e] = e
    g.after[prev_e] = e
    g.after[e] = next_e
    g.edge[e] = v
  end
end

local function add_edge_term1(g, e, u, v)
  local prev_e = g.last[u]
  if not prev_e then
    g.first[u] = e
    g.last[u] = e
    g.edge[e] = v
  else
    g.last[u] = e
    g.before[e] = prev_e
    -- g.before[next_e] = nil
    g.after[prev_e] = e
    -- g.after[e] = nil
    g.edge[e] = v
  end
end

local function add_edge_term2(g, e, u, v)
  local prev_e = g.last[u]
  if not prev_e then
    g.first[u] = e
    g.last[u] = e
    g.edge[e] = v
  else
    g.last[u] = e
    g.before[e] = prev_e
    g.after[prev_e] = e
    g.after[e] = false
    g.edge[e] = v
  end
end

local function make(l, u)
  l = l + 1
  for i = 1, count do
    v = v + 1
    e = e + 1
    if mode == "cycle" then
      add_edge_cycle(uv, e, u, v)
      add_edge_cycle(vu, e, v, u)
    elseif mode == "term1" then
      add_edge_term1(uv, e, u, v)
      add_edge_term1(vu, e, v, u)
    elseif mode == "term2" then
      add_edge_term2(uv, e, u, v)
      add_edge_term2(vu, e, v, u)
    end

    if l <= layer then
      make(l, v)
    end
  end
end

collectgarbage() collectgarbage() local c1 = collectgarbage "count"
make(1, 1)
collectgarbage() collectgarbage() local c2 = collectgarbage "count"

print(v, e, c2 - c1)

