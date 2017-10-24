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

local dfs = require "dromozoa.graph.dfs"
local dfs_visit = require "dromozoa.graph.dfs_visit"

local class = {}
local metatable = { __index = class }

function class:back_edge()
  error("not a dag")
end

function class:finish_vertex(uid)
  self[#self + 1] = uid
end

return function (g, uid)
  local that = {}
  if uid then
    dfs_visit(g, setmetatable(that, metatable), uid, {})
  else
    dfs(g, setmetatable(that, metatable))
  end
  return that
end
