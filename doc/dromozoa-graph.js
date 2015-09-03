(function (root) {
  var D = root.dromozoa;

  if (D === undefined) {
    root.dromozoa = D = {};
  }

  D.make_id = function () {
    var namespace = "dromozoa-", counter = 0;
    return function () {
      ++counter;
      return namespace + counter;
    };
  }();

  D.make_arrow = function (defs, width, height, attr) {
    var marker, path;

    marker = defs.append("marker").attr({
      id: D.make_id(),
      refX: 0,
      refY: height / 2,
      markerWidth: width,
      markerHeight: height,
      orient: "auto"
    });

    path = marker.append("path").attr("d", d3.svg.line()([
      [ 0, 0 ],
      [ width, height / 2 ],
      [ 0, height ]
    ]));
    if (attr !== undefined) {
      $.each(attr, function (k, v) {
        path.attr(k, v);
      });
    }

    return marker;
  };

  D.make_boxed_text = function (svg, line) {
    var g, rect, text;

    g = svg.append("g");

    rect = g.append("rect");

    text = g.append("text").text(line).attr({
      "font-size": 40,
      x: 100,
      y: 50,
      "text-anchor": "start"
    });

    var b = text.node().getBBox();
    console.log(b);
    rect.attr({
      x: b.x,
      y: b.y,
      width: b.width,
      height: b.height,
      fill: "red"
    });



    return g
  };

  $(function () {
    var svg, defs, arrow;

    svg = d3.select("body").append("svg").attr({
      width: 640,
      height: 480
    });

    defs = svg.append("defs");

    arrow = D.make_arrow(defs, 2 * Math.sqrt(3), 4);

    var path = svg.append("path").attr({
      d: d3.svg.line().interpolate("basis")([
        [ 10, 100 ],
        [ 400, 90 ],
        [ 530, 400 ]
      ]),
      fill: "none",
      stroke: "black",
      "stroke-width": 8,
      "marker-end": "url(#" + arrow.attr("id") + ")"
    });

    var size = path.node().getTotalLength() * 2;
    console.log(size);

    path.attr("stroke-dasharray", size + " " + size);
    path.attr("stroke-dashoffset", size);
    path.transition().duration(2000).attr("stroke-dashoffset", 0);

    var bbox = svg.append("rect").attr({
      x: 0,
      y: 0,
      width: 0,
      height: 0,
      fill: "green",
      opacity: 0.5
    });

    var circle = svg.append("circle").attr({
      cx: 0,
      cy: 0,
      r: 0,
      fill: "yellow",
      opacity: 0.5
    });

    var text = svg.append("text").text("東京").attr({
      x: 320,
      y: 240,
      "font-size": 50,
      "font-weight": 100,
      "text-anchor": "middle",
      fill: "red"
    });
    var b = text.node().getBBox();
    bbox.attr(b);

    circle.attr({
      cx: b.x + b.width / 2,
      cy: b.y + b.height / 2,
      r: Math.sqrt(b.width * b.width + b.height * b.height) / 2
    });

    var t2 = D.make_boxed_text(svg, "日本語");


  });
}(window));
