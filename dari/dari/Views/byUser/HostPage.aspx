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
    var lifeTimes = {}; //associative array mapping lifetime birth times to an object with {index and deathtime}
    var selectedLifeTime; //the selected lifetime (identified by the birthtime)

    /*This function calls the JSON api to get info for the given host */
    function getInfo(hostname, callback) {

        /*Calling JSON API to get the information for host with the given hostname
        Returns data to call back function, as an array of objects, corresponding to Lifetimes
        Each lifetime object, contains 
	        · Birthtime- a time stamp for the beginning of the lifetime
	        · Deathtime: - a time stamp for the beginning of the lifetime
	        · HostIndex- the identifier for the host in the system
	        · HostPlatform- the platform of the host
	        · NumCores- number of cores
	        · NumLogical- number of logical cores
	        · NumPhysical- number of sockets
	        · PrimaryHostIndex- primary identifier
	        · TotalMemory- total memory
	        · Cpus[]- An array of objects corresponding to logical cpus:
			        · BrandString
			        · CPUNum: 1
			        · CoreID: 0
			        · PhysID: 0
			        · ProductFamily:
            · timeIntervalLabel- a string that puts the birthtime to death time range in readable format ex."December 18, 2012- March 31, 2013"
        */
        $.getDariJson("byUser","getHostInfo", { hostname: hostname }, function (data) {

            //write header
            $('#lifetime_info').empty();
            $('#lifetime_info').append('<h2> Information for ' + hostname + ' </h2>');

            //process each lifetime
            data.forEach(function (lifetime, idx) {

                //store lifetime information
                lifeTimes[lifetime.Birthtime] = {index: idx, death: lifetime.Deathtime};
                
                //add a panel of information for each lifetime
                $('#panels').append("<h1>"+lifetime.timeIntervalLabel+"<span class='details'></span></h1>");
                $('#panels').append("<div>"+lifetime.HostPlatform+" platform<div>");
                $('#panels div').last().append("<ul></ul>");
                $('#panels ul').last().append("<li>"+lifetime.TotalMemory+" bytes of memory</li>");
                $('#panels ul').last().append("<li>"+lifetime.NumPhysical+" physical sockets/packages</li>");
                $('#panels ul').last().append("<li>"+lifetime.NumCores+" cores</li>");
                $('#panels ul').last().append("<li>"+lifetime.NumLogical+" logical cores: <span class='instructions'>Select desired cores and parameter to plot</span></li>");


                //print table with row for each cpu
                var cpuInfo;
                var cpuCount = (lifetime.cpus)? lifetime.cpus.length : 0;

                var tableHTML = '<table><thead><tr><th>ID</th><th>Brand</th><th>Product Family</th><th>on Core</th><th> in Soc.</th><th>Select</th></tr></thead><tbody>';
                for (var i = 0; i<cpuCount; i++){
                    cpuInfo = lifetime.cpus[i];
                    tableHTML += ('<tr><td>'+cpuInfo.CPUNum+'</td><td>'+cpuInfo.BrandString+'</td><td>'
                                    +cpuInfo.ProductFamily+'</td><td>'+cpuInfo.CoreID+'</td><td>'
                                    +cpuInfo.PhysID+'</td><td><input type="checkbox" name="cpu" value="'+cpuInfo.CPUNum+'"></td></tr>');
                }
                tableHTML += '</tbody></table>';
                $('#panels div').last().append(tableHTML);

                //add buttons and controls to choose this lifetime
                $('#panels div').last().append("<br /><div class='styled-select'><select><option>Select Parameter</option><option>Temperature MSR</option></select></div><button onclick='plotLifetime("+lifetime.Birthtime+","+lifetime.Deathtime+","+idx+")'>Plot Selected Cores</button/>");
            });

            //style the panel display
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

    // Close panels and display plot
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

    /*This function calls the dari JSON api to get the data to plot 
    --Parameters--
    save: (optional) a boolean that indicates whether or not a plot query string will be saved for this plot
    */
    function plotTemp(save) {
        loadingImg("show","Generating Plot");

        save = save || false; //default value of save is FALSE. (Any plots from zooming in and out, should not be saved)

        //Get the start and end times for this plot
        var startDate = ($("#startDatePicker").datepicker("getDate")).valueOf()/1000;
        var endDate = ($("#endDatePicker").datepicker("getDate")).valueOf() / 1000;

        //Process which CPUs will be plotted
        var checkedCPUs = [];
        $('#panels tbody').eq(selectedLifeTime).find("input:checked").each(function (idx, el) {
                checkedCPUs.push(el.value);
            });
        $('#panels h1').eq(selectedLifeTime).find('.details').text(" (Temperature for cores "+checkedCPUs.join(", ")+")");


        /*Calling JSON API to get the data to plot. Returns the relevant data points (time vs variable) to plot a time series
        Returns data to call back function, as an array of objects that correspond to a data point. Each object contains:
	        · timestamp: The time stamp for this measurement
	        · value: The value of this measurement
	        · cpu: The cpu on which this measurement was taken

        */
        $.getDariJson("byUser","getHostData", { hostName: '<%= ViewData["hostName"] %>', cpus: checkedCPUs, start: startDate, end: endDate, lifetimeIdx: selectedLifeTime, save: save, os: '<%= ViewData["os"] %>' },
            function (data) {

                //CPU bookkeeping
                var byCpu = {}; //stores an array for each cpu
                checkedCPUs.forEach(function (cpuNum, idx) {
                    byCpu[cpuNum] = [];
                });

                //Group the datapoints into arrays by cpuNum
                data.forEach(function (d) {
                    d.date = new Date(d.timestamp * 1000);
                    d.close = d.value;
                    d.dateString = d.date.toTimeString();

                    byCpu[d.cpu].push(d);
                });

                /*Start bulding plot foundation */
                $('svg').remove();
                var dariPlot = new dariPlotter("#plotCanvas div");
                dariPlot.drawYaxis("Temperature Register Value", data, { coordinate: "close" });
                dariPlot.drawXaxis("Date", data, {coordinate: "date", plotType: dariPlot.plotTypes.TIME_SERIES});
                dariPlot.drawHorizontalGrids();

                //Plot each data series for each cpu 
                checkedCPUs.forEach(function (cpuNum, idx) {
                    dariPlot.drawLine(byCpu[cpuNum], {x: "date", y: "close", class: "line"}, idx);
                    dariPlot.drawDataPoints(byCpu[cpuNum], {x: "date", y: "close", text: "dateString"}, idx);
                });

                //implementing ability to zoom in and out of plot
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


    //intialization
    $(function () {
    
        //Activate date picking ui
        $("#startDatePicker").datepicker();
        $("#endDatePicker").datepicker();

        //Get host name from url parameter and process
        selectedHost = '<%= ViewData["hostName"] %>';
        if (selectedHost.length > 0) {
            //get and display info for given host, and then see if there is any more information in the url parameters, to proceed with plotting 
            getInfo(selectedHost, function (){

                //extract info from url parameters
                var lifetimeIdx = '<%= ViewData["lifetimeIdx"] %>';
                var lifetimeLabel = '<%= ViewData["lifetimeLabel"] %>';
                var start = '<%= ViewData["start"] %>';
                var end = '<%= ViewData["end"] %>';

                //if there is a selected lifetime in the parameters, deduct info about that lifetime
                if(lifeTimes[lifetimeLabel]){
                    lifetimeIdx = lifeTimes[lifetimeLabel].index.toString();
                    start = lifetimeLabel;
                    end = lifeTimes[lifetimeLabel].death;
                }

                //Proceed with selected lifetime
                if (lifetimeIdx.length > 0) {

                    //Check the respective cpu check boxes
                    <% var serializer = new System.Web.Script.Serialization.JavaScriptSerializer(); %>
                    <%= serializer.Serialize((string[]) ViewData["cpus"]) %>.forEach(function(cpuNum){
                        $('#panels tbody').eq(lifetimeIdx).find("input[value='"+cpuNum+"']").attr("checked",true);
                    });

                    //close panels and plot
                    $('#panels h1').eq(lifetimeIdx).click();
                    plotLifetime(start, end, lifetimeIdx);
                }

            });//end of getInfo call
        } //end of '(selectedHost.length > 0)'

    }); // end of intialization
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
