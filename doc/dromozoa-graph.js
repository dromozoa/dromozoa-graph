// Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
//
// This file is part of dromozoa-graph.
//
// dromozoa-graph is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// dromozoa-graph is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-graph.  If not, see <http://www.gnu.org/licenses/>.

/*jslint this: true, white: true */
/*global global */
"use strict";
(function (root) {
  var $ = root.jQuery, d3 = root.d3, module = (function () {
    var that;
    if (root.dromozoa === undefined) {
      root.dromozoa = {};
    }
    if (root.dromozoa.graph === undefined) {
      that = function (data) {
        that.data = data;
      };
      that.namespace = "dromozoa-graph";
      that.data = "dromozoa-graph.json";
      root.dromozoa.graph = that;
    }
    return root.dromozoa.graph;
  }());

  if (root.console !== undefined && root.console.log !== undefined) {
    module.console = root.console;
  } else {
    module.console = {
      assert: $.noop,
      log: $.noop
    };
  }

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
    var that = [
      m00, m01, m02, // 0, 1, 2
      m10, m11, m12, // 3, 4, 5
      m20, m21, m22  // 6, 7, 8
    ];

    that.determinant = function () {
      var m00 = that[0], m01 = that[1], m02 = that[2],
          m10 = that[3], m11 = that[4], m12 = that[5],
          m20 = that[6], m21 = that[7], m22 = that[8];
      return m00 * (m11 * m22 - m21 * m12)
          - m01 * (m10 * m22 - m20 * m12)
          + m02 * (m10 * m21 - m20 * m11);
    };

    that.set_zero = function () {
      that[0] = 0; that[1] = 0; that[2] = 0;
      that[3] = 0; that[4] = 0; that[5] = 0;
      that[6] = 0; that[7] = 0; that[8] = 0;
      return that;
    };

    that.set_identity = function () {
      that[0] = 1; that[1] = 0; that[2] = 0;
      that[3] = 0; that[4] = 1; that[5] = 0;
      that[6] = 0; that[7] = 0; that[8] = 1;
      return that;
    };

    that.set_row = function (row, x, y, z) {
      row *= 3;
      that[row] = x;
      that[row + 1] = y;
      if (z !== undefined) {
        that[row + 2] = z;
      }
      return that;
    };

    that.set_col = function (col, x, y, z) {
      that[col] = x;
      that[col + 3] = y;
      if (z !== undefined) {
        that[col + 6] = z;
      }
      return that;
    };

    that.transpose = function () {
      var tmp = that[1]; that[1] = that[3]; that[3] = tmp;
      tmp = that[2]; that[2] = that[6]; that[6] = tmp;
      tmp = that[5]; that[5] = that[7]; that[7] = tmp;
      return that;
    };

    that.invert = function () {
      var d = that.determinant(),
          m00 = that[0], m01 = that[1], m02 = that[2],
          m10 = that[3], m11 = that[4], m12 = that[5],
          m20 = that[6], m21 = that[7], m22 = that[8],
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
        that[0] = n00 * s; that[1] = n01 * s; that[2] = n02 * s;
        that[3] = n10 * s; that[4] = n11 * s; that[5] = n12 * s;
        that[6] = n20 * s; that[7] = n21 * s; that[8] = n22 * s;
      }
      return that;
    };

    that.rot_x = function (angle) {
      var c = Math.cos(angle),
          s = Math.sin(angle);
      that[0] = 1; that[1] = 0; that[2] =  0;
      that[3] = 0; that[4] = c; that[5] = -s;
      that[6] = 0; that[7] = s; that[8] =  c;
      return that;
    };

    that.rot_y = function (angle) {
      var c = Math.cos(angle),
          s = Math.sin(angle);
      that[0] =  c; that[1] = 0; that[2] = s;
      that[3] =  0; that[4] = 1; that[5] = 0;
      that[6] = -s; that[7] = 0; that[8] = c;
      return that;
    };

    that.rot_z = function (angle) {
      var c = Math.cos(angle),
          s = Math.sin(angle);
      that[0] = c; that[1] = -s; that[2] = 0;
      that[3] = s; that[4] =  c; that[5] = 0;
      that[6] = 0; that[7] =  0; that[8] = 1;
      return that;
    };

    that.transform = function (t, result) {
      var x = t.x, y = t.y, z = t.z;
      if (result === undefined) {
        result = t;
      }
      if (z === undefined) {
        result.x = that[0] * x + that[1] * y + that[2];
        result.y = that[3] * x + that[4] * y + that[5];
      } else {
        result.x = that[0] * x + that[1] * y + that[2] * z;
        result.y = that[3] * x + that[4] * y + that[5] * z;
        result.z = that[6] * x + that[7] * y + that[8] * z;
      }
      return result;
    };

    that.clone = function () {
      return module.matrix3(that[0], that[1], that[2], that[3], that[4], that[5], that[6], that[7], that[8]);
    };

    that.toString = function () {
      return "[[" + that[0] + "," + that[1] + "," + that[2]
          + "],[" + that[3] + "," + that[4] + "," + that[5]
          + "],[" + that[6] + "," + that[7] + "," + that[8] + "]]";
    };

    return that;
  };
  module.matrix3.zero = module.matrix3().set_zero();
  module.matrix3.identity = module.matrix3().set_identity();

  module.make_id = function () {
    module.make_id.counter += 1;
    return module.namespace + "-" + module.make_id.counter;
  };
  module.make_id.counter = 0;

  module.marker = function (defs, type) {
    var bbox = module.marker.bbox,
        hbox = module.marker.hbox,
        marker = defs.append("marker"),
        path = marker.append("path");
    marker.attr({
      id: module.make_id(),
      refX: hbox.x,
      refY: hbox.y,
      markerWidth: bbox.x,
      markerHeight: bbox.y,
      orient: "auto"
    });
    if (type === "start") {
      path.attr("d", d3.svg.line()([ [ bbox.x, 0 ], [ 0, hbox.y ], [ bbox.x, bbox.y ] ]));
    } else {
      path.attr("d", d3.svg.line()([ [ 0, 0 ], [ bbox.x, hbox.y ], [ 0, bbox.y ] ]));
    }
    return marker;
  };
  module.marker.bbox = module.vector2(8, 8);
  module.marker.hbox = module.vector2(4, 4);

  module.rect = function () {
    var that = {};

    that.append = function (g) {
      return g.append("rect");
    };

    that.update = function (g, d) {
      var data = d[module.namespace],
          hbox = data.hbox,
          bbox = hbox.clone().scale(2);
      data.bbox = bbox;
      return g.select("rect").attr({
        x: -hbox.x,
        y: -hbox.y,
        width: bbox.x,
        height: bbox.y
      });
    };

    that.offset = function (a, b) {
      var angle = module.vector2(b.x, b.y).sub(a).absolute().angle(module.vector2.x1y0);
      if (angle < a.hbox.angle(module.vector2.x1y0)) {
        return a.hbox.x / Math.cos(angle);
      } else {
        return a.hbox.y / Math.sin(angle);
      }
    };

    return that;
  };

  module.circle = function () {
    var that = {};

    that.append = function (g) {
      return g.append("circle");
    };

    that.update = function (g, d) {
      var data = d[module.namespace],
          hbox = data.hbox,
          r = hbox.length(),
          bbox = module.vector2(r, r).scale(2);
      data.bbox = bbox;
      return g.select("circle").attr("r", r);
    };

    that.offset = function (a) {
      return a.hbox.length();
    };

    return that;
  };

  module.ellipse = function () {
    var that = {};

    that.append = function (g) {
      return g.append("ellipse");
    };

    that.update = function (g, d) {
      var data = d[module.namespace],
          hbox = data.hbox,
          rx = hbox.x * Math.SQRT2,
          ry = hbox.y * Math.SQRT2,
          bbox = module.vector2(rx, ry).scale(2);
      data.bbox = bbox;
      return g.select("ellipse").attr({
        rx: rx,
        ry: ry
      });
    };

    that.offset = function (a, b) {
      var angle = module.vector2(b.x, b.y).sub(a).angle(module.vector2.x1y0),
          cos = Math.cos(angle),
          cos2 = cos * cos,
          r = a.hbox.clone().scale(Math.SQRT2),
          _1_rx2 = 1 / (r.x * r.x),
          _1_ry2 = 1 / (r.y * r.y);
      return 1 / Math.sqrt(cos2 * (_1_rx2 - _1_ry2) + _1_ry2);
    };

    return that;
  };

  module.update_links = function (links) {
    links.each(function (d) {
      var data = d[module.namespace],
          g = d3.select(this),
          text = g.select("text"),
          text_dy = text.attr("dy"),
          text_bbox = text.node().getBBox(),
          line = g.select("line"),
          line_stroke_width = line.attr("stroke-width"),
          offset;
      if (data === undefined) {
        data = {};
        d[module.namespace] = data;
      }
      if (text_dy === null) {
        text_dy = 0;
      }
      text.attr("dy", text_dy - (text_bbox.y + text_bbox.height));
      if (line_stroke_width === null) {
        line_stroke_width = 1;
      }
      offset = line_stroke_width * module.marker.hbox.x;
      if (line.attr("marker-start") !== null) {
        data.start_offset = offset;
      } else {
        data.start_offset = 0;
      }
      if (line.attr("marker-end") !== null) {
        data.end_offset = offset;
      } else {
        data.end_offset = 0;
      }
    });
  };

  module.update_nodes = function (nodes, shape) {
    var bbox = module.vector2(0, 0);
    nodes.each(function (d) {
      var data = d[module.namespace],
          g = d3.select(this),
          text = g.select("text"),
          text_dy = text.attr("dy"),
          text_bbox = text.node().getBBox(),
          hbox = module.vector2(text_bbox.width, text_bbox.height).scale(0.5);
      if (data === undefined) {
        data = {};
        d[module.namespace] = data;
      }
      if (hbox.x < hbox.y) {
        hbox.x = hbox.y;
      }
      data.shape = shape;
      data.hbox = hbox;
      if (text_dy === null) {
        text_dy = 0;
      }
      text.attr("dy", text_dy - (text_bbox.y + hbox.y));
      shape.update(g, d);
      if (bbox.x < data.bbox.x) { bbox.x = data.bbox.x; }
      if (bbox.y < data.bbox.y) { bbox.y = data.bbox.y; }
    });
    return bbox;
  };

  module.offset = function (a, b, length) {
    return module.vector2(b.x, b.y).sub(a).normalize().scale(length + a.shape.offset(a, b)).add(a);
  };

  module.construct = function (svg, data_nodes, data_links) {
    var that = {},
        defs = svg.append("defs"),
        marker_start = module.marker(defs, "start"),
        marker_end = module.marker(defs, "end"),
        view_g = svg.append("g"),
        view_rect = view_g.append("rect"),
        g = view_g.append("g"),
        links = g.append("g").selectAll("g").data(data_links).enter().append("g"),
        nodes = g.append("g").selectAll("g").data(data_nodes).enter().append("g"),
        opacity = 0.8,
        marker = { end: true },
        shape = module.ellipse(),
        node_bbox;

    view_rect.attr("fill", "white");

    links.append("line").attr({
      opacity: opacity,
      stroke: "black"
    });
    if (marker.start) {
      links.select("line").attr("marker-start", "url(#" + marker_start.attr("id") + ")");
    }
    if (marker.end) {
      links.select("line").attr("marker-end", "url(#" + marker_end.attr("id") + ")");
    }
    links.append("text").text(function (d) {
      if (d.text === undefined) {
        return "";
      } else {
        return d.text;
      }
    }).attr("text-anchor", "middle");

    shape.append(nodes).attr({
      opacity: opacity,
      fill: "white",
      stroke: "black"
    });

    nodes.append("text").text(function (d) {
      return d.text;
    }).attr("text-anchor", "middle");

    module.update_links(links);
    node_bbox = module.update_nodes(nodes, shape);

    view_g.call(d3.behavior.zoom().on("zoom", function () {
      g.attr("transform", "translate(" + d3.event.translate + ") scale(" + d3.event.scale + ")");
    }));

    that.nodes = nodes;
    that.links = links;
    that.node_bbox = node_bbox;

    that.update = function (matrix) {
      nodes.each(function (d) {
        var data = d[module.namespace];
        matrix.transform(d, data);
      });

      links.each(function (d) {
        var data = d[module.namespace],
            source = d.source[module.namespace],
            target = d.target[module.namespace],
            start = module.offset(source, target, data.start_offset),
            end = module.offset(target, source, data.end_offset),
            middle = start.clone().add(end).scale(0.5),
            vector = end.clone().sub(start),
            angle = module.vector2.x1y0.angle(vector) / Math.PI * 180;
        data.start = start;
        data.end = end;
        data.middle = middle;
        if (vector.x < 0) {
          data.angle = 180;
        } else {
          data.angle = 0;
        }
        if (vector.y < 0) {
          data.angle -= angle;
        } else {
          data.angle += angle;
        }
      });

      nodes.attr("transform", function (d) {
        var data = d[module.namespace];
        return "translate(" + data.x + "," + data.y + ")";
      });

      links.select("text").attr({
        x: function (d) {
          return d[module.namespace].middle.x;
        },
        y: function (d) {
          return d[module.namespace].middle.y;
        },
        transform: function (d) {
          var data = d[module.namespace];
          return "rotate(" + data.angle + " " + data.middle.x + " " + data.middle.y + ")";
        }
      });

      links.select("line").attr({
        x1: function (d) {
          return d[module.namespace].start.x;
        },
        y1: function (d) {
          return d[module.namespace].start.y;
        },
        x2: function (d) {
          return d[module.namespace].end.x;
        },
        y2: function (d) {
          return d[module.namespace].end.y;
        }
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
    var force = d3.layout.force(),
        that = module.construct(svg, data.nodes, data.links);
    force.nodes(data.nodes).links(data.links)
        .linkDistance(that.node_bbox.length())
        .charge(-1000);

    force.on("tick", function () {
      that.update(module.matrix3.identity);
    });

    that.nodes.call(force.drag().on("dragstart", function () {
      d3.event.sourceEvent.stopPropagation();
    }));

    that.resize = function (w, h) {
      var scale = that.node_bbox.length(),
          hbox = module.vector2(w, h).scale(0.5);
      that.resize_impl(w, h);
      $.each(data.nodes, function (i, v) {
        var rotation = module.matrix3().rot_z(Math.PI * 2 * i / data.nodes.length),
            position = rotation.transform(module.vector2.x1y0.clone()).scale(scale).add(hbox);
        v.x = position.x;
        v.y = position.y;
      });
      force.size([ w, h ]).start();
    };

    return that;
  };

  module.construct_tree = function (svg, data) {
    var tree = d3.layout.tree(),
        data_nodes = tree.nodes(data),
        data_links = tree.links(data_nodes),
        that = module.construct(svg, data_nodes, data_links),
        mode = "lr", // tb bt lr rl
        rotation = module.matrix3().set_identity(),
        node_bbox = that.node_bbox,
        node_size = node_bbox.clone();
    if (mode === "rl") {
      rotation.rot_z(Math.PI * 0.5);
    } else if (mode === "bt") {
      rotation.rot_z(Math.PI);
    } else if (mode === "lr") {
      rotation.rot_z(Math.PI * 1.5);
    }
    rotation.transform(node_size.add(module.vector2(node_bbox.y, node_bbox.y))).absolute();

    tree = d3.layout.tree().nodeSize([ node_size.x, node_size.y ]);
    data_nodes = tree.nodes(data);
    data_links = tree.links(data_nodes);

    that.resize = function (w, h) {
      var translation = module.vector2(w * 0.5, that.node_bbox.y * 1.5);
      if (mode === "rl") {
        translation.x = w - (that.node_bbox.x * 0.5 + that.node_bbox.y);
        translation.y = h * 0.5;
      } else if (mode === "bt") {
        translation.y = h - translation.y;
      } else if (mode === "lr") {
        translation.x = that.node_bbox.x * 0.5 + that.node_bbox.y;
        translation.y = h * 0.5;
      }
      that.resize_impl(w, h);
      that.update(rotation.clone().set_col(2, translation.x, translation.y));
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
      if (module.data === undefined) {
        module.data = "dromozoa-graph.json";
      }
      if (typeof module.data === "string") {
        d3.json(module.data, function (error, data) {
          if (error !== null) {
            module.console.log(error);
            root.alert("could not load json");
            return;
          }
          module.main(data);
        });
      } else {
        module.main(module.data);
      }
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

  module.test = function () {
    var matrix, vector;
    matrix = module.matrix3().set_zero();
    module.console.assert(matrix.toString() === "[[0,0,0],[0,0,0],[0,0,0]]");
    matrix = module.matrix3().set_identity();
    module.console.assert(matrix.toString() === "[[1,0,0],[0,1,0],[0,0,1]]");
    matrix = module.matrix3().set_identity().set_col(2, 17, 23);
    module.console.assert(matrix.toString() === "[[1,0,17],[0,1,23],[0,0,1]]");
    matrix = module.matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9).transpose();
    module.console.assert(matrix.toString() === "[[1,4,7],[2,5,8],[3,6,9]]");
    matrix = module.matrix3(1, 2, 1, 2, 1, 0, 1, 1, 2).invert();
    vector = matrix.transform({ x: 1, y: 0, z: 0 });
    module.console.assert(Math.abs(vector.x + 0.4) < 0.000001);
    module.console.assert(Math.abs(vector.y - 0.8) < 0.000001);
    module.console.assert(Math.abs(vector.z + 0.2) < 0.000001);
    matrix = module.matrix3().rot_z(Math.PI * 0.5);
    vector = matrix.transform(module.vector2.x1y0.clone());
    module.console.assert(Math.abs(vector.x) < 0.000001);
    module.console.assert(Math.abs(vector.y - 1) < 0.000001);
  };
  // module.test();
}(this.self || global));
