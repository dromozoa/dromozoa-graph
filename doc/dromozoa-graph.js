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

    module.nodes = [
      { name: "μ's" },
      { name: "一年生" },
      { name: "二年生" },
      { name: "三年生" },
      { name: "Printemps" },
      { name: "BiBi" },
      { name: "lily white" },
      { name: "高坂穂乃果" },
      { name: "南ことり" },
      { name: "小泉花陽" },
      { name: "絢瀬絵里" },
      { name: "西木野真姫" },
      { name: "矢澤にこ" },
      { name: "園田海未" },
      { name: "星空凛" },
      { name: "東條希" }
    ];

    module.links = [
      { source: 0, target: 1 },
      { source: 0, target: 2 },
      { source: 0, target: 3 },
      { source: 0, target: 4 },
      { source: 0, target: 5 },
      { source: 0, target: 6 },
      { source: 1, target: 9 },
      { source: 1, target: 11 },
      { source: 1, target: 14 },
      { source: 2, target: 7 },
      { source: 2, target: 8 },
      { source: 2, target: 13 },
      { source: 3, target: 10 },
      { source: 3, target: 12 },
      { source: 3, target: 15 },
      { source: 4, target: 7 },
      { source: 4, target: 8 },
      { source: 4, target: 9 },
      { source: 5, target: 10 },
      { source: 5, target: 11 },
      { source: 5, target: 12 },
      { source: 6, target: 13 },
      { source: 6, target: 14 },
      { source: 6, target: 15 }
    ];

    module.layout = d3.layout.force()
        .nodes(module.nodes)
        .links(module.links)
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
        .data(module.links)
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
        .data(module.nodes)
        .enter()
            .append("g")
            .attr({
              transform: function (d) {
                return "translate(" + d.x + "," + d.y + ")";
              }
            });

//    module.group.append("rect")
//        .attr({
//            fill: "none",
//            stroke: "#000000"
//        });

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
//              rect = d3.select(this.parentNode).select("rect"),
              c = bbox.y + bbox.height,
              sqrt2 = Math.sqrt(2);
          d3.select(this)
              .attr({
                y: c
              });
//          d3.select(this.parentNode).select("rect")
//              .attr({
//                x: - bbox.width / 2,
//                y: - bbox.height / 2,
//                width: bbox.width,
//                height: bbox.height
//              });
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
      module.main(root.d3);
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
