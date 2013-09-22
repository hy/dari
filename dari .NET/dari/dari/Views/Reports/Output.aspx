<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Output
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Output</h2>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">

    <style>

        body {
          font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        }



#main
{
    display: none;
}

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
    height: 500px;
}

    .chart_type svg.hist
    {
        height: 500px;
        width: 960px;
    }


#plot_content
{
    width: 90%;
background: none;
margin: 50px auto;
}

#tabs
{
border: none;
width: 100%;
background: none;
}
    #tabs.ui-tabs .ui-tabs-nav li.ui-tabs-active 
    {
    }

    #tabs .ui-widget-header 
    {
        border: 0px;
        border-bottom: 1px solid #aaaaaa;
        border-radius: 0px;
        background: none;
    }

.color_option
{
    display: inline-block;
    width: 20px;
    height: 15px;
    border: White 2px solid;
    margin: 2px;
    cursor: pointer;
}



    path 
    {
        stroke: #1db34f;
        fill: none;
        stroke-width: 2px;
    }



</style>

    <body>
    <script src="http://d3js.org/d3.v2.min.js?2.10.0"></script>
    <script src="/Scripts/Plots/box.js"></script>
    <script>

        var formData = eval("( " + '<%= ViewData["parameters"] %>' + ")");

        var formatCount = d3.format(",.0f");

        var margin = { top: 10, right: 30, bottom: 30, left: 30 },
            width = 960 - margin.left - margin.right,
            height = 500 - margin.top - margin.bottom;


        function displayStats(data) {

            var fields = {};
            fields["Series Name"] = "NodeID";
            fields["Count"] = "Count";
            fields["Mean"] = "Mean";
            fields["Median"] = "Median";
            fields["5%"] = "Percentile_05";
            fields["10%"] = "Percentile_10";
            fields["25%"] = "Percentile_25";
            fields["75%"] = "Percentile_75";
            fields["90%"] = "Percentile_90";
            fields["95%"] = "Percentile_95";
            fields["Max"] = "Max";
            fields["Min"] = "Min";

            for (var i in data) {
                $("#stats table tbody").append("<tr class='bgColor" + i + "'></tr>");

            }

            for (var heading in fields) {
                $("#stats table thead tr").append("<th>" + heading + "</th>");

                for (var i in data) {
                    var cellClass = "";
                    if (heading == "Series Name")
                        cellClass = " class='fontA text_color" + i + "'";

                    var myStats = data[i];
                    $("#stats table tbody tr").eq(i).append("<td" + cellClass + ">" + myStats[fields[heading]] + "</td>");

                }
            }

        }

        function plotHistogram(data) {

            var x = d3.scale.linear()
            //.domain([0, d3.max(data, function (d) { return d.x; })])
                .domain([0, d3.max(data, function (d) { return d3.max(d, function (dd) { return dd.x; }); })])
                .range([0, width]);

            var y = d3.scale.linear()
            //.domain([0, d3.max(data, function (d) { return d.y; })])
                .domain([0, d3.max(data, function (d) { return d3.max(d, function (dd) { return dd.y; }); })])
                .range([height, 0]);

                
        var xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom");
        var yAxis = d3.svg.axis()
                .scale(y)
                .orient("left").ticks(10); 

                var svg = d3.select("#hist").append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

                svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);

                svg.append("g")
                .attr("class", "y axis")
                .call(yAxis);

                svg.selectAll("line.horizontalGrid").data(y.ticks(10)).enter()
                .append("line")
                    .attr(
                    {
                        "class": "horizontalGrid",
                        "x1": 0,
                        "x2": width,
                        "y1": function (d) { return y(d); },
                        "y2": function (d) { return y(d); }
                    });

                data.forEach(function (data_series, i) {
                    var bar = svg.selectAll(".bar"+i)
                .data(data_series)
              .enter().append("g")
                .attr("class", "bar")
                .attr("transform", function (d) { return "translate(" + x(d.x) + "," + y(d.y) + ")"; });

                    bar.append("rect")
                .attr("x", 1)
                .attr("class", "color" + i)
                .attr("width", x(data_series[0].dx) - 1)
                .attr("height", function (d) { return height - y(d.y); });

                /*
                    bar.append("text")
                .attr("dy", ".75em")
                .attr("y", 6)
                .attr("x", x(data_series[0].dx) / 2)
                .attr("text-anchor", "middle")
                .text(function (d) { return formatCount(d.y); });
                */
             });

        }


        function plotProb(data) {
            var x = d3.scale.linear()
            //.domain([0, d3.max(data, function (d) { return d.x; })])
                .domain([0, d3.max(data, function (d) { return d3.max(d, function (dd) { return dd.x; }); })])
                .range([0, width]);

            var y = d3.scale.linear()
                //.domain([0, d3.max(data, function (d) { return d.y; })])
                .domain([0, d3.max(data, function (d) { return d3.max(d, function (dd) { return dd.y; }); })])
                .range([height, 0]);
                
            var xAxis = d3.svg.axis()
                .scale(x)
                .orient("bottom");

            var yAxis = d3.svg.axis()
                .scale(y)
                .orient("left").ticks(10); 

            var line = d3.svg.line()
                .x(function (d) {
                    return x(d.x);
                })
                .y(function (d) {
                    return y(d.y);
                });


               

            var svg = d3.select("#cdf").append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            svg.selectAll("line.horizontalGrid").data(y.ticks(10)).enter()
                .append("line")
                    .attr(
                    {
                        "class": "horizontalGrid",
                        "x1": 0,
                        "x2": width,
                        "y1": function (d) { return y(d); },
                        "y2": function (d) { return y(d); }
                    });
                    
            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis);

                    svg.append("g")
                .attr("class", "y axis")
                .call(yAxis);

            data.forEach(function (d, i) {
                        svg.append("path")
                .datum(d)
                .attr("d", line)
                .attr("class", "color"+i)
            });


        }

        function boxPlot(datasets) {

            displayStats(datasets);

            var y = d3.scale.linear()
                .domain([d3.min(datasets, function (d) { return d.Min; }), d3.max(datasets, function (d) { return d.Max; })])
                .range([height, 0]);


            var yAxis = d3.svg.axis()
                .scale(y)
                .orient("left").ticks(10); 

            var svg = d3.select("#box").append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis);

            svg.selectAll("line.horizontalGrid").data(y.ticks(10)).enter()
                .append("line")
                    .attr(
                    {
                        "class": "horizontalGrid",
                        "x1": 0,
                        "x2": width,
                        "y1": function (d) { return y(d); },
                        "y2": function (d) { return y(d); }
                    });

            var boxWidth = 100;

            datasets.forEach(function (data, i) {




                var g = svg
                .append("g")
                .attr("class", "box")
                .attr("width", boxWidth)
                .attr("height", height + margin.bottom + margin.top)
                .attr("transform", "translate(" + (100 * (i+1)) + "," + margin.top + ")")


                g.append("line")
                .attr("class", "center color"+i)
                .attr("x1", boxWidth / 4)
                .attr("y1", function (d, i) { return y(data.Percentile_05); })
                .attr("x2", boxWidth / 4)
                .attr("y2", function (d) { return y(data.Percentile_95); })

                g.append("rect")
          .attr("class", "box color" + i)
          .attr("x", 0)
          .attr("y", function (d) { return y(data.Percentile_75); })
          .attr("width", boxWidth / 2)
          .attr("height", function (d) { return y(data.Percentile_25) - y(data.Percentile_75); });

                // median line.
                g.append("line")
          .attr("class", "median color" + i)
          .attr("x1", 0)
          .attr("y1", y(data.Percentile_50))
          .attr("x2", boxWidth / 2)
          .attr("y2", y(data.Percentile_50));

          //whisker
                g.append("line")
          .attr("class", "whisker color" + i)
          .attr("x1", 0)
          .attr("y1", y(data.Percentile_05))
          .attr("x2", boxWidth / 2)
          .attr("y2", y(data.Percentile_05))

                g.append("line")
          .attr("class", "whisker color" + i)
          .attr("x1", 0)
          .attr("y1", y(data.Percentile_95))
          .attr("x2", boxWidth / 2)
          .attr("y2", y(data.Percentile_95))

            });



        }

        function getData(format, callback) {
            formData.format = format;
            $.getDariJson("Reports", "getData", formData, callback);
        }

        $(function () {
            $("#tabs").tabs();

            getData("Histogram", plotHistogram);
            getData("ProbPlot", plotProb);
            getData("BasicStats", boxPlot);


        });

    </script>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">

