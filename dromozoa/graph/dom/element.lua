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

-- https://www.w3.org/TR/html5/syntax.html#void-elements
local void_elements = {
  area = true;
  base = true;
  br = true;
  col = true;
  embed = true;
  hr = true;
  img = true;
  input = true;
  keygen = true;
  link = true;
  meta = true;
  param = true;
  source = true;
  track = true;
  wbr = true;
}

-- https://www.w3.org/TR/html5/syntax.html#serializing-html-fragments
local char_table = {
  ["&"] = "&amp;";
  ["\""] = "&quot;";
}
local nbsp = string.char(0xC2, 0xA0)

local function escape(s)
  return (s:gsub("[&\"]", char_table):gsub(nbsp, "&nbsp;"))
end

function class:set_attribute(key, value)
  self.doc:set_attribute(self.uid, key, value)
end

function class:append_child(that)
  self.doc:append_child(self.uid, that.uid)
end

function class:serialize_html5(out)
  local doc = self.doc
  local uid = self.uid
  local name = doc.name_map[uid]
  local attr = doc.attr_map[uid]
  local uv = doc.tree.uv
  local uv_first = uv.first
  local uv_after = uv.after

  out:write("<", name)
  if attr then
    for k, v in pairs(attr) do
      out:write(" ", escape(k), "=\"", escape(v), "\"")
    end
  end
  out:write(">")
  if not void_elements[name] then
    local vid = uv_first[uid]
    while vid do
      doc(vid):serialize_html5(out)
      vid = uv_after[vid]
    end
    out:write("</", name, ">")
  end
end

function metatable:__call(t)
  local doc = self.doc

  for k, v in pairs(t) do
    if type(k) == "string" then
      self:set_attribute(k, v)
    else
      if type(v) == "string" then
        self:append_child(doc:create_text_node(v))
      else
        self:append_child(v)
      end
    end
  end

  return self
end

return setmetatable(class, {
  __call = function (_, doc, uid)
    return setmetatable({
      doc = doc;
      uid = uid;
    }, metatable)
  end;
})
