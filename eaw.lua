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

-- https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt

for line in io.lines() do
  local a, b, p = line:match("^(%x+)%.%.(%x+);(%a+)")
  if not a then
    a, p = line:match("^(%x+);(%a+)")
    b = a
  end
  if a then
    print(a, b, p)
  end
end
