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

local class = {}
local metatable = { __index = class }

-- https://www.w3.org/TR/html5/syntax.html#serializing-html-fragments
local char_table = {
  ["&"] = "&amp;";
  ["<"] = "&lt;";
  [">"] = "&gt;";
}
local nbsp = string.char(0xC2, 0xA0)

local function escape(s)
  return (s:gsub("[&<>]", char_table):gsub(nbsp, "&nbsp;"))
end

function class:serialize_html5(out)
  out:write(escape(self.doc.text_map[self.uid]))
end

return setmetatable(class, {
  __call = function (_, doc, uid)
    return setmetatable({
      doc = doc;
      uid = uid;
    }, metatable)
  end;
})
