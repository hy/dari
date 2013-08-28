<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<dynamic>" %>

<head>
<script src="http://d3js.org/d3.v3.js"></script>
<script src="//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.9.1.min.js"></script>

    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  <script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
<script>
    var checkedCPUs = [];

 function getInfo(hostname, callback) {

        $.getJSON('/byUser/getHostInfo', { source: 'SEMA', hostname: hostname }, function (data) {
            $('#lifetime_info').empty();
            $('#lifetime_info').append('<h2> Information for ' + hostname + ' </h2>');
            data.forEach(function (lifetime, idx) {
                var Birthtime = new Date(lifetime.Birthtime * 1000);
                var Deathtime = new Date(lifetime.Deathtime * 1000);

                
                $('#panels').append("<h1>"+lifetime.timeIntervalLabel+"<span class='details'></span></h1>");
                $('#panels').append("<div>"+lifetime.HostPlatform+" platform<div>");
                $('#panels div').last().append("<ul></ul>");
                $('#panels ul').last().append("<li>"+lifetime.TotalMemory+" bytes of memory</li>");
                $('#panels ul').last().append("<li>"+lifetime.NumPhysical+" physical sockets/packages</li>");
                $('#panels ul').last().append("<li>"+lifetime.NumCores+" cores</li>");
                $('#panels ul').last().append("<li>"+lifetime.NumLogical+" logical cores: <span class='instructions'>Select desired cores and parameter to plot</span></li>");

                var tableHTML = '<table><thead><tr><th>ID</th><th>Brand</th><th>Product Family</th><th>on Core</th><th> in Soc.</th><th>Select</th></tr></thead><tbody>';
                
                var cpuInfo;
                var cpuCount = (lifetime.cpus)? lifetime.cpus.length : 0;
                for (var i = 0; i<cpuCount; i++){
                    cpuInfo = lifetime.cpus[i];
                    tableHTML += ('<tr><td>'+cpuInfo.CPUNum+'</td><td>'+cpuInfo.BrandString+'</td><td>'
                                    +cpuInfo.ProductFamily+'</td><td>'+cpuInfo.CoreID+'</td><td>'
                                    +cpuInfo.PhysID+'</td><td><input type="checkbox" name="cpu" value="'+cpuInfo.CPUNum+'"></td></tr>');
                }
                tableHTML += '</tbody></table>';

                $('#panels div').last().append(tableHTML);
                $('#panels div').last().append("<br /><div class='styled-select'><select><option>Select Parameter</option><option>Temperature MSR</option><option>CPU Utilization</option></select></div><button onclick='plotLifetime("+lifetime.Birthtime+","+lifetime.Deathtime+","+idx+")'>Plot Selected Cores</button/>");
            });

            $('#panels').accordion({
                heightStyle: "content",
                collapsible: true,
                activate: function( event, ui ) {
                    
                    //ui.oldPanel.find('input:checkbox').removeAttr('checked');
                },
                create: callback
            });

        });
    }

    function plotLifetime(birth, death, idx, init){
        var cpuString = "";
        var seriesVariable ="";
        if(!init){
            checkedCPUs = [];

        
            $('#panels tbody').eq(idx).find("input:checked").each(function (idx, el) {
                    checkedCPUs.push(el.value);
                    cpuString += (el.value + ", ");
                });
         }

         $('#panels h1 span').text('');
         $('#panels h1').css('background-color','');

        $("#startDatePicker").datepicker("setDate", new Date(birth*1000));
        $("#endDatePicker").datepicker("setDate", new Date(death*1000));

        $('#panels h1').eq(idx).click();
        $('#panels h1').eq(idx).css('background-color','rgb(165,208,40)');

        //seriesVariable = $("#panels select:eq("+idx+") option:selected").text();
        $('#panels h1').eq(idx).find('.details').text(" (Temperature for cores "+cpuString.slice(0,cpuString.length-2)+")");
        $('#plotCanvas').show();
        plotTemp(idx);
    }
    

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

    function plotTemp(lifetimeIdx) {
        $('#loading_gif').show();

        var startDate = ($("#startDatePicker").datepicker("getDate")).valueOf()/1000;
        var endDate = ($("#endDatePicker").datepicker("getDate")).valueOf() / 1000;



        $.ajax({

            url: '/Plot/lineData',
            data: { hostName: '<%= ViewData["hostName"] %>', cpus: checkedCPUs, start: startDate, end: endDate, lifetimeIdx: lifetimeIdx },
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


                var svg = d3.select("#plotCanvas div").append("svg")
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





    $(document).ready(function () {
    
        $("#startDatePicker").datepicker();
        $("#endDatePicker").datepicker();

        selectedHost = '<%= ViewData["hostName"] %>';
        if (selectedHost.length > 0) {
            getInfo(selectedHost, function (){

            var lifetimeIdx = '<%= ViewData["lifetimeIdx"] %>';
            var start = '<%= ViewData["start"] %>';
            var end = '<%= ViewData["end"] %>';
            <% var serializer = new System.Web.Script.Serialization.JavaScriptSerializer(); %>
            checkedCPUs = <%= serializer.Serialize((string[]) ViewData["cpus"]) %>; 

            if (lifetimeIdx.length > 0) {
                $('#panels h1').eq(lifetimeIdx).click();
                plotLifetime(start, end, lifetimeIdx, true);
            }
            });
        }

    });
</script>

<style>
    
    body 
    {
        background: rgb(49,182,253);
        margin: 0px;
        font-family: Calibri;
    }
    
    #main 
    {
        background: White;
        color: Black;
        width: 800px;
        margin: auto;
                  -moz-box-shadow:    1px 1px 10px 1px #0F0A0A;
  -webkit-box-shadow: 1px 1px 10px 1px #0F0A0A;
  box-shadow:         1px 1px 10px 1px #0F0A0A;
        position: relative;

    }
    
    #main > div 
    {
        padding: 20px 10%;
    }

    #panels 
    {
        margin-bottom: 30px;
    }

    #header 
    {
        background: rgb(69,132,211);
        color: White;
        padding: 20px;
    }
    
    .instructions
    {
        font-style: italic;
        display: block;
    }
    
    .ajax 
        {
            display: none;
        }

       #goToPlotButton
       {
           background: rgb(49,182,253);
            display: block;
            padding: 30px 0px;
            text-align: center;
            margin: 20px 5%;
            position: absolute;
            bottom: 0px;
            width: 90%;
            color: white;
            font-size: 30px;
            text-decoration: none;
            box-shadow: 1px 1px 5px 0px #0F0A0A;
            border-radius: 5px;
            display: none;
       }
       
       .ui-accordion
       {            
           /* width: 80%;
            margin: 10px 10%; */
       }
       
            .ui-accordion .ui-accordion-header 
            {
            margin-top: 10px;
            }
       
           .ui-accordion-header
           {
            background: rgb(49,182,253);
            color: White;
            border: rgb(69,132,211) 2px solid;
            margin-top: 10px;
            text-align: center;
           }
            .ui-accordion-content
           {
            background: rgb(49,182,253);
            color: White;
            border: rgb(69,132,211) 2px solid;
            border-top: 0px;
           }     
           .ui-accordion .ui-accordion-header .ui-accordion-header-icon 
           {
               background: none;
           } 

    #hostname
    {
        color: rgb(49,182,253);
        font-size: 35px;
    }

    #panels > div
    {
        font-size: 14px;
    }
        #panels li {
            list-style-type: disk;
        }


        table
{
border-collapse:collapse;
            font-size: 12px;
}
table,th, td
{
border: 2px solid White;
}

td {
padding: 5px 10px;
text-overflow: ellipsis;
white-space: nowrap;
}
thead 
{
    background: rgb(245,192,62);
    color: White;
    }
tbody tr:nth-child(even) {background: rgb(251,232,205)}
tbody tr:nth-child(odd) {background: rgb(253,244,232)}


    .styled-select {
       width: 200px;
        height: 34px;
        overflow: hidden;
        background: url(/public/down_arrow_brown.jpg) no-repeat right rgb(255,255,153);
        border: 2px solid rgb(244,189,58);
        border-radius: 5px;
        display: inline-block;
        color: rgb(244,189,58);
        box-shadow: 1px 1px 5px 0px #0F0A0A;
        margin-right: 20px;
       }
   
       .styled-select select, .styled-select input {
       background: transparent;
       width: 268px;
       padding: 5px;
       font-size: 16px;
       line-height: 1;
       border: 0;
       border-radius: 0;
       height: 34px;
       -webkit-appearance: none;
       color: rgb(147,106,8);
       }

       #panels .styled-select {
        border: 2px White solid;
        box-shadow: none;
       }
       
       button {
       width: 240px;
        height: 37px;
        overflow: hidden;
        background: rgb(165,208,40);
        border: 2px solid rgb(120,152,26);
        border-radius: 5px;
        display: inline-block;
        color: White;
        margin-left: 30px;
       }



    /*svg styling */
    #plotCanvas {
        display: none;
        }
        
        #plotCanvas svg{
            font: 10px sans-serif;
            }
            
        #plotCanvas button 
        {
            width: 100px;
        box-shadow: 1px 1px 5px 0px #0F0A0A;
        margin-left: 0px;
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


</style>

</head>

<body>

<div id="main">
    <div>
        <span style="font-size: 20px;">host name: <span id="hostname"><%= ViewData["hostName"] %></span></span><br /><br />
        <span class="instructions">Click dates for more details on each instance of this host</span>
        <div id="panels"></div>

         <img id="loading_gif" class="ajax" src="/public/images/ajax-loader.gif"/>

         <div id="plotCanvas">
         <div><svg></svg></div>
         <p class="instructions">Zoom in or out of plot with mouse, or manually change dates and click replot.</p>
         
            From: <div class="styled-select"><input id="startDatePicker"/></div> To: <div class="styled-select"><input id="endDatePicker"/></div>

            <button onclick="plotTemp()">Replot</button>
         
        </div>
    </div>
</div>

</body>