<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<dynamic>" %>
<%
    
    var hostName = ViewData["host"];
 %>

<!DOCTYPE html>
<meta charset="utf-8">
<style>

body {
  font: 10px sans-serif;
}

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.x.axis path {
  display: none;
}

.line {
  fill: none;
  stroke: steelblue;
  stroke-width: 1.5px;
}

.other 
{
    stroke: purple;
}

.series1 
{
    stroke: purple;
}
.series2
{
    stroke: green;
}

#loading_gif
{
    position: fixed;
top:500px;
left:300px;
display: none;
}

text.datum_info 
{
    /*visibility: hidden;*/
    display: none;
}

.ajax 
{
    display: none;
}

</style>
<script src="http://d3js.org/d3.v3.js"></script>
<script src="//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.9.1.min.js"></script>


    <link rel="stylesheet" type="text/css" href="/public/dataset_colors.css">
    <link href='http://fonts.googleapis.com/css?family=Days+One' rel='stylesheet' type='text/css'>

<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  <script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  <%--<link rel="stylesheet" href="/resources/demos/style.css" />--%>



<script>


    var selectedHost = ""; 
    var margin = { top: 20, right: 20, bottom: 30, left: 50 },
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

    var parseDate = d3.time.format("%d-%b-%y").parse;

    var x = d3.time.scale()
    .range([0, width]);

    var y = d3.scale.linear()
    .range([height, 0]);

    var xAxis = d3.svg.axis()
    .scale(x)
    .tickFormat(d3.time.format("%d-%b-%y"))
    .orient("bottom");

    var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

    var line = d3.svg.line()
    .x(function (d) {
        return x(d.date);
    })
    .y(function (d) {
        return y(d.close);
    });

    var color = ["", "steelblue", "#90CA77", "#E9B64D"];

    function plotTemp() {
        $('#loading_gif').show();

        var startDate = ($("#startDatePicker").datepicker("getDate")).valueOf()/1000;
        var endDate = ($("#endDatePicker").datepicker("getDate")).valueOf() / 1000;

        var checkedCPUs = [];
        $("input:checked").each(function (idx, el) {
            checkedCPUs.push(el.value);
        });

        $.ajax({

            url: '/Plot/lineData',
            data: { host: selectedHost, cpus: checkedCPUs, start: startDate, end: endDate },
            type: 'GET',
            dataType: 'json',
            traditional: true,
            success: function (data) {

                byCpu = {};

                checkedCPUs.forEach(function (cpuNum) {
                    byCpu[cpuNum] = [];
                });

                data.forEach(function (d) {
                    d.date = new Date(d.timestamp * 1000);
                    d.close = d.value;

                    byCpu[d.cpu].push(d);

                });


                $('svg').remove();


                var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

                x.domain(d3.extent(data, function (d) { return d.date; }));
                y.domain(d3.extent(data, function (d) { return d.close; }));

                svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

                svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Temperature Restiger Value");



                checkedCPUs.forEach(function (cpuNum, idx) {
                    svg.append("path")
                          .datum(byCpu[cpuNum])
                          .attr("class", "line series" + idx)
                          .attr("d", line);

                });




                svg.selectAll(".data_point")
                      .data(data)
                    .enter().append("g")
                      .attr("class", "data_point");

                svg.selectAll(".data_point")
                .data(data)
                .append("circle")
                .attr("class", "dot")
                .attr("r", 3.5)
                .attr("cx", function (d) { return x(d.date); })
                .attr("cy", function (d) { return y(d.close); })
                .style("fill", function (d) { return color[d.cpu]; });

                svg.selectAll(".data_point")
                .data(data).append("text")
                      .attr("class", "datum_info")
                      .text(function (d) { return d.date.toTimeString() })
                      .attr("x", function (d) { return x(d.date) + 5; })
                      .attr("y", function (d) { return y(d.close); })
                      .style("fill", "black");

                $('.dot').mouseover(
                    function () {
                        $(this).siblings('text').show();
                    });

                $('.dot').mouseout(
                    function () {
                        $(this).siblings('text').hide();
                    });


                $('svg').get(0).addEventListener("mousewheel", function (e) {

                    //var delta = Math.max(-1, Math.min(1, (e.wheelDelta || -e.detail)));

                    var range = endDate - startDate;
                    if (e.wheelDelta > 0) {
                        var newStart = (startDate + range / 4) * 1000;
                        var newEnd = (endDate - range / 4) * 1000;
                    } else {
                        var newStart = (startDate - range / 2) * 1000;
                        var newEnd = (endDate + range / 2) * 1000;
                    }
                    $("#startDatePicker").datepicker("setDate", new Date(newStart));
                    $("#endDatePicker").datepicker("setDate", new Date(newEnd));

                    plotTemp();
                    return false;
                }, false);

                $('#loading_gif').hide();
            }
        });


    }

    function getHosts(searchKey) {
        if (searchKey.length < 1)
            return;
        $.getJSON('/Plot/getHostNames', { searchKey: searchKey }, function (data) {
            $('#hostSelector').empty();
            data.forEach(function (hostName) {
                $('#hostSelector').append('<option>'+hostName+'</option>');
            }
            );
        });
    }


    function getInfo(hostname) {

        $.getJSON('/Plot/getHostLifeInfo', { host: hostname }, function (data) {
            $('#lifetime_info').empty();
            $('#lifetime_info').append('<h2> Information for ' + hostname + '</h2>');
            data.forEach(function (lifetime, idx) {
                var Birthtime = new Date(lifetime.Birthtime * 1000);
                var Deathtime = new Date(lifetime.Deathtime * 1000);


                $('#lifetime_info').append('<strong>LifeTime #' + (idx + 1) + ':</strong> &nbsp' + Birthtime.toDateString() + ' to ' + Deathtime.toDateString() + ' <button>Use These Dates</button> <br>');

                var button = $('#lifetime_info button').last();

                button.data('Birthtime', lifetime.Birthtime * 1000);
                button.data('Deathtime', lifetime.Deathtime * 1000);
                button.data('Cpus', lifetime.cpus);

                button.click(function () {
                    var birth = $(this).data('Birthtime');
                    var death = $(this).data('Deathtime');
                    var Cpus = $(this).data('Cpus');
                    Cpus = (Cpus > 32) ? 32 : Cpus;

                    $("#startDatePicker").datepicker("setDate", new Date(birth));
                    $("#endDatePicker").datepicker("setDate", new Date(death));

                    $('#select_cpus').empty();

                    for (var i = 1; i <= Cpus; i++) {
                        $('#select_cpus').append(i + '<input type="checkbox" name="cpu" value="' + i + '"> &nbsp &nbsp');
                    }

                    $('#plot_params').show();
                });

            });

        });
    }


    function plotStats() {
        var startDate = ($("#startDatePicker").datepicker("getDate")).valueOf() / 1000;
        var endDate = ($("#endDatePicker").datepicker("getDate")).valueOf() / 1000;
        window.location = "/Plot/ThermStats/1?host=" + selectedHost + "&start=" + startDate + "&end=" + endDate;
    };


    $(document).ready(function () {

        //just added 8/18/2013
        selectedHost = "<%= ViewData["host"] %>";
        if (selectedHost.length>0)
            getInfo(selectedHost)

        $("#startDatePicker").datepicker();
        $("#endDatePicker").datepicker();
        $('#hostSelector').change(getInfo);


        $("#hostSearch").autocomplete({
            source: function (request, response) {

                $('#small_loader').show();

                $.getJSON('/Plot/getHostNames', { searchKey: request.term }, function (data) {
                    response(data);
                    $('#small_loader').hide();
                });
            },
            select: function (event, ui) {
                selectedHost = ui.item.value
                getInfo(selectedHost);
            }
        });


    });

</script>



<body>
    Search for hosts: <input id="hostSearch" type="text" /> <img id="small_loader" class="ajax" src="/public/images/small_ajax.gif"/> <br />
    <%--<select id="hostSelector" style = "display: none;">
    </select>--%>

    <div id="lifetime_info"></div>

    <div id="plot_params" style="display: none">
    From: <input id="startDatePicker"/> To: <input id="endDatePicker"/>
    <br /><br />
    Select Cpus: 
    <div id="select_cpus"></div>
    <button onclick="plotTemp()">Plot</button>
    <button onclick="plotStats()">Plot Stats</button>


    <img id="loading_gif" src="/public/images/ajax-loader.gif"/>
    </div>



<%--    <h1>Temperature of Core over the Past Week</h1>
    <h2>host name: <%= hostName%></h2>
    <h2 style="color: steelblue">cpu: 1</h2>
    <h2 style="color: purple">cpu: 2</h2>--%>
</body>