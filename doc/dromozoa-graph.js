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

  module.update_nodes = function (type) {
    module.nodes.each(function (d) {
      var d3_this = d3.select(this),
          d3_text = d3_this.select("text"),
          box = d3_text.node().getBBox(),
          y = box.y,
          w = box.width,
          h = box.height,
          hw = w * 0.5,
          hh = h * 0.5,
          dy = d3_text.attr("dy");
      if (dy === null) {
        dy = 0;
      }
      d3_text.attr({
        dy: dy - y - hh
      });
      d3_this.select("rect").attr({
        x: -hw,
        y: -hh,
        width: w,
        height: h
      });
      d3_this.select("ellipse").attr({
        rx: hw * Math.SQRT2,
        ry: hh * Math.SQRT2
      });
      d3_this.select("circle").attr({
        r: Math.sqrt(hw * hw + hh * hh)
      });
      d.type = type;
      d.width = w;
      d.height = h;
    });
  };

  module.intersection = function (a, b) {
    var fn = module.intersection[a.type];
    if (fn !== undefined) {
      return fn(a, b);
    } else {
      return a;
    }
  };

  module.intersection.rect = function (a, b) {
    var dx = b.x - a.x,
        dy = b.y - a.y,
        hw = a.width * 0.5,
        hh = a.height * 0.5,
        c = hh / hw,
        x, y, d;
    if (dx === 0) {
      x = 0;
      y = hh;
      if (dy < 0) {
        y = -y;
      }
    } else {
      d = dy / dx;
      if (-c < d && d < c) {
        x = hw;
        if (dx < 0) {
          x = -x;
        }
        y = x * d;
      } else {
        y = hh;
        if (dy < 0) {
          y = -y;
        }
        x = y / d;
      }
    }
    return {
      x: a.x + x,
      y: a.y + y
    };
  };

  module.intersection.ellipse = function (a, b) {
    var dx = b.x - a.x,
        dy = b.y - a.y,
        hw = a.width * 0.5,
        hh = a.height * 0.5,
        rx = hw * Math.SQRT2,
        ry = hh * Math.SQRT2,
        rx2 = rx * rx,
        ry2 = ry * ry,
        x, y, d;
    if (dx === 0) {
      x = 0;
      y = ry;
      if (dy < 0) {
        y = -y;
      }
    } else {
      d = dy / dx;
      x = Math.sqrt(rx2 * ry2 / (rx2 * d * d + ry2));
      if (dx < 0) {
        x = -x;
      }
      y = x * d;
    }
    return {
      x: a.x + x,
      y: a.y + y
    };
  };

  module.intersection.circle = function (a, b) {
    var dx = b.x - a.x,
        dy = b.y - a.y,
        hw = a.width * 0.5,
        hh = a.height * 0.5,
        c = Math.sqrt((hw * hw + hh * hh) / (dx * dx + dy * dy));
    return {
      x: a.x + dx * c,
      y: a.y + dy * c
    };
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
//      opacity: 0.5,
//      fill: "pink",
//      stroke: "black"
//    });

//    nodes.append("rect").attr({
//      opacity: 0.5,
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
    module.update_nodes("ellipse");

    module.layout.on("tick", function () {
      links.attr({
        x1: function (d) {
          return module.intersection(d.source, d.target).x;
        },
        y1: function (d) {
          return module.intersection(d.source, d.target).y;
        },
        x2: function (d) {
          return module.intersection(d.target, d.source).x;
        },
        y2: function (d) {
          return module.intersection(d.target, d.source).y;
        }
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
