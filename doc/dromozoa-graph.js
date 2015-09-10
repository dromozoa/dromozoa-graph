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

  module.tuple2 = function (x, y) {
    var that = { x: x, y: y };

    that.add = function (t1) {
      that.x += t1.x;
      that.y += t1.y;
      return that;
    };

    that.sub = function (t1) {
      that.x -= t1.x;
      that.y -= t1.y;
      return that;
    };

    that.scale = function (s) {
      that.x *= s;
      that.y *= s;
      return that;
    };

    that.interpolate = function (t1, alpha) {
      var beta = 1 - alpha;
      that.x = that.x * beta + t1.x * alpha;
      that.y = that.y * beta + t1.y * alpha;
      return that;
    };

    that.clone = function () {
      return module.tuple2(that.x, that.y);
    };

    that.toString = function () {
      return "[" + that.x + "," + that.y + "]";
    };

    return that;
  };

  module.vector2 = function (x, y) {
    var that = module.tuple2(x, y);

    that.dot = function (v1) {
      return that.x * v1.x + that.y * v1.y;
    };

    that.angle = function (v1) {
      return Math.abs(Math.atan2(that.x * v1.y - that.y * v1.x, that.dot(v1)));
    };

    that.length = function () {
      var x = that.x,
          y = that.y;
      return Math.sqrt(x * x + y * y);
    };

    that.length_squared = function () {
      var x = that.x,
          y = that.y;
      return x * x + y * y;
    };

    that.normalize = function () {
      var d = that.length(),
          s = 1 / d;
      that.x *= s;
      that.y *= s;
      return that;
    };

    that.clone = function () {
      return module.vector2(that.x, that.y);
    };

    return that;
  };

  module.matrix3 = function (m00, m01, m02, m10, m11, m12, m20, m21, m22) {
    var that = {};

    that.set_zero = function () {
      m00 = 0; m01 = 0; m02 = 0;
      m10 = 0; m11 = 0; m12 = 0;
      m20 = 0; m21 = 0; m22 = 0;
      return that;
    };

    that.set_identity = function () {
      m00 = 1; m01 = 0; m02 = 0;
      m10 = 0; m11 = 1; m12 = 0;
      m20 = 0; m21 = 0; m22 = 1;
      return that;
    };

    that.set_row = function (row, x, y, z) {
      switch (row) {
        case 0:
          m00 = x;
          m01 = y;
          if (z !== undefined) {
            m02 = z;
          }
          break;
        case 1:
          m10 = x;
          m11 = y;
          if (z !== undefined) {
            m12 = z;
          }
          break;
        case 2:
          m20 = x;
          m21 = y;
          if (z !== undefined) {
            m22 = z;
          }
          break;
      }
      return that;
    };

    that.set_col = function (col, x, y, z) {
      switch (col) {
        case 0:
          m00 = x;
          m10 = y;
          if (z !== undefined) {
            m20 = z;
          }
          break;
        case 1:
          m01 = x;
          m11 = y;
          if (z !== undefined) {
            m21 = z;
          }
          break;
        case 2:
          m02 = x;
          m12 = y;
          if (z !== undefined) {
            m22 = z;
          }
          break;
      }
      return that;
    };

    that.rot_x = function (angle) {
      var c = Math.cos(angle),
          s = Math.sin(angle);
      m00 = 1; m01 = 0; m02 =  0;
      m10 = 0; m11 = c; m12 = -s;
      m20 = 0; m21 = s; m22 =  c;
      return that;
    };

    that.rot_y = function (angle) {
      var c = Math.cos(angle),
          s = Math.sin(angle);
      m00 =  c; m01 = 0; m02 = s;
      m10 =  0; m11 = 1; m12 = 0;
      m20 = -s; m21 = 0; m22 = c;
      return that;
    };

    that.rot_z = function (angle) {
      var c = Math.cos(angle),
          s = Math.sin(angle);
      m00 = c; m01 = -s; m02 = 0;
      m10 = s; m11 =  c; m12 = 0;
      m20 = 0; m21 =  0; m22 = 1;
      return that;
    };

    that.transpose = function () {
      var tmp = m01; m01 = m10; m10 = tmp;
      tmp = m02; m02 = m20; m20 = tmp;
      tmp = m12; m12 = m21; m21 = tmp;
      return that;
    };

    that.determinant = function () {
      return m00 * (m11 * m22 - m21 * m12)
          - m01 * (m10 * m22 - m20 * m12)
          + m02 * (m10 * m21 - m20 * m11);
    };

    that.invert = function () {
      var d = that.determinant(),
          n00 = m11 * m22 - m12 * m21,
          n01 = m02 * m21 - m01 * m22,
          n02 = m01 * m12 - m02 * m11,
          n10 = m12 * m20 - m10 * m22,
          n11 = m00 * m22 - m02 * m20,
          n12 = m02 * m10 - m00 * m12,
          n20 = m10 * m21 - m11 * m20,
          n21 = m01 * m20 - m00 * m21,
          n22 = m00 * m11 - m01 * m10,
          s;
      if (d !== 0) {
        s = 1 / d;
        m00 = n00 * s; m01 = n01 * s; m02 = n02 * s;
        m10 = n10 * s; m11 = n11 * s; m12 = n12 * s;
        m20 = n20 * s; m21 = n21 * s; m22 = n22 * s;
      }
      return that;
    };

    that.transform = function (t, result) {
      var x = t.x, y = t.y, z = t.z;
      if (result === undefined) {
        result = t;
      }
      if (z === undefined) {
        result.x = m00 * x + m01 * y + m02;
        result.y = m10 * x + m11 * y + m12;
      } else {
        result.x = m00 * x + m01 * y + m02 * z;
        result.y = m10 * x + m11 * y + m12 * z;
        result.z = m20 * x + m21 * y + m22 * z;
      }
      return result;
    };

    that.clone = function () {
      return module.matrix3(m00, m01, m02, m10, m11, m12, m20, m21, m22);
    };

    that.toString = function () {
      return "[[" + m00 + "," + m01 + "," + m02
          + "],[" + m10 + "," + m11 + "," + m12
          + "],[" + m20 + "," + m21 + "," + m22 + "]";
    };

    return that;
  };

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
        force = d3.layout.force(),
        view_g = svg.append("g"),
        view_rect = view_g.append("rect"),
        g = view_g.append("g"),
        links = g.selectAll("line").data(data.links).enter().append("line"),
        nodes = g.selectAll("g").data(data.nodes).enter().append("g"),
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
      view_rect.attr({
        width: w,
        height: h
      });
      force.size([ w, h ]).start();
    };

    return that;
  };

  module.construct_tree = function (svg, data) {
    var that = {},
        defs = svg.append("defs"),
        marker_start = module.make_marker(defs, "start"),
        marker_end = module.make_marker(defs, "end"),
        tree = d3.layout.tree(),
        data_nodes = tree.nodes(data),
        data_links = tree.links(data_nodes),
        view_g = svg.append("g"),
        view_rect = view_g.append("rect"),
        g = view_g.append("g"),
        links = g.selectAll("line").data(data_links).enter().append("line"),
        nodes = g.selectAll("g").data(data_nodes).enter().append("g"),
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

    that.update = function (w, h) {
      var px = Math.min(w, h) * 0.2,
          py = px,
          pw = w - px * 2,
          ph = h - py * 2;

      links.attr({
        x1: function (d) {
          var sx = d.source.x * pw + px,
              sy = d.source.y * ph + py,
              tx = d.target.x * pw + px,
              ty = d.target.y * ph + py,
              t = d.source.type,
              dw = d.source.width,
              dh = d.source.height;
          return module.offset({ x: sx, y: sy, type: t, width: dw, height: dh }, { x: tx, y: ty }, d.offset_start).x;
        },
        y1: function (d) {
          var sx = d.source.x * pw + px,
              sy = d.source.y * ph + py,
              tx = d.target.x * pw + px,
              ty = d.target.y * ph + py,
              t = d.source.type,
              dw = d.source.width,
              dh = d.source.height;
          return module.offset({ x: sx, y: sy, type: t, width: dw, height: dh }, { x: tx, y: ty }, d.offset_start).y;
        },
        x2: function (d) {
          var sx = d.source.x * pw + px,
              sy = d.source.y * ph + py,
              tx = d.target.x * pw + px,
              ty = d.target.y * ph + py,
              t = d.target.type,
              dw = d.target.width,
              dh = d.target.height;
          return module.offset({ x: tx, y: ty, type: t, width: dw, height: dh }, { x: sx, y: sy }, d.offset_end).x;
        },
        y2: function (d) {
          var sx = d.source.x * pw + px,
              sy = d.source.y * ph + py,
              tx = d.target.x * pw + px,
              ty = d.target.y * ph + py,
              t = d.target.type,
              dw = d.target.width,
              dh = d.target.height;
          return module.offset({ x: tx, y: ty, type: t, width: dw, height: dh }, { x: sx, y: sy }, d.offset_end).y;
        }
      });

      nodes.attr("transform", function (d) {
        return "translate(" + (d.x * pw + px) + "," + (d.y * ph + py) + ")";
      });
    };

    view_g.call(d3.behavior.zoom().on("zoom", function () {
      g.attr("transform", "translate(" + d3.event.translate + ") scale(" + d3.event.scale + ")");
    }));

    that.resize = function (w, h) {
      svg.attr({
        width: w,
        height: h
      });
      view_rect.attr({
        width: w,
        height: h
      });
      that.update(w, h);
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

    that = module.construct_tree(svg, data);
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
