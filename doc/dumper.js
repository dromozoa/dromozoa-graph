/*jslint for,this,white*/
(function (root) {
  "use strict";

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
          result[2].push(visit(v));
          break;
        case root.Node.TEXT_NODE:
          result[2].push(v.nodeValue);
          break;
      }
    }

    return result;
  }

  var result = visit(root.document.children[0]);
  // root.console.log(root.JSON.stringify(result, null, 2));
  // root.dumper_result = result;
  root.copy(root.JSON.stringify(result));
}(this.self));
