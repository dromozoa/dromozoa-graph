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

-- https://www.w3.org/TR/DOM-Parsing/#dfn-concept-serialize-attr-value
local char_table = {
  ["&"] = "&amp;";
  ["\""] = "&quot;";
  ["<"] = "&lt;";
  [">"] = "&gt;";
}

local function serialize_xml(out, u)
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
    local v = u[k]
    if type(v) == "number" then
      v = ("%.17g"):format(v)
    end
    out:write(" ", k, "=\"", (v:gsub("[&\"]", char_table)), "\"")
  end

  if m == 0 then
    out:write("/>")
  else
    out:write(">")
    for i = 1, m do
      local v = u[i]
      local t = type(v)
      if t == "number" then
        out:write(("%.17g"):format(v))
      elseif t == "string" then
        out:write((v:gsub("[&<>]", char_table)))
      elseif t == "table" then
        serialize_xml(out, v)
      end
    end
    out:write("</", name, ">")
  end
end

return serialize_xml
