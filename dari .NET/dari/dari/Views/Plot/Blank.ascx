<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<dynamic>" %>
        <% var arr = ViewData["result"];
           var analysis = ViewData["analysis"];
           var os = ViewData["os"];
           var classification = ViewData["classification"];
           var date = ViewData["date"];
            
            %>


<!DOCTYPE html>
<meta charset="utf-8">
<style>
    
    #raw div
    {
        display: inline-block;
        vertical-align: top;
    }
    
    .window
    {
        padding: 30px;
        overflow-y: auto;
        width: 80%;
    }

.chart_type 
{
    opacity: 0;
    display: none;
    height: 500px;
    position: absolute;
    top: 100px;
}

    .chart_type svg.hist
    {
        height: 500px;
        width: 960px;
    }

.bars rect {
/*  fill: #D3BCEB; */
  stroke: white;
    fill-opacity:0.65;
}

.axis text {
  font: 10px sans-serif;
}

.axis path, .axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.line {
  fill: none;
 /* stroke: purple; */
  stroke-width: 1.5px;
}

.moving 
{
    /*stroke: orange;*/
}

.datum_info
{
    /*fill: Gray;*/
    font: 300 40px Helvetica Neue;
}

.shaded 
{
   /* fill: steelblue; */
    fill-opacity:0.5;
}



.box {
  font: 10px sans-serif;
}

.box line,
.box rect,
.box circle {
  /*fill: #D3BCEB;*/
  stroke: #000;
  stroke-width: 1.5px;
}

.box .center {
  stroke-dasharray: 3,3;
}

.box .outlier {
  fill: none;
  stroke: #ccc;
}

#chart_options 
{
    /*    position: absolute;
    top: 600px;*/
}

#chart_options li
{
    display: inline-block;
    padding: 10px 20px;
    margin: 5px;
    /*background: rgba(70, 130, 180, 0.5);*/
    cursor: pointer;
    font-family: Verdana;
    font-size: large;
    color: White;
    font-weight: bold;
    color: steelblue;
    border: Gray dotted 2px;
}

#chart_options li.current
{
    background: #D3BCEB;
    color: White;
}



h1, h2, h3 
{
        font-family: Verdana;
    color: steelblue;
    margin: 20px;
}

