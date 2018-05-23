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

return function (filename, g)
  local out = assert(io.open(filename, "w"))
  out:write "digraph {\n"
  local uid = g.u.first
  while uid do
    local eid = g.uv.first[uid]
    while eid do
      local vid = g.uv.target[eid]
      out:write(uid, "->", vid, "[label=", eid, "];\n")
      eid = g.uv.after[eid]
    end
    uid = g.u.after[uid]
  end
  out:write "}\n"
  out:close()
end
