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

local class = {}

function class.new(mode)
  return {
    mode = mode;
    dataset = {};
  }
end

function class:append_edge(uid, eid)
  local data = self.dataset[uid]
  if data then
    if type(data) == "table" then
      data[#data + 1] = eid
    else
      self.dataset[uid] = { data, eid }
    end
  else
    self.dataset[uid] = eid
  end
end

function class:remove_edge(uid, eid)
  local data = self.dataset[uid]
  if type(data) == "table" then
    for i = 1, #data do
      if data[i] == eid then
        table.remove(data, i)
        if #data == 1 then
          self.dataset[uid] = data[1]
        end
        return
      end
    end
  else
    if data == eid then
      self.dataset[uid] = nil
      return
    end
  end
  error("could not remove edge " .. eid)
end

function class:each_adjacent_vertex(g, uid)
  local data = self.dataset[uid]
  if data then
    if type(data) == "table" then
      return coroutine.wrap(function ()
        for i in ipairs(data) do
          local e = g:get_edge(data[i])
          coroutine.yield(e[self.mode], e)
        end
      end)
    else
      return coroutine.wrap(function ()
        local e = g:get_edge(data)
        coroutine.yield(e[self.mode], e)
      end)
    end
  else
    return function () end
  end
end

function class:count_degree(uid)
  local data = self.dataset[uid]
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

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, mode)
    return setmetatable(class.new(mode), metatable)
  end;
})
