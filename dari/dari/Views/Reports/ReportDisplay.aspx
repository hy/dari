<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	DARI | Montly Report
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>DARI | Montly Report</h2>

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
    position: relative;
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
    <script>

        var formData = eval("( " + '<%= ViewData["parameters"] %>' + ")"); //holds url paramters 
        var seriesNames = formData.series_names; //labels for all the series

        /*This function builds a histogram, unto the histogram panel
         --Paramters---
         data: An array where each element corresponds to a class (ex. "Laptops", "Servers", etc).
                each element is an array of objects, corresponding to bins, with the following members:
	            · x: the minimum value that this bin corresponds to
	            · dx: the bin max minus the bin min
	            · y: the frequency of values in this bin
	            · percent: the frequency divided by the total number of values
        */
        function plotHistogram(data) {

            /*Start bulding plot foundation */
            var dariPlot = new dariPlotter("#hist");
            dariPlot.drawYaxis("Normalized Frequency", data, { coordinate: "percent" });
            dariPlot.drawXaxis("Parameter: " + formData.ParameterName, data);
            dariPlot.drawHorizontalGrids();

            /*Plot the data*/
            data.forEach(function (data_series, i) {

                dariPlot.drawBars(data_series, i, { y: "percent" });
                displayLegend("#hist", data_series, "Histogram", function (d) { return d.x + "," + d.dx + "," + d.y; }, "Lower Limit,Bin Width, Frequency\n", i);

            });


        }

        /*This function builds a propability plot, unto the probPlot panel
        --Paramters---
        data: An array where each element corresponds to a class (ex. "Laptops", "Servers", etc).
                each element is an array of objects, corresponding data points for a graph, each point with the following members
                · x: the x-coordinate for this data point
	            · y: the y-coordinate for this data point
                · idx: the index of this data sample 
         */
        function plotProb(data) {

            /*Start bulding plot foundation */
            var dariPlot = new dariPlotter("#cdf");
            dariPlot.drawYaxis("Probability", data, "y");
            dariPlot.drawXaxis("Parameter: " + formData.ParameterName, data);
            dariPlot.drawHorizontalGrids();

            /*Plot the data*/
            data.forEach(function (d, i) {
                dariPlot.drawLine(d, {}, i);
                displayLegend("#cdf", d, "Probability", function (datum) { return datum.x + "," + datum.y; }, "x,y,\n", i);
            });


        }

        /*This function builds a box plot, unto the box panel
        --Paramters---
        datasets: An array where each element corresponds to a class (ex. "Laptops", "Servers", etc).
        each element is an object, where each member corresponds to a statistic:	
            ·  Percentile_05
	        ·  Percentile_95
	        ·  Percentile_25
	        ·  Percentile_75
	        · Percentile_50
	        · Mean
	        · Median
	        · Max
	        · Count
	        · Min
	        · NodeID: (indicates the class this data represents)
        */
        function boxPlot(datasets) {

                
            /*Start bulding plot foundation */
            var dariPlot = new dariPlotter("#box");
            dariPlot.drawYaxis(null, datasets, { plotType: dariPlot.plotTypes.BOX_PLOT });
            dariPlot.drawHorizontalGrids();

            /*Plot the data*/
            datasets.forEach(function (data, i) {
                dariPlot.drawBoxPlot(data, i);
                displayLegend("#box", datasets, "Stats", function (d) { return d.Min + "," + d.Max + "," + d.Mean; }, "Min,Max,Mean\n", i);
            });

            //also use this data to fill stats table
            displayStats(datasets);


        }

        /*This function displays all the statistics in a table
        --Paramters---
        data: An array where each element corresponds to a class (ex. "Laptops", "Servers", etc).
        each element is an object, where each member corresponds to a statistic (ex. "mean", "max", "95_percentile", etc) */
        function displayStats(data) {

            //Map each member to a row
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

            //Get series names
            for (var i in data) {
                data[i].NodeID = seriesNames[i].split("(")[0];
            }


            //Print table
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

                    if (isHeader)
                        currentRow.append("<th class='color" + i + "'>" + myStats[fields[heading]] + "</th>");
                    else
                        currentRow.append("<td>" + myStats[fields[heading]] + "</td>");
                }

            }


        }

        /*This function displays a legend for a given series in the plot, and also generates the csv data for the respective series
        --Paramters---
        plot_div: a string for the selector of the panel that contains the respective plot
        data: An array where each element corresponds to a class (ex. "Laptops", "Servers", etc).
        each element is an object, where each member corresponds to a statistic (ex. "mean", "max", "95_percentile", etc)
        plotType: a string that says what type of plot this legend is for
        mapping: a function, that maps each datum, to a string representation that will represent a row in the csv file
        csv_headers: the string reprsentation of the first row of the csv file, that will typically be used to label each column
        i: an index of the series of data that is currently being added to the legend
        */
        function displayLegend(plot_div, data, plotType, mapping, csv_headers, i) {

            //generate container for legend if not already generated
            this.containers = this.containers || {};
            this.containers[plot_div] = this.containers[plot_div] || $("<div class='legend_div'></div>").appendTo(plot_div);

            // store raw data for csv file
            var csvRows = data.map(mapping);
            var csvString = csv_headers + csvRows.join("\n");


            //Build link for downloading csv data (only for histograms and probPlot)
            var link = null;
            if (plotType != "Stats")
                link = $("<a></a>").attr("href", "data:text/csv;charset=utf-8," + encodeURI(csvString))
                    .attr("download", seriesNames[i] + " " + plotType + ".csv")
                    .text("(download data)");

            //generate color indicator that also activates color picker control
            var colorBox = $('<div class="legend">Change Color</div>').data('series_idx', i).click(chooseNewColor);

            //append color control, series label, and download link to the legend container
            $('<div></div>').append(colorBox).append(seriesNames[i] + " &nbsp; ").append(link).addClass('color' + i)
                            .appendTo(this.containers[plot_div]);
        }

        /*this function shows the color picker control and appends it to the active color box */
        function chooseNewColor() {
            $(this).addClass("active");
            $('#options').appendTo($(this));
            $('#options').show("slow");
            $('#options').find(".color_option").data('series_idx', $(this).data('series_idx'));
        }

        /*this function builds the color picker control */
        function buildColorPicker() {
            //the availabe colors
            var options = ["red", "blue", "green", "#1db34f", "rgb(244,189,58)", "rgb(75, 180, 236)"]; 

            //build the display of clickable boxes for each color option
            for (var t = 0; t < options.length; t++) {
                var color_option = $('<div class="color_option"></div>');
                color_option.css('background-color', options[t]);
                color_option.appendTo('#options');
            }

            //add handler to change all the respective svg and html elements to the chosen color
            $('.color_option').click(function () {
                var selectedColor = $(this).css('background-color');
                var series_idx = $(this).data('series_idx');

                new dariPlotter().changeColors(series_idx, selectedColor);

                $('#options').hide("slow");
                $(this).parent().parent().removeClass("active");
                event.stopPropagation();
            });

        }

        /*function that calls the json api to get the data for the desired plot 
        --Paramters---
        format: a string that indicates what type of plot to get data for
        callback: the function that process the data once it is retrieved
        */
        function getData(format, callback) {

            //store associative arrays mapping plotting format to containers, and call back functions
            this.containers = { Histogram: "#hist", ProbPlot: "#cdf", BasicStats: "#box" };
            this.callbacks = { Histogram: plotHistogram, ProbPlot: plotProb, BasicStats: boxPlot };

            //display ajax loader animation in the respective tab
            var ajax_loader = $("#ajax_loader").clone().appendTo($(this.containers[format])).show();
            ajax_loader.find("span").text("Plotting");

            var callback = this.callbacks[format];
            formData.format = format; //add format to the parameters for the "getData" request
            $.getDariJson("Reports", "getData", formData, function (data) {
                callback(data);
                ajax_loader.hide('slow');
            });
        }

        //initialize page
        $(function () {
            $("#tabs").tabs(); //display tabs for each plot
            $("li.ui-state-default a").focus(function () { $(this).blur(); }); //so that orange glow doesn't show after tab is clicked

            //retreive the data for each plot
            getData("Histogram");
            getData("ProbPlot");
            getData("BasicStats");

            /*display all the analysis info */
            for (var param in formData) {
                $("#" + param).text(formData[param]);
            }
            var date_stamp = new Date(formData["date"] * 1000);
            $('#date').text(date_stamp.toLocaleDateString());

            //generate color picking control
            buildColorPicker();

        }); // end of initialization

    </script>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">

<div id="plot_content">

    <div id="description">

        <h2>Report Details</h2>
        <p>Analysis: <span id="analysis"></span></p>
        <p>Parameter: <span id="ParameterName"></span></p>
        <p>Classification: <span id="classification_name"></span></p>
        <p>Operating System: <span id="os"></span></p>
        <p>Date: <span id="date"></span></p>

        <h2>Basic Statistics</h2>
        <div id="stats">
                <table width="100%">
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
        </div>
      </div>
      <div id="tabs-4">
        <div id="cdf" class="chart_type"></div>
      </div>
    </div>

    <div id="options"></div>

</div>

</asp:Content>
