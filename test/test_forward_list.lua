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

local dumper = require "dromozoa.commons.dumper"
local forward_list = require "dromozoa.graph.forward_list"

local x = forward_list()
x:add_first() -- 1
x:add_first() -- 2,1
x:insert_after(2) -- 2,3,1
x:insert_after(1) -- 2,3,1,4
x:add() -- 2,3,1,4,5

x:remove_after(2) -- 2,1,4,5
x:remove_after(4) -- 2,1,4
x:remove_first() -- 1,4
x:remove_first() -- 4
x:remove_first() -- {}

print(dumper.encode(x, { stable = true }))

x:add()
x:add()
x:add()
x:add()
x:add() -- 6,7,8,9,10

local prev_id
local id = x.head
repeat
  print(id)

  if id == 8 then
    id = x:remove_after(prev_id)
  else
    prev_id = id
    id = x[id]
  end
until not id

print("--")

local id = x.head
repeat
  print(id)
  id = x[id]
until not id
