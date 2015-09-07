/*jslint this: true, white: true */
/*global global */
"use strict";
(function (root) {
  var module = (function () {
    if (root.dromozoa === undefined) {
      root.dromozoa = {};
    }
    if (root.dromozoa.graph === undefined) {
      root.dromozoa.graph = {};
    }
    return root.dromozoa.graph;
  }());

  if (root.console !== undefined && root.console.log !== undefined) {
    module.log = function () {
      root.console.log.apply(root.console, arguments);
    };
  } else {
    module.log = root.jQuery.noop;
  }

  module.main = function (d3) {
    var a, b, box, svg = d3.select("body").style({
      margin: 0,
      "font-family": "Noto Sans Japanese",
      "font-weight": 100
    }).append("svg").attr({
      width: root.innerWidth,
      height: root.innerHeight
    }).style({
      display: "block"
    });

    d3.select(root).on("resize", function () {
      svg.attr({
        width: root.innerWidth,
        height: root.innerHeight
      });
    });

    b = svg.append("rect").attr({
      fill: "red"
    });

    a = svg.append("text").text("レッサーパンダ").attr({
      x: 100,
      y: 100,
      "font-size": 72
    });
    box = a.node().getBBox();
    b.attr({
      x: box.x,
      y: box.y,
      width: box.width,
      height: box.height
    });
  };

  module.run = function () {
    if (module.run.ready && module.run.active) {
      module.main(root.d3);
    }
  };

  root.WebFont.load({
    custom: {
      families: [ "Noto Sans Japanese:n1" ],
      urls: [ "https://fonts.googleapis.com/earlyaccess/notosansjapanese.css" ]
    },
    active: function () {
      module.run.active = true;
      module.run();
    }
  });

  root.jQuery(function () {
    module.run.ready = true;
    module.run();
  });
}(this.self || global));
