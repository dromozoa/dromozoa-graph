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

-- https://www.w3.org/TR/html5/syntax.html#void-elements
-- https://www.w3.org/TR/html51/syntax.html#void-elements
-- https://www.w3.org/TR/html52/syntax.html#void-elements
return {
  area = true;
  base = true;
  br = true;
  col = true;
  embed = true;
  hr = true;
  img = true;
  input = true;
  keygen = true; -- removed from HTML 5.2
  link = true;
  meta = true;
  param = true;
  source = true;
  track = true;
  wbr = true;
}