<div id="plot_content">
    <div id="title">
        <h1><%= ViewData["analysis"] %> by <%= ViewData["classification"]%></h1>
        OS: <strong><%= ViewData["os"] %></strong> | Date: <strong><%= ViewData["date"] %></strong> | Variable: <strong><%= ViewData["variable"] %></strong>
    </div>

    <div id="tabs">
      <ul>
        <li><a href="#tabs-1">Stats</a></li>
        <li><a href="#tabs-2">Box</a></li>
        <li><a href="#tabs-3">Histogram</a></li>
        <li><a href="#tabs-4">Probability Plot</a></li>
        <li><a href="#tabs-5">Raw Data</a></li>
      </ul>
      <div id="tabs-1">
          <div id="stats" class="chart_type window">
            <table>
            <thead><tr></tr></thead>
            <tbody></tbody>
            </table>
        </div>
      </div>
      <div id="tabs-2">
        <div id="box" class="chart_type"> </div>
      </div>
      <div id="tabs-3">
        <div id="hist" class="chart_type">
        </div>
      </div>
      <div id="tabs-4">
        <div id="cdf" class="chart_type"></div>
      </div>
      <div id="tabs-5">
        <div id="raw"  class="chart_type window"><button id="Button4">Download Data</button><br /></div>
      </div>
    </div>

    <div id="options">

            <button id="toggleOverlay">Hide Overlay</button><button id="toggleHist">Hide Bars</button><button id="toggleLines">Hide Lines</button> <br />

    </div>

</div>

</asp:Content>
