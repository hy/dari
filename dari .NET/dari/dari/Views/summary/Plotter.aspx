<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Plotter
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">

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
        <div id="box" class="chart_type"></div>
      </div>
      <div id="tabs-3">
        <div id="hist" class="chart_type">
            <svg class="hist"></svg></div>
      </div>
      <div id="tabs-4">
        <div id="cdf" class="chart_type"><svg class="hist"></svg></div>
      </div>
      <div id="tabs-5">
        <div id="raw"  class="chart_type window"><button id="Button4">Download Data</button><br /></div>
      </div>
    </div>

    <div id="options">

<%--        <% foreach (string series_name in (string[])ViewData["series"])
           { %>
        <%=series_name %> <div class="color_option"></div><div class="color_option"></div><div class="color_option"></div>
            <br />
        <% } %>--%>
            <button id="Button1">Hide Overlay</button><button id="Button2">Hide Bars</button><button id="Button3">Hide Lines</button> <br />

    </div>

</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">

<style>
    

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





body{
    background: rgb(255,255,153);
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
    #tabs .ui-widget-header
    {
        background: none;
        border: none;
    }

    #tabs .ui-tabs-panel
    {
        border: 1px solid #aaaaaa;
        background: White;
        border-color: rgb(120,152,26);
    
    }
    #tabs .ui-state-default
    {
        background: rgb(165,208,40);
        float: right;
        border-color: rgb(120,152,26);
    }
        #tabs .ui-state-default:hover
        {
            background: Gray;
        }
        #tabs .ui-state-default a
        {
            color: White;
        }
    #tabs li.ui-tabs-active
    {
        background: White;
        }
        #tabs li.ui-tabs-active:hover
        {
            background: White;
            }
        #tabs li.ui-tabs-active a
        {
            color: rgb(165,208,40);
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


</style>

<script src="http://mbostock.github.com/d3/d3.v2.js?2.8.0"></script>
<script src="../../public/histogram-chart2.js"></script>
<script src="../../public/box.js"></script>

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


    var parameters = eval("(" + '<%= ViewData["parameters"] %>' + ")");


    var processedData
    var distributions;
    var max;
    var distribution;

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
            $("#stats table thead tr").append("<th>" + heading + "</th>");

            for (var i in processedData.array_info) {
                var cellClass = "";
                if (heading == "Series Name")
                    cellClass = " class='fontA text_color" + i + "'";

                var myStats = processedData.array_info[i];
                $("#stats table tbody tr").eq(i).append("<td" + cellClass + ">" + myStats[fields[heading]] + "</td>");

            }
        }

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


        $("#tabs").tabs();

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


        /*prepare color selector */
        var series = <%= ViewData["series"]%>;
        var options = ["red", "blue", "green"];
        for (var s = 0; s < series.length; s++){
            $('#options').append("<span>"+series[s]+"</span>");
            for(var t = 0; t < options.length; t++){
                var color_option = $('<div class="color_option series'+s+'"></div>');
                color_option.css('background-color', options[t]);
                color_option.data('series_idx', s);
                color_option.appendTo('#options');
            }
            $('#options').append("<br>");
        }

        $('.color_option').click(function () {
            var selectedColor = $(this).css('background-color');
            var series_idx = $(this).data('series_idx');
            $('.fill_color'+series_idx).attr('fill', selectedColor);
            $('.series'+series_idx).css('border-width','');
            $(this).css('border-width','4px');
        });



        $.ajax({
            url: '/Summary/getPlottingData/SEMA',
            data: parameters,
            traditional: true,
            success: function (data) {
                processedData = data;
                distributions = processedData.arrays;
                max = processedData.max, min = processedData.min;
                distribution = distributions[0];
                plotData();


                displayStats();

                printData();

            }
        });

    })

</script>



</asp:Content>
