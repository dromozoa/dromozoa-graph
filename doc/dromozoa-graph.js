/*jslint this: true, white: true */
/*global global */
"use strict";
(function (root) {
  var $ = root.jQuery, d3 = root.d3, module = (function () {
    if (root.dromozoa === undefined) {
      root.dromozoa = {};
    }
    if (root.dromozoa.graph === undefined) {
      root.dromozoa.graph = {};
    }
    return root.dromozoa.graph;
  }());

  if (root.console !== undefined && root.console.log !== undefined) {
    module.console = root.console;
  } else {
    module.console = {
      log: $.noop
    };
  }

  module.update_nodes = function () {
    module.nodes.each(function () {
      var g = d3.select(this),
          t = g.select("text"),
          box = t.node().getBBox(),
          w = box.width,
          h = box.height,
          w2 = w * 0.5,
          h2 = h * 0.5,
          dy = t.attr("dy");
      if (dy === null) {
        dy = 0;
      }
      t.attr({
        dy: dy - (box.y + h2)
      });
      g.select("rect").attr({
        x: -w2,
        y: -h2,
        width: w,
        height: h
      });
      g.select("ellipse").attr({
        rx: w2 * Math.SQRT2,
        ry: h2 * Math.SQRT2
      });
      g.select("circle").attr({
        r: Math.sqrt(w2 * w2 + h2 * h2)
      });
    });
  };

  module.main = function () {
    var nodes, links;

    module.svg = d3.select("body").style({
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
      module.svg.attr({
        width: root.innerWidth,
        height: root.innerHeight
      });
    });

    module.layout = d3.layout.force()
        .nodes(module.data.nodes)
        .links(module.data.links)
        .size([
          root.innerWidth,
          root.innerHeight
        ])
        .linkStrength(0.9)
        .friction(0.9)
        .linkDistance(100)
        .charge(-900)
        .gravity(0.1)
        .theta(0.8)
        .alpha(0.1)
        .start();

    links = module.svg.selectAll("line")
        .data(module.data.links)
        .enter()
        .append("line").attr({
          stroke: "black"
        });

    nodes = module.svg.selectAll("g")
        .data(module.data.nodes)
        .enter()
        .append("g");

    nodes.append("ellipse").attr({
      opacity: 0.5,
      fill: "pink",
      stroke: "#000000"
    });

//    nodes.append("circle").attr({
//      fill: "pink",
//      stroke: "black"
//    });

//    nodes.append("rect").attr({
//      fill: "pink",
//      stroke: "black"
//    });

    nodes.append("text")
        .text(function (d) { return d.text; })
        .attr({
            "text-anchor": "middle"
        });

    module.links = links;
    module.nodes = nodes;
    module.update_nodes();

    module.layout.on("tick", function () {
      links.attr({
        x1: function (d) { return d.source.x; },
        y1: function (d) { return d.source.y; },
        x2: function (d) { return d.target.x; },
        y2: function (d) { return d.target.y; }
      });

      nodes.attr({
        transform: function (d) {
          return "translate(" + d.x + "," + d.y + ")";
        }
      });
    });
  };

  module.run = function (ev) {
    module.console.log("run " + ev);
    module.run[ev] = true;
    if (module.run.start) {
      return;
    }
    if ((module.run.ready && module.run.active) || module.run.timeout) {
      if (module.run.timer !== undefined) {
        root.clearTimeout(module.run.timer);
      }
      module.run.start = true;
      d3.json("dromozoa-graph.json", function (error, data) {
        if (error !== null) {
          module.console.log(error);
          root.alert("could not load json");
          return;
        }
        module.data = data;
        module.main();
      });
    }
  };

  root.WebFont.load({
    custom: {
      families: [ "Noto Sans Japanese:n1" ],
      urls: [ "https://fonts.googleapis.com/earlyaccess/notosansjapanese.css" ]
    },
    timeout: 60000,
    active: function () {
      module.run("active");
    },
    inactive: function () {
      module.console.log("inactive");
      root.alert("could not load font");
    }
  });

  $(function () {
    module.run("ready");
  });

  module.run.timer = root.setTimeout(function() {
    module.run("timeout");
  }, 3000);
}(this.self || global));
