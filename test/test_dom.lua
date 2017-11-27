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

local document = require "dromozoa.graph.dom.document"

local doc = document()
local _ = doc:builder()

-- print(doc:create_element "div")

local element = _"div" {
  foo = "bar";
  baz = "qux";
  "foo bar baz";
  _"strong" { "bold?" };
}

-- local element = doc:create_element("div")
-- element:set_attribute("foo", "bar")
-- element:set_attribute("baz", "qux")
-- element:append_child(doc:create_text_node "foo bar baz")
element:serialize_html5(io.stdout)
io.write("\n")

doc:create_text_node("<foo\194\160>"):serialize_html5(io.stdout)
io.write("\n")

-- local element = _"div" {
--   class = "foo bar baz";
--   "foo";
--   "bar";
--   "baz";
-- }

-- _"div"
--   + _("class", "foo bar")
--   + _("style", "display: none")
--   + "text node"

