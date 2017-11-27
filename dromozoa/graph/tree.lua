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

local linked_list = require "dromozoa.graph.linked_list"
local node_list = require "dromozoa.graph.node_list"

local class = {}
local metatable = { __index = class }

function class:create_node()
end

function class:remove_node(uid)
end

function class:append_child(uid, vid)
end

function class:remove_child(uid, vid)
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      u = linked_list();
      uv = node_list();
      vu = {};
    }, metatable)
  end;
})
