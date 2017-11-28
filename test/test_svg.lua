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
local serialize_xml = require "dromozoa.graph.dom.serialize_xml"

local _ = element

local svg = _"svg" {
  version = "1.1"; width = 600; height = 600; xmlns = "http://www.w3.org/2000/svg";
  _"style" { [[
    @font-face {
      font-family: 'Noto Sans Mono CJK JP';
      font-style: normal;
      font-weight: 400;
      src: url('https://dromozoa.s3.amazonaws.com/mirror/NotoSansCJKjp-2017-04-03/NotoSansMonoCJKjp-Regular.otf') format('opentype');
    }
    text {
      font-family: 'Noto Sans Mono CJK JP';
      font-weight: 400;
      dominant-baseline: central;
      text-anchor: middle;
    }
  ]] };
  _"circle" { cx = 300; cy = 300; r = 100; stroke = "black"; fill = "white" };
  _"text" {
    x = 300; y = 300; stroke = "none"; fill = "black";
    "ABC日本語";
  };
}
serialize_xml(io.stdout, svg)
io.write("\n")
