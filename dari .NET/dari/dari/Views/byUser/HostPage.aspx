<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	DARI | Host: <%= ViewData["hostName"] %>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

            <span style="font-size: 20px;">host name: <span id="hostname"><%= ViewData["hostName"] %></span></span><br /><br />
        <span class="instructions">Click dates for more details on each instance of this host</span>
        <div id="panels"></div>

         <div id="plotCanvas">
         <div><svg></svg></div>
         <p class="instructions">Zoom in or out of plot with mouse, or manually change dates and click replot.</p>
         
            From: <div class="styled-select"><input id="startDatePicker"/></div> To: <div class="styled-select"><input id="endDatePicker"/></div>

            <button onclick="plotTemp()">Replot</button>
         
        </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">

<script>
    var lifeTimes = {};
    var selectedLifeTime;

 function getInfo(hostname, callback) {

        $.getDariJson("byUser","getHostInfo", { hostname: hostname }, function (data) {
            $('#lifetime_info').empty();
            $('#lifetime_info').append('<h2> Information for ' + hostname + ' </h2>');
            data.forEach(function (lifetime, idx) {
                var Birthtime = new Date(lifetime.Birthtime * 1000);
                var Deathtime = new Date(lifetime.Deathtime * 1000);

                lifeTimes[lifetime.Birthtime] = {index: idx, death: lifetime.Deathtime};
                
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

    function plotLifetime(birth, death, idx){
        selectedLifeTime = idx;


         $('#panels h1 span').text('');
         $('#panels h1').css('background-color','');

        $("#startDatePicker").datepicker("setDate", new Date(birth*1000));
        $("#endDatePicker").datepicker("setDate", new Date(death*1000));

        $('#panels h1').eq(idx).click();
        $('#panels h1').eq(idx).css('background-color','rgb(165,208,40)');

        $('#plotCanvas').show();
        plotTemp(true);
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


    function plotTemp(save) {
        loadingImg("show","Generating Plot");
        save = save || false;

        var checkedCPUs = [];

        $('#panels tbody').eq(selectedLifeTime).find("input:checked").each(function (idx, el) {
                checkedCPUs.push(el.value);
            });

        $('#panels h1').eq(selectedLifeTime).find('.details').text(" (Temperature for cores "+checkedCPUs.join(", ")+")");


        var startDate = ($("#startDatePicker").datepicker("getDate")).valueOf()/1000;
        var endDate = ($("#endDatePicker").datepicker("getDate")).valueOf() / 1000;


        $.getDariJson("byUser","getHostData", { hostName: '<%= ViewData["hostName"] %>', cpus: checkedCPUs, start: startDate, end: endDate, lifetimeIdx: selectedLifeTime, save: save, os: '<%= ViewData["os"] %>' },
            function (data) {

                byCpu = {};
                var cpuIndex = {};

                checkedCPUs.forEach(function (cpuNum, c) {
                    byCpu[cpuNum] = [];
                    cpuIndex[cpuNum]=c;
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
                          .attr("class", "line color" + idx)
                          .attr("d", line);

                });




                svg.selectAll(".data_point")
                      .data(data)
                    .enter().append("g")
                      .attr("class", "data_point");

                svg.selectAll(".data_point")
                .data(data)
                .append("circle")
                .attr("class", function (d) { return "dot color" + cpuIndex[d.cpu]; })
                .attr("r", 3.5)
                .attr("cx", function (d) { return x(d.date); })
                .attr("cy", function (d) { return y(d.close); })
                ;

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

                loadingImg("hide");
            }
        );


    }





    $(document).ready(function () {
    
        $("#startDatePicker").datepicker();
        $("#endDatePicker").datepicker();

        selectedHost = '<%= ViewData["hostName"] %>';
        if (selectedHost.length > 0) {
            getInfo(selectedHost, function (){

            var lifetimeIdx = '<%= ViewData["lifetimeIdx"] %>';
            var lifetimeLabel = '<%= ViewData["lifetimeLabel"] %>';
            var start = '<%= ViewData["start"] %>';
            var end = '<%= ViewData["end"] %>';

            if(lifeTimes[lifetimeLabel]){
                lifetimeIdx = lifeTimes[lifetimeLabel].index.toString();
                start = lifetimeLabel;
                end = lifeTimes[lifetimeLabel].death;
            }


            if (lifetimeIdx.length > 0) {

                <% var serializer = new System.Web.Script.Serialization.JavaScriptSerializer(); %>
                <%= serializer.Serialize((string[]) ViewData["cpus"]) %>.forEach(function(cpuNum){
                    $('#panels tbody').eq(lifetimeIdx).find("input[value='"+cpuNum+"']").attr("checked",true);
                });

                $('#panels h1').eq(lifetimeIdx).click();
                plotLifetime(start, end, lifetimeIdx);
            }
            });
        }

    });
</script>

<style>
    table 
    {
        color: Black;
        width: 100%;
    }
    
    #main 
    {
         width: 900px;
    }
    
    #mainContent
    {
        margin: 30px 0px;
    }
</style>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">
</asp:Content>
