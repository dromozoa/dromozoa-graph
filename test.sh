#! /bin/sh -e

# Copyright (C) 2015,2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

LUA_PATH="test/?.lua;?.lua;;"
export LUA_PATH

for i in test/test*.lua
do
  case X$# in
    X0) lua "$i";;
    *) "$@" "$i";;
  esac
done

rm -f test*.dot

# (cd test && make)

# mkdir -p out

# for i in data/undirected*.txt
# do
#   name=`expr "x$i" : 'xdata/\(.*\)\.txt$'`
#   test/boost_graph undirected "$i" >"out/$name-boost.txt"
#   lua test/graph.lua undirected "$i" >"out/$name.txt"
#   diff -u "out/$name-boost.txt" "out/$name.txt"
# done

# for i in data/directed*.txt
# do
#   name=`expr "x$i" : 'xdata/\(.*\)\.txt$'`
#   test/boost_graph directed "$i" >"out/$name-boost.txt"
#   lua test/graph.lua directed "$i" >"out/$name.txt"
#   diff -u "out/$name-boost.txt" "out/$name.txt"
# done

# for i in data/cycle_removal*.txt
# do
#   lua test/cycle_removal.lua "$i"
# done

# for i in data/layer_assignment*.txt
# do
#   lua test/layer_assignment.lua "$i"
# done

# for i in data/transitive_reduction*.txt
# do
#   lua test/transitive_reduction.lua "$i"
# done

# rm -f -r out
