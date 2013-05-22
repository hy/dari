function histogramChart(numOfTicks, chart_type, series_names) {
     var margin = {top: 20, right: 0, bottom: 20, left: 50},
        width = 960,
        height = 500;
    var bar_width = (width - margin.left - margin.right) / numOfTicks;

    var histogram = d3.layout.histogram(),
        x = d3.scale.linear(),
        y = d3.scale.linear(),
    //[0.1, 1, 5, 20, 80, 95, 99, 99.99]
        yAxis = d3.svg.axis().scale(y).orient("left").tickSize(6, 0).tickValues((chart_type == "cdf")?[0, 25, 50, 75,100]:[]).tickFormat(d3.format("g")),
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
        selection.each(function (distributions) {

            var allData = [];
            // Select the svg element, if it exists.
            //var svg = d3.select(this).selectAll("svg").data([data]);
            var svg = d3.select(this).selectAll("svg").data([distributions]);

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

            //add movable vertical line
            var verti_line = gEnter.append("line")
                .attr("class", "moving line")
                .attr("stroke", "orange")
                .attr("x1", width / 2)
                .attr("x2", width / 2)
                .attr("y1", height)
                .attr("y2", 0);

//            var stroke_colors = ["purple", "DarkBlue", "orange"];
//            var fill_colors = ["#D3BCEB", "LightBlue", "yellow"];
//            var overlay_colors = ["MediumPurple", "steelblue", "PaleGoldenRod"];

            var graphOverlays = [];
            var datumInfos = [];
            var horizLines = [];

            var yMax = 0;

            distributions.forEach(function (data, current) {
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

                //normlize values
                data = data.map(function (d) {
                    d.perc = d.cum * 100 / sum
                    d.norm = d.y * 100 / sum;
                    if (chart_type == "cdf")
                        d.y = d.perc;
                    else
                        d.y = d.norm;

                    if (d.y > yMax)
                        yMax = d.y;
                    return d;
                });

                allData.push(data);

                // Update the x-scale.
                x.domain([data[0].x, data[data.length - 1].x])
                .range([0, width - margin.left - margin.right]);

            });

            //var max = 100;
            //                if (chart_type == "hist")
            //                    max = d3.max(data, function (d) { return d.y; });

            y.domain([0, yMax])
                .range([height - margin.top - margin.bottom, 0]);

            distributions.forEach(function (raw_data, current) {

                var data = allData[current];

                var shaded_graph = gEnter.append("path")
                .datum(data)
                .attr("class", "shaded overlay_color"+current)
                //.attr("fill", overlay_colors[current])
                .on("mouseover", moveLine)
                .attr("d", area);
                graphOverlays.push(shaded_graph);

                gEnter.append("path")
                .datum(data)
                .attr("class", "line" + " stroke_color" + current)
                //.attr("stroke", stroke_colors[current])
                .attr("d", line)
                .on("mouseover", moveLine);



                //add movable horizotal line
                var horiz_line = gEnter.append("line")
                    .attr("class", "moving line" + " stroke_color" + current)
                    //.attr("stroke", stroke_colors[current])
                    .attr("x1", "0")
                    .attr("x2", width)
                    .attr("y1", height / 2)
                    .attr("y2", height / 2);
                horizLines.push(horiz_line);



                //add text
                var datum_info = gEnter.append("text")
                .text("")
                .attr("class", "datum_info fill_color"+current)
                //.attr("fill", stroke_colors[current])
                .attr("x", 20)
                .attr("y", 100 + 50 * current);
                datumInfos.push(datum_info);

                // Update the bars.
                var bar = svg.select(".bars").selectAll(".bar").data(data);
                bar.enter().append("rect");
                bar.exit().remove();
                bar.attr("width", bar_width)
                    .attr("x", function (d) { return x(d.x); })
                    .attr("y", function (d) {
                        return y(d.y);
                    })
                    //.attr("fill", fill_colors[current])
                    .attr("class", "fill_color" + current)
                    .attr("height", function (d) { return y.range()[0] - y(d.y); })
                    .on("mouseover", moveLine)
                    .order();

                function moveLine(d, i) {

                    var coor = d3.mouse(this);
                    var coorX = coor[0];
                    var coorY = coor[1];

                    var lineX;

                    for (var j = 0; j < graphOverlays.length; j++) {
                        var subdata = [];
                        var k = 0;
                        var currDataSet = allData[j];
                        for (k in currDataSet) {
                            if (currDataSet[k].x < x.invert(coorX))
                                subdata.push(currDataSet[k]);
                            else
                                break;
                        }
                        datum_val = currDataSet[k - 1];

                        var newpath = area(subdata);


                        lineX = x(datum_val.x);
                        var lineY = y(datum_val.y);

                        horizLines[current].transition()
                            .duration(750)
                            .attr("y1", lineY)
                            .attr("y2", lineY);



                        graphOverlays[j].attr("d", newpath);
                        datumInfos[j].text(series_names[j] + ": (" + datum_val.x + ", " + d3.round(datum_val.perc, 2) + "%)");
                    }

                    verti_line.transition()
                    .duration(750)
                    .attr("x1", lineX)
                    .attr("x2", lineX);
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