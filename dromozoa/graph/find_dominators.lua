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
  local label_wid = label[wid]
  local child_sid = child[sid]
  while semi[label_wid] < semi[label[child_sid]] do
    if size[sid] + size[child[child_sid]] >= 2 - size[child_sid] then
      ancestor[child_sid] = sid
      child_sid = child[child_sid]
      child[sid] = child_sid
    else
      size[child_sid] = size[sid]
      ancestor[sid] = child_sid
      child_sid = child[child_sid]
      sid = child_sid
    end
  end
  label[sid] = label_wid
  local size_wid = size[wid]
  local size_vid = size[vid] + size_wid
  size[vid] = size_vid
  if size_vid < 2 - size_wid then
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
    parent = parent;
    ancestor = ancestor;
    child = child;
    vertex = vertex;
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
      local semi_uid = semi[uid]
      if semi_uid < semi[wid] then
        semi[wid] = semi_uid
      end
      eid = vu_after[eid]
    end

    bucket[vertex[semi[wid]]][wid] = true

    local parent_wid = parent[wid]
    self:link(parent_wid, wid)
    local bucket_parent_wid = bucket[parent_wid]
    for vid in pairs(bucket_parent_wid) do
      bucket_parent_wid[vid] = nil
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
    local dom_wid = dom[wid]
    if dom_wid ~= vertex[semi[wid]] then
      dom[wid] = dom[dom_wid]
    end
  end

  return dom
end
