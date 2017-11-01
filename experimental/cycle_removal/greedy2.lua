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

local function greedy_linear_ordering(g)
--[[
color 削除済みかどうか
sink
source
heap: out_degree - in_degreeを最大化するようなヒープ

for each vertex v do
  if v is sink vertex then
    add to sink
  elseif v is source vertex then
    add to source
  else
    add to heap
  end
end






]]





end

return function (g)
  local order = greedy_linear_ordering(g)
end