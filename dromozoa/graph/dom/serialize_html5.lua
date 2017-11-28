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

-- https://www.w3.org/TR/html52/syntax.html#void-elements
local void_elements = {
  area = true;
  base = true;
  br = true;
  col = true;
  embed = true;
  hr = true;
  img = true;
  input = true;
  link = true;
  meta = true;
  param = true;
  source = true;
  track = true;
  wbr = true;
}

-- https://www.w3.org/TR/html52/syntax.html#escaping-a-string
local char_table = {
  ["&"] = "&amp;";
  ["\""] = "&quot;";
  ["<"] = "&lt;";
  [">"] = "&gt;";
}
local nbsp = string.char(0xC2, 0xA0) -- U+00A0 NO-BREAK SPACE

local function serialize_html5(out, u)
  local name = u[0]

  local keys = {}
  local n = 0
  local m = 0
  for k, v in pairs(u) do
    local t = type(k)
    if t == "number" then
      if m < k then
        m = k
      end
    elseif t == "string" then
      n = n + 1
      keys[n] = k
    end
  end
  table.sort(keys)

  out:write("<", name)
  for i = 1, n do
    local k = keys[i]
    out:write(" ", k, "=\"", (u[k]:gsub("[&\"]", char_table):gsub(nbsp, "&nbsp;")), "\"")
  end
  out:write(">")

  if not void_elements[name] then
    for i = 1, m do
      local v = u[i]
      local t = type(v)
      if t == "number" then
        out:write(("%.17g"):format(v))
      elseif t == "string" then
        out:write((v:gsub("[&<>]", char_table):gsub(nbsp, "&nbsp;")))
      elseif t == "table" then
        serialize_html5(out, v)
      end
    end
    out:write("</", name, ">")
  end
end

return serialize_html5
