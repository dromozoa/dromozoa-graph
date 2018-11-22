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

local class = {}
local metatable = { __index = class }

function class:dfs(uv_first, uv_after, uv_target, vid, n)
  local parent = self.parent
  local semi = self.semi

  n = n + 1

  semi[vid] = n
  self.vertex[n] = vid
  self.label[vid] = vid
  self.ancestor[vid] = 0
  self.child[vid] = 0
  self.size[vid] = 1

  local eid = uv_first[vid]
  while eid do
    local wid = uv_target[eid]
    if semi[wid] == 0 then
      parent[wid] = vid
      n = self:dfs(uv_first, uv_after, uv_target, wid, n)
    end
    eid = uv_after[eid]
  end

  return n
end

function class:compress(vid)
  local ancestor = self.ancestor
  local label = self.label
  local semi = self.semi

  local ancestor_vid = ancestor[vid]
  if ancestor[ancestor_vid] ~= 0 then
    self:compress(ancestor_vid)
    local ancestor_vid = ancestor[vid]
    local label_ancestor_vid = label[ancestor_vid]
    if semi[label_ancestor_vid] < semi[label[vid]] then
      label[vid] = label_ancestor_vid
    end
    ancestor[vid] = ancestor[ancestor_vid]
  end
end

function class:eval(vid)
  local ancestor = self.ancestor
  local label = self.label
  local semi = self.semi

  if ancestor[vid] == 0 then
    return label[vid]
  else
    self:compress(vid)
    local label_ancestor_vid = label[ancestor[vid]]
    local label_vid = label[vid]
    if semi[label_ancestor_vid] >= semi[label_vid] then
      return label_vid
    else
      return label_ancestor_vid
    end
  end
end

function class:link(vid, wid)
  local ancestor = self.ancestor
  local child = self.child
  local label = self.label
  local semi = self.semi
  local size = self.size

  local sid = wid
  while semi[label[wid]] < semi[label[child[sid]]] do
    if size[sid] + size[child[child[sid]]] >= 2 - size[child[sid]] then
      ancestor[child[sid]] = sid
      child[sid] = child[child[sid]]
    else
      size[child[sid]] = size[sid]
      ancestor[sid] = child[sid]
      sid = child[sid]
    end
  end
  label[sid] = label[wid]
  size[vid] = size[vid] + size[wid]
  if size[vid] < 2 - size[wid] then
    sid, child[vid] = child[vid], sid
  end
  while sid ~= 0 do
    ancestor[sid] = vid
    sid = child[sid]
  end
end

return function (g, start_uid)
  local u = g.u
  local u_after = u.after
  local uv = g.uv
  local uv_first = uv.first
  local uv_after = uv.after
  local uv_target = uv.target
  local vu = g.vu
  local vu_first = vu.first
  local vu_after = vu.after
  local vu_target = vu.target

  -- integer array (1::n)
  local dom = {}

  -- integer array (1::n)
  local parent = {}
  local ancestor = {}
  local child = {}
  local vertex = {}
  -- integer array (0::n)
  local label = { [0] = 0 }
  local semi = { [0] = 0 }
  local size = { [0] = 0 }
  -- integer set array (1::n)
  local bucket = {}

  local self = setmetatable({
    -- integer array (1::n)
    parent = parent;
    ancestor = ancestor;
    child = child;
    vertex = vertex;
    -- integer array (0::n)
    label = label;
    semi = semi;
    size = size;
  }, metatable)

  local uid = u.first
  while uid do
    bucket[uid] = {}
    semi[uid] = 0
    uid = u_after[uid]
  end

  local n = self:dfs(uv_first, uv_after, uv_target, start_uid, 0)

  for i = n, 2, -1 do
    local wid = vertex[i]

    local eid = vu_first[wid]
    while eid do
      local vid = vu_target[eid]
      local uid = self:eval(vid)
      if semi[uid] < semi[wid] then
        semi[wid] = semi[uid]
      end
      eid = vu_after[eid]
    end

    bucket[vertex[semi[wid]]][wid] = true

    self:link(parent[wid], wid)

    for vid in pairs(bucket[parent[wid]]) do
      bucket[parent[wid]][vid] = nil
      local uid = self:eval(vid)
      if semi[uid] < semi[vid] then
        dom[vid] = uid
      else
        dom[vid] = parent[wid]
      end
    end
  end

  for i = 2, n do
    local wid = vertex[i]

    if dom[wid] ~= vertex[semi[wid]] then
      dom[wid] = dom[dom[wid]]
    end
  end

  return dom
end
