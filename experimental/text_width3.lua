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

local utf8 = require "dromozoa.utf8"
local east_asian_width = require "experimental.east_asian_width_utf8"

local width_map = {
  ["N"]  = 1; -- neutral
  ["Na"] = 1; -- narrow
  ["H"]  = 1; -- halfwidth
  ["A"]  = 2; -- ambiguous
  ["W"]  = 2; -- wide
  ["F"]  = 2; -- fullwidth
}

local byte = string.byte

return function (s)
  local i = 1
  local w = 0
  while true do
    local a, b, c, d = byte(s, i, i + 3)
    if not a then
      return w
    end
    if a <= 0xDF then
      if a <= 0x7F then
        i = i + 1
        w = w + width_map[east_asian_width(a)]
      else
        i = i + 2
        w = w + width_map[east_asian_width(a * 0x100 + b)]
      end
    else
      if a <= 0xEF then
        i = i + 3
        w = w + width_map[east_asian_width(a * 0x10000 + b * 0x100 + c)]
      else
        i = i + 4
        w = w + width_map[east_asian_width(a * 0x1000000 + b * 0x10000 + c * 0x100 + d)]
      end
    end
  end
end
