#! /bin/sh -e

# Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
#
# This file is part of dromozoa-graph.
#
# dromozoa-graph is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dromozoa-graph is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-graph.  If not, see <http://www.gnu.org/licenses/>.

case x$1 in
  x) lua=lua;;
  *) lua=$1;;
esac

for i in test/test*.lua
do
  "$lua" "$i"
done

(cd test && make)

mkdir -p out

for i in data/undirected*.txt
do
  name=`expr "x$i" : 'xdata/\(.*\)\.txt$'`
  test/boost_graph undirected "$i" >"out/$name-boost.txt"
  lua test/graph.lua undirected "$i" >"out/$name-ungraph.txt"
  diff -u "out/$name-boost.txt" "out/$name-ungraph.txt"
done

for i in data/directed*.txt
do
  name=`expr "x$i" : 'xdata/\(.*\)\.txt$'`
  test/boost_graph directed "$i" >"out/$name-boost.txt"
  lua test/graph.lua bidirectional "$i" >"out/$name-bigraph.txt"
  lua test/graph.lua directed "$i" >"out/$name-digraph.txt"
  diff -u "out/$name-boost.txt" "out/$name-bigraph.txt"
  diff -u "out/$name-boost.txt" "out/$name-digraph.txt"
done

for i in data/cycle_removal*.txt
do
  lua test/cycle_removal.lua "$i"
done
