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

local tree = require "dromozoa.graph.tree"
local builder = require "dromozoa.graph.dom.builder"
local element = require "dromozoa.graph.dom.element"
local text_node = require "dromozoa.graph.dom.text_node"

local class = {}
local metatable = { __index = class }

function class:builder()
  return builder(self)
end

function class:create_element(name)
  -- check name
  local uid = self.tree:add_vertex()
  self.name_map[uid] = name
  return element(self, uid)
end

function class:create_text_node(text)
  local uid = self.tree:add_vertex()
  self.text_map[uid] = text
  return text_node(self, uid)
end

function class:set_attribute(uid, key, value)
  local attr_map = self.attr_map
  local attr = attr_map[uid]
  if not attr then
    attr_map[uid] = { [key] = value }
  else
    attr[key] = value
  end
end

function class:append_child(uid, vid)
  self.tree:add_edge(uid, vid)
end

function metatable:__call(uid)
  if self.name_map[uid] then
    return element(self, uid)
  elseif self.text_map[uid] then
    return text_node(self, uid)
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({
      tree = tree();
      name_map = {};
      attr_map = {};
      text_map = {};
    }, metatable)
  end;
})
