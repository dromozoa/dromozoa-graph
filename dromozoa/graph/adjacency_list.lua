-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local clone = require "dromozoa.graph.clone"

local function construct(self, g, a, b, dataset)
  function self:clone(g)
    return construct({}, g, a, b, clone(dataset))
  end

  function self:append_edge(uid, eid)
    local data = dataset[uid]
    if data then
      if type(data) == "table" then
        data[#data + 1] = eid
      else
        dataset[uid] = { data, eid }
      end
    else
      dataset[uid] = eid
    end
  end

  function self:remove_edge(uid, eid)
    local data = dataset[uid]
    if type(data) == "table" then
      for i = 1, #data do
        if data[i] == eid then
          table.remove(data, i)
          if #data == 1 then
            dataset[uid] = data[1]
          end
          return
        end
      end
    else
      if data == eid then
        dataset[uid] = nil
        return
      end
    end
    error "could not remove_edge"
  end

  function self:each_adjacent_vertex(uid)
    local data = dataset[uid]
    if data then
      if type(data) == "table" then
        local i = 0
        return function ()
          i = i + 1
          local e = g._e:get_edge(data[i])
          if e then
            return e[b], e
          end
        end
      else
        return function (_, i)
          if not i then
            local e = g._e:get_edge(data)
            return e[b], e
          end
        end
      end
    else
      return function () end
    end
  end

  function self:count_degree(uid)
    local data = dataset[uid]
    if data then
      if type(data) == "table" then
        return #data
      else
        return 1
      end
    else
      return 0
    end
  end

  return self
end

return function (g, a, b)
  return construct({}, g, a, b, {})
end
