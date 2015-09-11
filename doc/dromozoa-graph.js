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

  module.name = "dromozoa-graph";

  module.tuple2 = function (x, y) {
    var that = { x: x, y: y };

    that.absolute = function () {
      var x_ = that.x,
          y_ = that.y;
      if (x_ < 0) { that.x = -x_; }
      if (y_ < 0) { that.y = -y_; }
      return that;
    };

    that.scale = function (s) {
      that.x *= s;
      that.y *= s;
      return that;
    };

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

    that.length = function () {
      var x_ = that.x,
          y_ = that.y;
      return Math.sqrt(x_ * x_ + y_ * y_);
    };

    that.length_squared = function () {
      var x_ = that.x,
          y_ = that.y;
      return x_ * x_ + y_ * y_;
    };

    that.dot = function (v1) {
      return that.x * v1.x + that.y * v1.y;
    };

    that.angle = function (v1) {
      return Math.abs(Math.atan2(that.x * v1.y - that.y * v1.x, that.dot(v1)));
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
  module.vector2.x0y0 = module.vector2(0, 0);
  module.vector2.x0y1 = module.vector2(0, 1);
  module.vector2.x1y0 = module.vector2(1, 0);
  module.vector2.x1y1 = module.vector2(1, 1);

  module.matrix3 = function (m00, m01, m02, m10, m11, m12, m20, m21, m22) {
    var that = {};

    that.determinant = function () {
      return m00 * (m11 * m22 - m21 * m12)
          - m01 * (m10 * m22 - m20 * m12)
          + m02 * (m10 * m21 - m20 * m11);
    };

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
          if (z !== undefined) { m20 = z; }
          break;
        case 1:
          m01 = x;
          m11 = y;
          if (z !== undefined) { m21 = z; }
          break;
        case 2:
          m02 = x;
          m12 = y;
          if (z !== undefined) { m22 = z; }
          break;
      }
      return that;
    };

    that.transpose = function () {
      var tmp = m01; m01 = m10; m10 = tmp;
      tmp = m02; m02 = m20; m20 = tmp;
      tmp = m12; m12 = m21; m21 = tmp;
      return that;
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
    return module.name + "-" + module.make_id.counter;
  };
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
    var max_size = module.vector2(0, 0);

    nodes.each(function (d) {
      var group = d3.select(this),
          text = group.select("text"),
          box = text.node().getBBox(),
          y = box.y,
          w = box.width,
          h = box.height,
          hw = w * 0.5,
          hh = h * 0.5,
          dy = text.attr("dy"),
          data;
      if (d[module.name] === undefined) {
        d[module.name] = {};
      }
      data = d[module.name];

      if (dy === null) {
        dy = 0;
      }
      text.attr("dy", dy - (y + hh));
      if (type === "circle") {
        group.select("circle").attr("r", Math.sqrt(hw * hw + hh * hh));
      } else if (type === "ellipse") {
        group.select("ellipse").attr({
          rx: hw * Math.SQRT2,
          ry: hh * Math.SQRT2
        });
      } else if (type === "rect") {
        group.select("rect").attr({
          x: -hw,
          y: -hh,
          width: w,
          height: h
        });
      }
      data.type = data.type;
      data.rect = module.vector2(w, h);
      if (max_size.x < w) {
        max_size.x = w;
      }
      if (max_size.y < h) {
        max_size.y = h;
      }
    });

    return max_size;
  };

  module.offset_impl = function (a, b, length) {
    return module.vector2(b.x, b.y).sub(a).normalize().scale(length).add(a);
  };

  module.offset = function (a, b, length) {
    var fn = module.offset[a[module.name].type];
    if (fn !== undefined) {
      return fn(a, b, length);
    } else {
      return module.offset_impl(a, b, length);
    }
  };

  module.offset.circle = function (a, b, length) {
    length += a[module.name].rect.length() * 0.5;
    return module.offset_impl(a, b, length);
  };

  module.offset.ellipse = function (a, b, length) {
    var angle = module.vector2(b.x, b.y).sub(a).angle(module.vector2.x1y0),
        cos = Math.cos(angle),
        cos2 = cos * cos,
        r = a[module.name].rect.clone().scale(0.5 * Math.SQRT2),
        _1_rx2 = 1 / (r.x * r.x),
        _1_ry2 = 1 / (r.y * r.y);
    length += 1 / Math.sqrt(cos2 * (_1_rx2 - _1_ry2) + _1_ry2);
    return module.offset_impl(a, b, length);
  };

  module.offset.rect = function (a, b, length) {
    var angle = module.vector2(b.x, b.y).sub(a).absolute().angle(module.vector2.x1y0),
        r = a[module.name].rect.clone().scale(0.5);
    if (angle < r.angle(module.vector2.x1y0)) {
      length += r.x / Math.cos(angle);
    } else {
      length += r.y / Math.sin(angle);
    }
    return module.offset_impl(a, b, length);
  };

  module.construct = function (svg, data_nodes, data_links) {
    var that = {},
        defs = svg.append("defs"),
        marker_start = module.make_marker(defs, "start"),
        marker_end = module.make_marker(defs, "end"),
        view_g = svg.append("g"),
        view_rect = view_g.append("rect"),
        g = view_g.append("g"),
        links = g.selectAll("line").data(data_links).enter().append("line"),
        nodes = g.selectAll("g").data(data_nodes).enter().append("g"),
        opacity = 0.8,
        marker = { end: true },
        type = "circle",
        max_node_size;

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
    } else if (type === "circle") {
      nodes.append("circle").attr({
        opacity: opacity,
        fill: "white",
        stroke: "black"
      });
    } else if (type === "rect") {
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
    max_node_size = module.update_nodes(nodes, type);

    view_g.call(d3.behavior.zoom().on("zoom", function () {
      g.attr("transform", "translate(" + d3.event.translate + ") scale(" + d3.event.scale + ")");
    }));

    that.nodes = nodes;
    that.links = links;
    that.max_node_size = max_node_size;

    that.update = function () {
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
    };

    that.resize_impl = function (w, h) {
      svg.attr({
        width: w,
        height: h
      });
      view_rect.attr({
        width: w,
        height: h
      });
    };

    return that;
  };

  module.construct_force = function (svg, data) {
    var that = module.construct(svg, data.nodes, data.links),
        force = d3.layout.force();

    force.nodes(data.nodes).links(data.links)
        .linkStrength(0.9)
        .friction(0.9)
        .linkDistance(200)
        .charge(-2000)
        .gravity(0.1)
        .theta(0.8)
        .alpha(0.1);

    force.on("tick", function () {
      that.update();
    });

    that.nodes.call(force.drag().on("dragstart", function () {
      d3.event.sourceEvent.stopPropagation();
    }));

    that.resize = function (w, h) {
      that.resize_impl(w, h);
      force.size([ w, h ]).start();
    };

    return that;
  };

  module.construct_tree = function (svg, data) {
    var tree = d3.layout.tree(),
        data_nodes = tree.nodes(data),
        data_links = tree.links(data_nodes),
        that = module.construct(svg, data_nodes, data_links),
        max_node_size;

    max_node_size = that.max_node_size.clone().scale(2);
    tree = d3.layout.tree().nodeSize([ max_node_size.x, max_node_size.y ]);
    data_nodes = tree.nodes(data);
    data_links = tree.links(data_nodes);

    that.resize = function (w, h) {
      that.resize_impl(w, h);
      that.update();
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

    if (data.nodes !== undefined) {
      that = module.construct_force(svg, data);
    } else {
      that = module.construct_tree(svg, data);
    }
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
      d3.json("dromozoa-graph.json", function (error, data) {
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
