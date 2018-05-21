// Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
//
// This file is part of dromozoa-graph.
//
// dromozoa-graph is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// dromozoa-graph is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-graph.  If not, see <http://www.gnu.org/licenses/>.

/*jslint for,this,white*/
(function (root) {
  "use strict";

  var count_element = 1;
  var count_text = 0;

  function visit(u) {
    var i;
    var v;
    var result = [ u.tagName, {}, [] ];

    for (i = 0; i < u.attributes.length; i += 1) {
      v = u.attributes[i];
      result[1][v.name] = v.value;
    }

    for (i = 0; i < u.childNodes.length; i += 1) {
      v = u.childNodes[i];
      switch (v.nodeType) {
        case root.Node.ELEMENT_NODE:
          count_element += 1;
          result[2].push(visit(v));
          break;
        case root.Node.TEXT_NODE:
          count_text += 1;
          result[2].push(v.nodeValue);
          break;
      }
    }

    return result;
  }

  var result = visit(root.document.children[0]);
  root.console.log("count_element", count_element);
  root.console.log("count_text", count_text);
  root.copy(root.JSON.stringify(result));
}(this.self));
