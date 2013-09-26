<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Output
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Output</h2>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">

    <style>
        #main
        {
            display: none;
        }

        #plot_content
        {
            width: 90%;
            background: none;
            margin: 100px auto;
        }

        #tabs
        {
            border: none;
            width: 70%;
            background: none;
            display: inline-block;
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
   
            #tabs li.ui-state-default {
            border: 1px solid white;
            background: none;
            }
            #tabs li.ui-state-active {
            border: 1px solid #aaaaaa;
            border-bottom-color: White;
            }

            #tabs li.ui-state-default:hover a {
                color: rgb(69,132,211);
            }
        
        
        #description {
            display: inline-block;
            vertical-align: top;
            background: rgba(200,200,200,0.25);
            padding: 15px;
            border-radius: 10px;
            width: 25%;
        }
        
            #description h2 {
                color: gray;
                border-bottom: 1px solid rgba(43,197,109,0.4);
            }

            #description p {
                margin: 2px;
                font-size: 12px;
                color: gray;
                font-weight: 600;
                font-family: Calibri;
            }

            #description span 
            {
                color: rgb(75, 180, 236);
                font-size: 16px;
                font-weight: 800;
            }
            
        #stats thead {
            background: rgb(100,100,100);
            background: White;
             }
        #stats tbody tr:nth-child(even) {background: White;}
        #stats tbody tr:nth-child(odd) {background: rgb(240,240,240);}
    
            

        body {
          font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
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



/*color selectors and legends */

#options
{
    display: none;
}

.legend_div 
{
    margin: 20px 50px;
}
    .legend_div > div {
    position: relative;
    }
    .legend_div #options
    {
        display: inline-block;
        margin: 0px 2px 0px 5px;
        padding: 0px;
    }

    .legend_div #options .color_option {
        display: inline-block;
        width: 20px;
        height: 8px;
        border: white 2px solid;
        margin: 0px;
        cursor: pointer;
    }

    .legend_div a 
    {
        color: Gray;
        font-size: 10px;
    }

    .legend_div .legend
    {
        display: inline-block;
        height: 12px;
        border: white 2px solid;
        cursor: pointer;
        margin: 2px 10px;
        font-size: 8px;
        padding: 2px;
    }

    .legend_div .legend:hover, .legend_div .legend.active
    {
        color: White;
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
        var reportInfo = eval("( " + '<%= ViewData["reportInfo"] %>' + ")");
        var seriesNames = [];
        var probRawData;
        var histRawData;

        var formatCount = d3.format(",.0f");

        var margin = { top: 5, right: 10, bottom: 50, left: 50 },
            width = 960 - margin.left - margin.right,
            height = 500 - margin.top - margin.bottom;


        function displayStats2(data) {

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

            //get series names
            for (var i in data) {
                data[i].NodeID = reportInfo.nodeClasses[data[i].NodeID];
            }


            //display table
            for (var heading in fields) {
                var currentRow;
                var isHeader = (heading == "Series Name");
                if (isHeader) {
                    currentRow = $("#stats table thead tr");
                    currentRow.append("<th></th>");
                } else {
                    currentRow = $("<tr></tr>");
                    $("#stats table tbody").append(currentRow);
                    currentRow.append("<td>" + heading + "</td>");
                }
                for (var i in data) {

                    var myStats = data[i];

                    if(isHeader)
                        currentRow.append("<th class='color" + i + "'>" + myStats[fields[heading]] + "</th>");
                    else
                        currentRow.append("<td>" + myStats[fields[heading]] + "</td>");
                }

            }


        }

        function plotHistogram(data) {

            var x = d3.scale.linear()
                .domain([0, d3.max(data, function (d) { return d3.max(d, function (dd) { return dd.x; }); })])
                .range([0, width]);

            var y = d3.scale.linear()
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


            svg.append("text")
                .attr("class", "label")
                .attr("y", height + margin.top + margin.bottom - 10)
                .attr("x", width / 4)
                .text("Parameter: " + formData.ParameterName);

            svg.append("text")
                .attr("class", "label")
                .attr("y", (height + margin.top + margin.bottom)/2)
                .attr("x", -1 * (margin.left-10))
                .style("writing-mode", "tb")
                .text("Frequency");

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

            $("#hist").append("<div class='legend_div'></div>");
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

                    displayLegend("#hist .legend_div", data_series, "Histogram", function (d) { return d.x + "," + d.dx + "," + d.y; }, "Lower Limit,Bin Width, Frequency\n", i);

            });


        }


        function plotProb(data) {
            

            //draw plot
            var x = d3.scale.linear()
                .domain([0, d3.max(data, function (d) { return d3.max(d, function (dd) { return dd.x; }); })])
                .range([0, width]);

            var y = d3.scale.linear()
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


                    svg.append("text")
                .attr("class", "label")
                .attr("y", height + margin.top + margin.bottom - 10)
                .attr("x", width / 4)
                .text("Parameter: " + formData.ParameterName);

                    svg.append("text")
                .attr("class", "label")
                .attr("y", (height + margin.top + margin.bottom) / 2)
                .attr("x", -1 * (margin.left - 10))
                .style("writing-mode", "tb")
                .text("Probability");

                    $("#cdf").append("<div class='legend_div'></div>");

                    data.forEach(function (d, i) {
                        svg.append("path")
                .datum(d)
                .attr("d", line)
                .attr("class", "color" + i)

                        displayLegend("#cdf .legend_div",d, "Probability", function (datum) { return datum.x + "," + datum.y; }, "x,y,\n", i);
                    });


         }

         function displayLegend(div_selector, data, plotType, mapping, csv_headers, i) {
             // store raw data
             var csvRows = data.map(mapping);
             var csvString = csv_headers + csvRows.join("\n");


             var link=null;
             if(plotType != "Stats")
                 link = $("<a></a>").attr("href", "data:text/csv;charset=utf-8," + encodeURI(csvString))
                    .attr("download", seriesNames[i] + " " + plotType + ".csv")
                    .text("(download data)");

             var colorBox = $('<div class="legend">Change Color</div>').data('series_idx', i).click(chooseNewColor);

             $('<div></div>').append(colorBox).append(seriesNames[i] + " &nbsp; ").append(link).addClass('color' + i)
                            .appendTo(div_selector);
        }

        function boxPlot(datasets) {

            displayStats2(datasets);

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


            $("#box").append("<div class='legend_div'></div>");

            datasets.forEach(function (data, i) {




                var g = svg
                .append("g")
                .attr("class", "box")
                .attr("width", boxWidth)
                .attr("height", height + margin.bottom + margin.top)
                .attr("transform", "translate(" + (100 * (i + 1)) + "," + margin.top + ")")


                g.append("line")
                .attr("class", "center color" + i)
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
          .attr("y2", y(data.Percentile_05));

                g.append("line")
          .attr("class", "whisker color" + i)
          .attr("x1", 0)
          .attr("y1", y(data.Percentile_95))
          .attr("x2", boxWidth / 2)
          .attr("y2", y(data.Percentile_95));

                //mean dot
                g.append("circle")
          .attr("class", "mean color" + i)
          .attr("cx", boxWidth / 4)
          .attr("cy", y(data.Mean))
          .attr("fill", "Gray")
          .attr("r", 3);

                // Compute the tick format.
                var format = y.tickFormat(8);

                // Update box ticks.
                g.append("text")
          .attr("class", "box")
          .attr("dy", ".3em")
          .attr("dx", function (d, i) { return i & 1 ? 6 : -6 })
          .attr("x", function (d, i) { return i & 1 ? width : 0 })
          .attr("y", y(data.Percentile_25))
          .attr("text-anchor", function (d, i) { return i & 1 ? "start" : "end"; })
          .text(format(data.Percentile_25));

                g.append("text")
          .attr("class", "box")
          .attr("dy", ".3em")
          .attr("dx", function (d, i) { return i & 1 ? 6 : -6 })
          .attr("x", function (d, i) { return i & 1 ? width : 0 })
          .attr("y", y(data.Percentile_75))
          .attr("text-anchor", function (d, i) { return i & 1 ? "start" : "end"; })
          .text(format(data.Percentile_75));


                g.append("text")
          .attr("class", "whisker")
          .attr("dy", ".3em")
          .attr("dx", 6)
          .attr("x", boxWidth / 2)
          .attr("y", y(data.Percentile_05))
          .text(format(data.Percentile_05))

                g.append("text")
          .attr("class", "whisker")
          .attr("dy", ".3em")
          .attr("dx", 6)
          .attr("x", boxWidth / 2)
          .attr("y", y(data.Percentile_95))
          .text(format(data.Percentile_95))

                g.append("text")
          .attr("class", "mean")
          .attr("dy", ".3em")
          .attr("dx", 6)
          .attr("x", boxWidth / 2)
          .attr("y", y(data.Mean))
          .text(format(data.Mean))


                displayLegend("#box .legend_div", datasets, "Stats", function (d) { return d.Min + "," + d.Max + "," + d.Mean; }, "Min,Max,Mean\n", i);

            });



        }

        function chooseNewColor() {
           // var postion = $(this).offset();
            // $('#options').offset(position);
            $(this).addClass("active");
            //$('#options').insertAfter($(this));
            $('#options').appendTo($(this));
            $('#options').show("slow");
            $('#options').find(".color_option").data('series_idx', $(this).data('series_idx'));
        }


        function buildColorPicker() {
            var series = formData.NodeID;
            var options = ["red", "blue", "green", "#1db34f", "rgb(244,189,58)", "rgb(75, 180, 236)"];

            for (var t = 0; t < options.length; t++) {
                var color_option = $('<div class="color_option"></div>');
                color_option.css('background-color', options[t]);
                //color_option.data('series_idx', s);
                color_option.appendTo('#options');
            }

            $('.color_option').click(function () {
                var selectedColor = $(this).css('background-color');
                var series_idx = $(this).data('series_idx');
                d3.selectAll('rect.color' + series_idx).transition().duration(function (d, i) {
                    return i * 100;
                }).style("fill", selectedColor);

                d3.selectAll('path.color' + series_idx).transition().duration(1000).style("stroke", selectedColor);
                $('.color' + series_idx + " .legend").css('background-color', selectedColor);
                $('.color' + series_idx).css('color', selectedColor);

                $('#options').hide("slow");
                $(this).parent().parent().removeClass("active");
                event.stopPropagation();
            });

        }

        function getData(format, callback) {
            formData.format = format;
            $.getDariJson("Reports", "getData", formData, callback);
        }

        $(function () {
            $("#tabs").tabs();
            $("li.ui-state-default a").focus(function () { $(this).blur(); }); //so that orange glow doesn't show after tab is clicked

            getData("Histogram", plotHistogram);
            getData("ProbPlot", plotProb);
            getData("BasicStats", boxPlot);


            //display parameters
            for (var param in formData) {
                $("#" + param).text(formData[param]);
            }
            $("#classification").text(reportInfo.classification_name);
            var date_stamp = new Date(formData["date"] * 1000);
            $('#date').text(date_stamp.toLocaleDateString());
            for (var i = 0; i < formData.NodeID.length; i++) {
                var nodeID = formData.NodeID[i];
                seriesNames[i] = reportInfo.nodeClasses[nodeID];
            }
            buildColorPicker();

        });

    </script>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">

<div id="plot_content">

    <div id="description">

        <h2>Report Details</h2>
        <p>Analysis: <span id="analysis"></span></p>
        <p>Parameter: <span id="ParameterName"></span></p>
        <p>Classification: <span id="classification"></span></p>
        <p>Operating System: <span id="os"></span></p>
        <p>Date: <span id="date"></span></p>

        <h2>Basic Statistics</h2>
        <div id="stats">
                <table>
                    <thead><tr></tr></thead>
                    <tbody></tbody>
                </table>
        </div>

    </div>

    <div id="tabs">
      <ul>
        <li><a href="#tabs-2">Box</a></li>
        <li><a href="#tabs-3">Histogram</a></li>
        <li><a href="#tabs-4">Probability Plot</a></li>
      </ul>

      <div id="tabs-2">
        <div id="box" class="chart_type"> </div>
      </div>
      <div id="tabs-3">
        <div id="hist" class="chart_type">
        <div id="options"></div>
        </div>
      </div>
      <div id="tabs-4">
        <div id="cdf" class="chart_type"></div>
      </div>
    </div>

</div>

</asp:Content>
