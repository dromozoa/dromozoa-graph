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

local element = require "dromozoa.graph.dom.element"
local serialize_html5 = require "dromozoa.graph.dom.serialize_html5"

local _ = element

local element = _"div" {
  foo = "bar";
  baz = "qux";
  "foo bar baz";
  _"strong" { "bold< >?" };
  _"b" { _"u" { "foo" } };
  _"f" { 1, " ", 2, " ", 4 / 2 };
  _"img" { src = "test.png", alt = "代替" };
  _"script" { src = "test.js" };
  _"br";
}
serialize_html5(io.stdout, element)
io.write("\n")
