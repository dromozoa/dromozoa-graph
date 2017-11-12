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

local function weighted_median(vu, layer, layer_index, layer_first, layer_last, layer_step)
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  local eids = {}

  for i = layer_first, layer_last, layer_step do
    local uids = layer[i]
    local un = #uids

    for j = 1, un do
      local uid = uids[j]
      local en = 0

      local eid = vu_first[uid]
      while eid do
        en = en + 1
        eids[en] = eid
        eid = vu_after[eid]
      end



    end


    print(table.concat(uids, " "))

  end
end

return function (g, layer)
  local uv = g.uv
  local vu = g.vu

  local layer_max = #layer

  weighted_median(vu, layer, {}, layer_max, 1, -1)
end
