function histogramChart(numOfTicks, chart_type) {
     var margin = {top: 20, right: 0, bottom: 20, left: 50},
        width = 960,
        height = 500;
    var bar_width = (width - margin.left - margin.right) / numOfTicks;

    var histogram = d3.layout.histogram(),
        x = d3.scale.linear(),
        y = d3.scale.linear(),
    //[0.1, 1, 5, 20, 80, 95, 99, 99.99]
        yAxis = d3.svg.axis().scale(y).orient("left").tickSize(6, 0).tickValues((chart_type == "cdf")?[0, 0.25, 0.5, 0.75,1]:[]).tickFormat(d3.format("g")),
        xAxis = d3.svg.axis().scale(x).orient("bottom").tickSize(6, 0);

    var sum=0;

    var line = d3.svg.line()
        .interpolate("cardinal")
        .x(function (d) {
            return x(d.x);
        })
        .y(function (d) {
            if (chart_type == "hist")
                return y(d.y);
            else
                return y(d.perc);
        });

    var area = d3.svg.area()
        .interpolate("cardinal")
        .x(function (d) { return x(d.x); })
        .y0(height - margin.top - margin.bottom)
        .y1(function (d) { return y(d.y); });

    function chart(selection) {
        selection.each(function (data) {

            // Compute the histogram.
            data = histogram(data);

            //add cumulative data
            var prev = 0;
            data = data.map(function (d) {
                sum = prev + d.y;
                d.cum = sum;
                prev = sum;
                return d;
            });

            //normlize cdf data
            data = data.map(function (d) {
                d.perc = d.cum * 100 / sum
                if (chart_type == "cdf")
                    d.y = d.perc;

                return d;
            });


            // Update the x-scale.
            x.domain([data[0].x, data[data.length - 1].x])
            .range([0, width - margin.left - margin.right]);

            var max = 100;
            if (chart_type == "hist")
                max = d3.max(data, function (d) { return d.y; });

            y.domain([0, max])
            .range([height - margin.top - margin.bottom, 0]);

            // Select the svg element, if it exists.
            var svg = d3.select(this).selectAll("svg").data([data]);

            // Otherwise, create the skeletal chart.
            var gEnter = svg.enter().append("svg").append("g");
            gEnter.append("g").attr("class", "bars");
            gEnter.append("g").attr("class", "x axis");
            gEnter.append("g").attr("class", "y axis");

            // Update the outer dimensions.
            svg.attr("width", width)
            .attr("height", height);

            // Update the inner dimensions.
            var g = svg.select("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            var shaded_graph = gEnter.append("path")
            .datum(data)
            .attr("class", "shaded")
            .on("mouseover", moveLine)
            .attr("d", area);

            gEnter.append("path")
            .datum(data)
            .attr("class", "line")
            .attr("d", line)
            .on("mouseover", moveLine);



            //add movable horizotal line
            var horiz_line = gEnter.append("line")
        .attr("class", "moving line")
        .attr("x1", "0")
        .attr("x2", width)
        .attr("y1", height / 2)
        .attr("y2", height / 2);

            //add movable vertical line
            var verti_line = gEnter.append("line")
            .attr("class", "moving line")
            .attr("x1", width / 2)
            .attr("x2", width / 2)
            .attr("y1", height)
            .attr("y2", 0);


            //add text
            var datum_info = gEnter.append("text")
            .text("")
            .attr("class", "datum_info")
            .attr("x", 20)
            .attr("y", 50);

            // Update the bars.
            var bar = svg.select(".bars").selectAll(".bar").data(data);
            bar.enter().append("rect");
            bar.exit().remove();
            bar.attr("width", bar_width)
                .attr("x", function (d) { return x(d.x); })
                .attr("y", function (d) {
                    return y(d.y);
                })
                .attr("height", function (d) { return y.range()[0] - y(d.y); })
                .on("mouseover", moveLine)
                .order();

            var allData = data;
            function moveLine(d, i) {

                var coor = d3.mouse(this);
                var coorX = coor[0];
                var coorY = coor[1];

                //var idx = Math.floor(coor[0] * d.length / (width - margin.left - margin.right));
                //var subdata = d.slice(0, idx);
                var subdata = [];

                datum_val = d;

                if (datum_val.x) {
                    subdata = allData.slice(0, i + 1);
                } else {
                    var k = 0;
                    for (k in d) {
                        if (d[k].x < x.invert(coorX))
                            subdata.push(d[k]);
                        else
                            break;
                    }

                    datum_val = d[k - 1];
                }

                var lineX = x(datum_val.x);
                var lineY = y(datum_val.y);

                horiz_line.transition()
                .duration(750)
                .attr("y1", lineY)
                .attr("y2", lineY);

                verti_line.transition()
                .duration(750)
                .attr("x1", lineX)
                .attr("x2", lineX);

                datum_info.text(d3.round(datum_val.perc, 2) + "%: " + datum_val.x);

                //var newpath = line(subdata);
                //newpath += ("L" + coorX + "," + coorY + "L" + coorX + "," + (height - margin.top - margin.bottom) + "L" + x(d[0].x) + "," + (height - margin.top - margin.bottom) + "Z");
                var newpath = area(subdata);

                shaded_graph
                //                .transition()
                //                .duration(750)
                .attr("d", newpath);
            }

            // Update the x-axis.
            g.select(".x.axis")
        .attr("transform", "translate(0," + y.range()[0] + ")")
        .call(xAxis);

            // Update the y-axis.
            g.select(".y.axis")
            //.attr("transform", "translate(0," + x.range()[0] + ")")
        .call(yAxis);
        });
    }

  chart.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return chart;
  };

  chart.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return chart;
  };

  // Expose the histogram's value, range and bins method.
  d3.rebind(chart, histogram, "value", "range", "bins");

  // Expose the x-axis' tickFormat method.
  d3.rebind(chart, xAxis, "tickFormat");


  // Expose the x-axis' tickFormat method.
//  d3.rebind(chart, yAxis, "tickFormat");


  return chart;
}