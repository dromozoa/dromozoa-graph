-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local element = require "dromozoa.dom.element"
local xml_document = require "dromozoa.dom.xml_document"
local path_data = require "dromozoa.svg.path_data"
local vecmath = require "dromozoa.vecmath"

local graph = require "dromozoa.graph"
local layout = require "dromozoa.graph.layout"

local _ = element

local root = _"g" {
  _"text" {
    x = 0;
    y = 80;
    ["font-size"] = 72;
    "Lorem ipsum";
  };
  _"text" {
    x = 0;
    y = 160;
    ["font-size"] = 72;
    "墾田永年私財法";
  };
}

local width = 640
local height = 640

local doc = xml_document(_"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  version = "1.1";
  width = width;
  height = height;
  _"style" { [[
@font-face {
  font-family: 'Noto Sans Mono CJK JP';
  src: url('https://dromozoa.s3.amazonaws.com/mirror/NotoSansCJKjp-2017-04-03/NotoSansMonoCJKjp-Regular.otf') format('opentype');
}
text {
  font-family: 'Noto Sans Mono CJK JP';
}
]]
  };
  root;
})

local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
