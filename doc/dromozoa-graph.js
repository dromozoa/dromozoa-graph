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
    module.console = root.console;
  } else {
    module.console = {
      log: root.jQuery.noop
    };
  }

  module.main = function (d3) {
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

    module.line = module.svg.selectAll()
        .data(module.data.links)
        .enter()
            .append("line")
            .attr({
              stroke: "black",
              x1: function (d) { return d.source.x; },
              y1: function (d) { return d.source.y; },
              x2: function (d) { return d.target.x; },
              y2: function (d) { return d.target.y; }
            });

    module.group = module.svg.selectAll("g")
        .data(module.data.nodes)
        .enter()
            .append("g")
            .attr({
              transform: function (d) {
                return "translate(" + d.x + "," + d.y + ")";
              }
            });

    module.group.append("ellipse")
        .attr({
            fill: "#ffccff",
            stroke: "#000000"
        });

    module.group.append("text")
        .text(function (d) { return d.name; })
        .attr({
            "text-anchor": "middle"
        }).each(function () {
          var bbox = this.getBBox(),
              c = bbox.y + bbox.height,
              sqrt2 = Math.sqrt(2);
          d3.select(this)
              .attr({
                y: c
              });
          d3.select(this.parentNode).select("ellipse")
              .attr({
                // cy: - c / 2,
                rx: bbox.width / 2 * sqrt2,
                ry: bbox.height / 2 * sqrt2
              });
        });

    module.layout.on("tick", function () {
      module.line.attr({
        x1: function (d) { return d.source.x; },
        y1: function (d) { return d.source.y; },
        x2: function (d) { return d.target.x; },
        y2: function (d) { return d.target.y; }
      });

      module.group.attr({
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
      root.d3.json("dromozoa-graph.json", function (data) {
        module.data = data;
        module.main(root.d3);
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
    }
  });

  root.jQuery(function () {
    module.run("ready");
  });

  module.run.timer = root.setTimeout(function() {
    module.run("timeout");
  }, 3000);
}(this.self || global));
