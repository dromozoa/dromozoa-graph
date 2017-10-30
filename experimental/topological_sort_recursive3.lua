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

local function visit(first, after, target, uid, color, order)
  color[uid] = 1

  local eid = first[uid]
  while eid do
    local vid = target[eid]
    local c = color[vid]
    if not c then
      visit(first, after, target, vid, color, order)
    elseif c == 1 then
      error "not a dag"
    end
    eid = after[eid]
  end

  color[uid] = 0
  order[#order + 1] = uid
end

return function (g, uid, color, order)
  visit(g.first, g.after, g.target, uid, color, order)
end
