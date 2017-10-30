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

return function (g, uid, color, order)
  local last = g.last
  local before = g.before
  local target = g.target

  local stack1 = {}
  local stack2 = {}
  local n1 = 0
  local n2 = 0

  color[uid] = 1

  local eid = last[uid]
  while eid do
    n1 = n1 + 1
    stack1[n1] = eid
    eid = before[eid]
  end

  while n1 > 0 do
    local eid = stack1[n1]
    local vid = target[eid]
    local c = color[vid]

    if eid ~= stack2[n2] then
      if not c then
        color[vid] = 1
        local eid2 = last[vid]
        while eid2 do
          n1 = n1 + 1
          stack1[n1] = eid2
          eid2 = before[eid2]
        end
      elseif c > 0 then
        error "not a dag"
      end
      n2 = n2 + 1
      stack2[n2] = eid
    else
      -- stack1[n1] = nil
      -- stack2[n2] = nil
      n1 = n1 - 1
      n2 = n2 - 1

      if c == 1 then
        color[vid] = 0
        order[#order + 1] = vid
      elseif c > 1 then
        color[vid] = c - 1
      end
    end
  end

  color[uid] = 0
  order[#order + 1] = uid
end
