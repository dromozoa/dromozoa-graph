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
local east_asian_width_lexer = require "experimental.east_asian_width_lexer"

local width_map = {
  ["N"]  = 1; -- neutral
  ["Na"] = 1; -- narrow
  ["H"]  = 1; -- halfwidth
  ["A"]  = 2; -- ambiguous
  ["W"]  = 2; -- wide
  ["F"]  = 2; -- fullwidth
}

local accept_map = {
  [1] = 1; -- neutral
  [2] = 1; -- narrow
  [3] = 1; -- halfwidth
  [4] = 2; -- ambiguous
  [5] = 2; -- wide
  [6] = 2; -- fullwidth
}

local byte = string.byte

local lexer = east_asian_width_lexer().lexers[1]
local automaton = lexer.automaton
local transitions = automaton.transitions
local start_state = automaton.start_state
local accept_states = automaton.accept_states

return function (s)
  local n = #s
  local w = 0
  local state = start_state

  for i = 4, n, 4 do
    local a, b, c, d = byte(s, i - 3, i)
    state = transitions[a][state]
    local accept = accept_states[state]
    if accept then
      w = w + accept_map[accept]
      state = start_state
    end
    state = transitions[b][state]
    local accept = accept_states[state]
    if accept then
      w = w + accept_map[accept]
      state = start_state
    end
    state = transitions[c][state]
    local accept = accept_states[state]
    if accept then
      w = w + accept_map[accept]
      state = start_state
    end
    state = transitions[d][state]
    local accept = accept_states[state]
    if accept then
      w = w + accept_map[accept]
      state = start_state
    end
  end

  local p = n + 1
  local m = p - (p - 1) % 4
  if m < p then
    local a, b, c = byte(s, m, n)
    if c then
      state = transitions[a][state]
      local accept = accept_states[state]
      if accept then
        w = w + accept_map[accept]
        state = start_state
      end
      state = transitions[b][state]
      local accept = accept_states[state]
      if accept then
        w = w + accept_map[accept]
        state = start_state
      end
      state = transitions[c][state]
      local accept = accept_states[state]
      if accept then
        w = w + accept_map[accept]
        state = start_state
      end
    elseif b then
      state = transitions[a][state]
      local accept = accept_states[state]
      if accept then
        w = w + accept_map[accept]
        state = start_state
      end
      state = transitions[b][state]
      local accept = accept_states[state]
      if accept then
        w = w + accept_map[accept]
        state = start_state
      end
    else
      state = transitions[a][state]
      local accept = accept_states[state]
      if accept then
        w = w + accept_map[accept]
        state = start_state
      end
    end
  end

  return w
end
