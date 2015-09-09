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
      marker.append("path").attr("d", d3.svg.line()([ [ w, 0 ], [ 0, hh ], [ w, h ] ]));
    } else {
      marker.append("path").attr("d", d3.svg.line()([ [ 0, 0 ], [ w, hh ], [ 0, h ] ]));
    }
    return marker;
  };
  module.make_marker.width = 8;
  module.make_marker.height = 8;

  module.update_links = function (links) {
    links.each(function (d) {
      var line = d3.select(this),
          stroke_width = line.attr("stroke-width"),
          offset;
      if (stroke_width === null) {
        stroke_width = 1;
      }
      offset = stroke_width * module.make_marker.width * 0.5;
      if (line.attr("marker-start") !== null) {
        d.offset_start = offset;
      } else {
        d.offset_start = 0;
      }
      if (line.attr("marker-end") !== null) {
        d.offset_end = offset;
      } else {
        d.offset_end = 0;
      }
    });
  };

  module.update_nodes = function (nodes, type) {
    nodes.each(function (d) {
      var group = d3.select(this),
          text = group.select("text"),
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
      text.attr("dy", dy - (y + hh));
      group.select("rect").attr({
        x: -hw,
        y: -hh,
        width: w,
        height: h
      });
      group.select("circle").attr("r", Math.sqrt(hw * hw + hh * hh));
      group.select("ellipse").attr({
        rx: hw * Math.SQRT2,
        ry: hh * Math.SQRT2
      });
      d.type = type;
      d.width = w;
      d.height = h;
    });
  };

  module.offset_impl = function (a, b, offset) {
    var dx = b.x - a.x,
        dy = b.y - a.y,
        c;
    if (dx === 0 && dy === 0) {
      c = 0;
    } else {
      c = offset * Math.sqrt(1 / (dx * dx + dy * dy));
    }
    return {
      x: a.x + dx * c,
      y: a.y + dy * c
    };
  };

  module.offset = function (a, b, offset) {
    var fn = module.offset[a.type];
    if (fn !== undefined) {
      return fn(a, b, offset);
    } else {
      return module.offset_impl(a, b, offset);
    }
  };

  module.offset.circle = function (a, b, offset) {
    var hw = a.width * 0.5,
        hh = a.height * 0.5;
    return module.offset_impl(a, b, Math.sqrt(hw * hw + hh * hh) + offset);
  };

  module.offset.ellipse = function (a, b, offset) {
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
    } else {
      d = dy / dx;
      x = Math.sqrt(rx2 * ry2 / (rx2 * d * d + ry2));
      y = x * d;
    }
    return module.offset_impl(a, b, Math.sqrt(x * x + y * y) + offset);
  };

  module.offset.rect = function (a, b, offset) {
    var dx = b.x - a.x,
        dy = b.y - a.y,
        hw = a.width * 0.5,
        hh = a.height * 0.5,
        c = hh / hw,
        x, y, d;
    if (dx === 0) {
      x = 0;
      y = hh;
    } else {
      d = dy / dx;
      if (-c < d && d < c) {
        x = hw;
        y = x * d;
      } else {
        y = hh;
        x = y / d;
      }
    }
    return module.offset_impl(a, b, Math.sqrt(x * x + y * y) + offset);
  };

  module.construct = function (svg, data) {
    var that = {},
        defs = svg.append("defs"),
        marker_start = module.make_marker(defs, "start"),
        marker_end = module.make_marker(defs, "end"),
        view_g = svg.append("g"),
        view_rect = view_g.append("rect"),
        g = view_g.append("g"),
        links = g.selectAll("line").data(data.links).enter().append("line"),
        nodes = g.selectAll("g").data(data.nodes).enter().append("g"),
        force = d3.layout.force(),
        opacity = 0.8,
        marker = { start: true },
        type = "ellipse";

    view_rect.attr("fill", "white");

    links.attr({
      opacity: opacity,
      stroke: "black"
    });
    if (marker.start) {
      links.attr("marker-start", "url(#" + marker_start.attr("id") + ")");
    }
    if (marker.end) {
      links.attr("marker-end", "url(#" + marker_end.attr("id") + ")");
    }

    if (type === "ellipse") {
      nodes.append("ellipse").attr({
        opacity: opacity,
        fill: "white",
        stroke: "black"
      });
    }
    if (type === "circle") {
      nodes.append("circle").attr({
        opacity: opacity,
        fill: "white",
        stroke: "black"
      });
    }
    if (type === "rect") {
      nodes.append("rect").attr({
        opacity: opacity,
        fill: "white",
        stroke: "black"
      });
    }

    nodes.append("text").text(function (d) {
      return d.text;
    }).attr("text-anchor", "middle");

    module.update_links(links);
    module.update_nodes(nodes, type);

    force.nodes(data.nodes).links(data.links)
        .linkStrength(0.9)
        .friction(0.9)
        .linkDistance(200)
        .charge(-2000)
        .gravity(0.1)
        .theta(0.8)
        .alpha(0.1);

    force.on("tick", function () {
      links.attr({
        x1: function (d) {
          return module.offset(d.source, d.target, d.offset_start).x;
        },
        y1: function (d) {
          return module.offset(d.source, d.target, d.offset_start).y;
        },
        x2: function (d) {
          return module.offset(d.target, d.source, d.offset_end).x;
        },
        y2: function (d) {
          return module.offset(d.target, d.source, d.offset_end).y;
        }
      });

      nodes.attr("transform", function (d) {
        return "translate(" + d.x + "," + d.y + ")";
      });
    });

    nodes.call(force.drag().on("dragstart", function () {
      d3.event.sourceEvent.stopPropagation();
    }));

    view_g.call(d3.behavior.zoom().on("zoom", function () {
      g.attr("transform", "translate(" + d3.event.translate + ") scale(" + d3.event.scale + ")");
    }));

    that.resize = function (w, h) {
      svg.attr({
        width: w,
        height: h
      });
      force.size([ w, h ]).start();
      view_rect.attr({
        width: w,
        height: h
      });
    };

    return that;
  };

  module.main = function (data) {
    var svg, that;

    svg = d3.select("body").style({
      margin: 0,
      "font-family": "Noto Sans Japanese",
      "font-weight": 100
    }).append("svg").style({
      display: "block"
    });

    that = module.construct(svg, data);
    that.resize(root.innerWidth, root.innerHeight);

    d3.select(root).on("resize", function () {
      that.resize(root.innerWidth, root.innerHeight);
    });
  };

  module.run = function (ev) {
    module.run[ev] = true;
    if (module.run.start) {
      return;
    }
    if ((module.run.ready && module.run.active) || module.run.timeout) {
      if (module.run.timer !== undefined) {
        root.clearTimeout(module.run.timer);
      }
      module.run.start = true;
      d3.json("dromozoa-graph-tree.json", function (error, data) {
        if (error !== null) {
          module.console.log(error);
          root.alert("could not load json");
          return;
        }
        module.main(data);
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
