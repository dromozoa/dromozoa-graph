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

local function construct(_g, _mode, _dataset)
  local _e = _g._e

  local self = {}

  function self:clone(g)
    return construct(g, _mode, clone(_dataset))
  end

  function self:append_edge(uid, eid)
    local data = _dataset[uid]
    if data then
      if type(data) == "table" then
        data[#data + 1] = eid
      else
        _dataset[uid] = { data, eid }
      end
    else
      _dataset[uid] = eid
    end
  end

  function self:remove_edge(uid, eid)
    local data = _dataset[uid]
    if type(data) == "table" then
      for i = 1, #data do
        if data[i] == eid then
          table.remove(data, i)
          if #data == 1 then
            _dataset[uid] = data[1]
          end
          return
        end
      end
    else
      if data == eid then
        _dataset[uid] = nil
        return
      end
    end
    error("could not remove edge " .. eid)
  end

  function self:each_adjacent_vertex(uid)
    local data = _dataset[uid]
    if data then
      if type(data) == "table" then
        local index = 0
        return function ()
          local i = index + 1
          index = i
          local e = _e:get_edge(data[i])
          if e then
            return e[_mode], e
          end
        end
      else
        return function (_, i)
          if not i then
            local e = _e:get_edge(data)
            return e[_mode], e
          end
        end
      end
    else
      return function () end
    end
  end

  function self:count_degree(uid)
    local data = _dataset[uid]
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

return function (g, mode)
  return construct(g, mode, {})
end
