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

local property_map = require "dromozoa.graph.property_map"

local p = property_map()
p:put("foo", 1, true)
p:put("foo", 2, false)
p:put("foo", 3, 42)

assert(p:get("foo", 1, "foo") == true)
assert(p:get("foo", 2, "foo") == false)
assert(p:get("foo", 3, "foo") == 42)
assert(p:get("foo", 4, "foo") == "foo")

p:remove("foo", 3)
p:remove("foo", 2)
assert(p.dataset.foo ~= nil)
p:remove("foo", 1)
assert(p.dataset.foo == nil)