h3
{
    color: Gray;
}
</style>
<link href='http://fonts.googleapis.com/css?family=Days+One' rel='stylesheet' type='text/css'>
<link rel="stylesheet" type="text/css" href="../../public/dataset_colors.css">
<script src="http://mbostock.github.com/d3/d3.v2.js?2.8.0"></script>
<script src="../../public/histogram-chart2.js"></script>
<script src="../../public/box.js"></script>
<script src="//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.9.1.min.js"></script>
<script>

    var margin = { top: 10, right: 50, bottom: 20, left: 50 },
    width = 120 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

    var min = Infinity,
    max = -Infinity;

    var chart = d3.box()
    .whiskers(iqr(1.5))
    .width(width)
    .height(height);

    var numOfTicks = 60;


    var svgArray = ["stats", "box", "hist", "cdf", "raw"];
    var svgArrayPtr = 2;

    var processedData = eval("(" + '<%= arr %>' + ")");
    var distributions = processedData.arrays;
    var max = processedData.max, min = processedData.min;
    var distribution = distributions[0];

    function plotData() {
        d3.select("#hist svg")
    .datum(distributions)
    .call(histogramChart(numOfTicks, "hist", processedData.series_names)
    .bins(
    d3.scale.linear()
            .domain([min, max])
            .ticks(numOfTicks)
            )
    .tickFormat(d3.format(".0f")));


        d3.select("#cdf svg")
    .datum(distributions)
    .call(histogramChart(numOfTicks, "cdf", processedData.series_names)
    .bins(
    d3.scale.linear()
            .domain([min, max])
            .ticks(numOfTicks)
            )
    .tickFormat(d3.format(".0f")));


        chart.domain([min, max]);

        var svg = d3.select("#box").selectAll("svg")
        .data(distributions)
        .enter().append("svg")
        .attr("class", "box")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.bottom + margin.top)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
        .call(chart);
    }






    function init() {
        var chart_options = d3.selectAll("#chart_options li")[0];
        for (var i = 0; i < chart_options.length; i++) {
            chart_options[i].dataIdx = i;
            chart_options[i].onclick = function () { trans(0, this.dataIdx); };
        }

        plotData();

        window.focus();
        d3.select(window).on("keydown", function () {
            switch (d3.event.keyCode) {
                case 37: trans(-1); break;
                case 39: trans(+1); break;
            }

        });

        displayStats();

        printData();

        setInterval(show, 1000);
    }

    function trans(add, ptr) {

        hide();
        if (add == 0) {
            svgArrayPtr = ptr;
        } else {
            svgArrayPtr += add;
            svgArrayPtr = (svgArrayPtr < 0) ? svgArray.length - 1 : svgArrayPtr % svgArray.length;
        }
        show();



    }

    function hide(callback) {

        d3.selectAll("#chart_options li")[0][svgArrayPtr].className = "";

        var element = "#" + svgArray[svgArrayPtr];
        d3.select(element).transition()
                .duration(750)
                .style("opacity", 0)
                .each("end", function () {
                    this.style.display = "none";
                    //callback();
                });
    }

    function show() {
        d3.selectAll("#chart_options li")[0][svgArrayPtr].className = "current";

        var element = "#" + svgArray[svgArrayPtr];

        d3.select(element).transition()
        .duration(750)
        .style("opacity", 1)
        .each("start", function () {
            this.style.display = "block";
        });

    }

    // Returns a function to compute the interquartile range.
    function iqr(k) {
        return function (d, i) {
            var q1 = d.quartiles[0],
        q3 = d.quartiles[2],
        iqr = (q3 - q1) * k,
        i = -1,
        j = d.length;
            while (d[++i] < q1 - iqr);
            while (d[--j] > q3 + iqr);
            return [i, j];
        };
    }


    function popup() {
        var string = ""
        var generator = window.open('', 'csv', 'height=400,width=600');
        for (var i in distributions[0]) {
            generator.document.write("<table>");
            generator.document.write("<tr><td>" + distributions[0][i] + "</td></tr>");
            generator.document.write("</table>");
            string += (distributions[0][i] + ",");
        }
        generator.document.close();
        $.post("/get_data", { raw_data: string });
    }

    function displayStats() {

    //<th>Series Name</th><th>Count</th><th>mean</th><th>min</th><th>median</th><th>1%</th><th>5%</th><th>10%</th><th>20%</th<th>80%</th>><th>90%</th><th>95%</th><th>99%</th><th>max</th>
        var fields = {};
        fields["Series Name"] = "name";
        fields["Count"] = "count";
        fields["Mean"] = "mean";
        fields["Median"] = "median";
        fields["1%"] = "p1";
        fields["5%"] = "p5";
        fields["10%"] = "p10";
        fields["20%"] = "p20";
        fields["80%"] = "p80";
        fields["%90"] = "p90";
        fields["%95"] = "p95";
        fields["%99"] = "p99";
        fields["Max"] = "max";

        for (var i in processedData.array_info) {
            $("#stats table tbody").append("<tr class='bgColor" + i + "'></tr>");

        }

        for (var heading in fields) {
            $("#stats table thead tr").append("<th>"+heading+"</th>");

            for (var i in processedData.array_info) {
                var cellClass = "";
                if (heading == "Series Name")
                    cellClass = " class='fontA text_color" + i + "'";

                var myStats = processedData.array_info[i];
                $("#stats table tbody tr").eq(i).append("<td" + cellClass + ">" + myStats[fields[heading]] + "</td>");

            }
        }
        /*
        for (var i in processedData.array_info) {
            var myStats = processedData.array_info[i];
            $("#stats table tbody").append("<tr class='bgColor" + i + "'><td class='fontA text_color" + i + "'>" + myStats.name + "</td><td>" + myStats.count + "</td><td>" + myStats.mean + "</td><td>" + myStats.median + "</td><td>" + myStats.p5 + "</td><td>" + myStats.p95 + "</td></tr>");

        }
        */


        
    }

    function printData() {
        for (var j in distributions) {
            var currSeries = distributions[j];
            var seriesName = processedData.array_info[j].name
            $("#raw").append("<div><table><thead><tr><th class='text_color" + j + "'>" + seriesName + "</th></tr><tbody></tbody></thead></table></div>");

            for (var i in currSeries) {
                $($("#raw table")[j]).find("tbody").append("<tr class='bgColor" + ((i % 2) ? j : "") + "'><td>" + currSeries[i] + "</td></tr>");
            }
        }

    }

    $(document).ready(function () {
        var overlay_showing = true;
        var bars_showing = true;
        var lines_showing = true;

        $('#toggleOverlay').click(function () {
            if (overlay_showing) {
                $('.shaded').attr("visibility", "hidden");
                $('line.line').attr("visibility", "hidden");
                $(this).html('Show Overlay');
            } else {
                $('.shaded').attr("visibility", "visible");
                $('line.line').attr("visibility", "visible");
                $(this).html('Hide Overlay');
            }
            overlay_showing = (!overlay_showing);
        });
        $('#toggleHist').click(function () {
            bars_showing;
            if (bars_showing) {
                $('.bars rect').attr("visibility", "hidden");
                $(this).html('Show Bars');
            } else {
                $('.bars rect').attr("visibility", "visible");
                $(this).html('Hide Bars');
            }
            bars_showing = (!bars_showing);
        });
        $('#toggleLines').click(function () {
            if (lines_showing) {
                $('path.line').attr("visibility", "hidden");
                $(this).html('Show Lines');
            } else {
                $('path.line').attr("visibility", "visible");
                $(this).html('Hide Lines');
            }
            lines_showing = (!lines_showing);
        });


        $('#downloadDataButton').click(function () {
            var string = "";
            for (var i in distributions) {
                string += processedData.series_names[i] + ",";
                for (var j in distributions[i]) {
                    string += (distributions[0][j] + ",");
                }
                string += "\r\n";
            }
            $('<form action="/download" method="post"><textarea name="raw_data">' + string + '</textarea></form>').submit();
        });

    })

