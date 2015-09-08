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

  module.make_id = function () {
    module.make_id.counter += 1;
    return module.make_id.namespace + module.make_id.counter;
  };
  module.make_id.namespace = "dromozoa-graph-";
  module.make_id.counter = 0;

  module.make_marker = function (defs, type) {
    var w = module.make_marker.width,
        h = module.make_marker.height,
        hw = w * 0.5,
        hh = h * 0.5,
        marker;
    marker = defs.append("marker").attr({
      id: module.make_id(),
      refX: hw,
      refY: hh,
      markerWidth: w,
      markerHeight: h,
      orient: "auto"
    });
    if (type === "start") {
      marker.append("path").attr({
        d: d3.svg.line()([ [ w, 0 ], [ 0, hh ], [ w, h ] ])
      });
    } else {
      marker.append("path").attr({
        d: d3.svg.line()([ [ 0, 0 ], [ w, hh ], [ 0, h ] ])
      });
    }
    return marker;
  };
  module.make_marker.width = 8;
  module.make_marker.height = 8;

  module.update_links = function () {
    module.links.each(function (d) {
      var line = d3.select(this),
          stroke_width = line.attr("stroke-width"),
          marker;
      if (stroke_width === null) {
        stroke_width = 1;
      }
      marker = stroke_width * module.make_marker.width * 0.5;
      if (line.attr("marker-start") !== null) {
        d.marker_start = marker;
      } else {
        d.marker_start = 0;
      }
      if (line.attr("marker-end") !== null) {
        d.marker_end = marker;
      } else {
        d.marker_end = 0;
      }
    });
  };

  module.update_nodes = function (type) {
    module.nodes.each(function (d) {
      var g = d3.select(this),
          text = g.select("text"),
          box = text.node().getBBox(),
          y = box.y,
          w = box.width,
          h = box.height,
          hw = w * 0.5,
          hh = h * 0.5,
          dy = text.attr("dy");
      if (dy === null) {
        dy = 0;
      }
      text.attr({
        dy: dy - y - hh
      });
      g.select("rect").attr({
        x: -hw,
        y: -hh,
        width: w,
        height: h
      });
      g.select("ellipse").attr({
        rx: hw * Math.SQRT2,
        ry: hh * Math.SQRT2
      });
      g.select("circle").attr({
        r: Math.sqrt(hw * hw + hh * hh)
      });
      d.type = type;
      d.width = w;
      d.height = h;
    });
  };

  module.intersection_impl = function (a, b, marker) {
    var dx = b.x - a.x,
        dy = b.y - a.y,
        c = marker * Math.sqrt(1 / (dx * dx + dy * dy));
    return {
      x: a.x + dx * c,
      y: a.y + dy * c
    };
  };

  module.intersection = function (a, b, marker) {
    var fn = module.intersection[a.type];
    if (fn !== undefined) {
      return module.intersection_impl(fn(a, b), b, marker);
    } else {
      return module.intersection_impl(a, b, marker);
    }
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

  module.main = function () {
    var svg, defs, marker_start, marker_end, links, nodes;

    svg = d3.select("body").style({
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

    defs = svg.append("defs");

    marker_start = module.make_marker(defs, "start");
    marker_end = module.make_marker(defs, "end");

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

    links = svg.selectAll("line")
        .data(module.data.links)
        .enter()
        .append("line").attr({
          stroke: "black",
          "marker-start": "url(#" + marker_start.attr("id") + ")",
          "marker-end": "url(#" + marker_end.attr("id") + ")"
        });

    nodes = svg.selectAll("g")
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

    module.update_links();
    module.update_nodes("ellipse");

    module.layout.on("tick", function () {
      links.attr({
        x1: function (d) {
          return module.intersection(d.source, d.target, d.marker_start).x;
        },
        y1: function (d) {
          return module.intersection(d.source, d.target, d.marker_start).y;
        },
        x2: function (d) {
          return module.intersection(d.target, d.source, d.marker_end).x;
        },
        y2: function (d) {
          return module.intersection(d.target, d.source, d.marker_end).y;
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
