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
  n = n + 1
  self.semi[vid] = n
  self.vertex[n] = vid
  self.label[vid] = vid
  self.ancestor[vid] = 0
  self.child[vid] = 0
  self.size[vid] = 1

  local eid = uv_first[vid]
  while eid do
    local wid = uv_target[eid]
    if self.semi[wid] == 0 then
      self.parent[wid] = vid
      n = self:dfs(uv_first, uv_after, uv_target, wid, n)
    end
    local pred = self.pred[vid]
    pred[#pred + 1] = vid
    eid = uv_after[eid]
  end

  return n
end

function class:compress(vid)
  if self.ancestor[self.ancestor[vid]] ~= 0 then
    self:compress(self.ancestor[vid])
    if self.semi[self.label[self.ancestor[vid]]] < self.semi[self.label[vid]] then
      self.label[vid] = self.label[self.ancestor[vid]]
    end
    self.ancestor[vid] = self.ancestor[self.ancestor[vid]]
  end
end

function class:eval(vid)
  if self.ancestor[vid] == 0 then
    return self.label[vid]
  else
    self:compress(vid)
    if self.semi[self.label[self.ancestor[vid]]] >= self.semi[self.label[vid]] then
      return self.label[vid]
    else
      return self.label[self.ancestor[vid]]
    end
  end
end

function class:link(vid, wid)
  local sid = wid
  while self.semi[self.label[wid]] < self.semi[self.label[self.child[sid]]] do
    if self.size[sid] + self.size[self.child[self.child[sid]]] >= 2 - self.size[self.child[sid]] then
      self.ancestor[self.child[sid]] = sid
      self.child[sid] = self.child[self.child[sid]]
    else
      self.size[self.child[sid]] = self.size[sid]
      self.ancestor[sid] = self.child[sid]
      sid = self.child[sid]
    end
  end
  self.label[sid] = self.label[wid]
  self.size[vid] = self.size[vid] + self.size[wid]
  if self.size[vid] < 2 - self.size[wid] then
    sid, child[vid] = child[vid], sid
  end
  while sid ~= 0 do
    self.ancestor[sid] = vid
    sid = self.child[sid]
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
  local label = {}
  local semi = {}
  local size = {}
  -- integer set array (1::n)
  local pred = {}
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
    -- integer set array (1::n)
    pred = pred;
    bucket = bucket;
  }, metatable)

  local uid = u.first
  while uid do
    pred[uid] = {}
    bucket[uid] = {}
    semi[uid] = 0
    uid = u_after[uid]
  end

  local n = self:dfs(uv_first, uv_after, uv_target, start_uid, 0)

  size[0] = 0
  label[0] = 0
  semi[0] = 0

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

    local b = bucket[vertex[semi[wid]]]
    b[#b + 1] = wid

    self:link(parent[wid], wid)

    local b = bucket[parent[wid]]
    for j = 1, #b do
      local vid = b[j]
      b[j] = nil
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

  -- dom[start_uid] = 0

  return dom
end