</script>

<body onload="init();">
<h1><%= analysis %></h1>
<h3>OS: <%= os %> </h3>
<h3>Date: <%= date %> </h3>
<h3>Systems Classified by: <%= classification %></h3>
<div style="position: relative;">
    <div id="stats" class="chart_type window">
        <table>
        <thead><tr><%--<th>Series Name</th><th>Count</th><th>mean</th><th>min</th><th>median</th><th>1%</th><th>5%</th><th>10%</th><th>20%</th<th>80%</th>><th>90%</th><th>95%</th><th>99%</th><th>max</th>--%></tr></thead>
        <tbody></tbody>
        </table>
    </div>
    <div id="box" class="chart_type"></div>
    <div id="hist" class="chart_type">
        <svg class="hist"></svg>
        <br />
        <button id="toggleOverlay">Hide Overlay</button><button id="toggleHist">Hide Bars</button><button id="toggleLines">Hide Lines</button></div>
    <div id="cdf" class="chart_type"><svg class="hist"></svg></div>
    <div id="raw"  class="chart_type window"><button id="downloadDataButton">Download Data</button><br /></div>
    
</div>

<ul id="chart_options">
<li>Stats</li>
<li>Box</li>
<li>Histogram</li>
<li>Probability Plot</li>
<li>Raw Data</li>
<a href="#" onclick="popup()">Download Data</a>
</ul>

</body>