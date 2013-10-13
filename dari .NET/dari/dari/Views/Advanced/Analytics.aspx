<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Analytics
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     
    <div id="filtering_div" style="position: relative;">

        <h2> Choose Filters </h2>
        <div class="grey_box">

            Filter by: <select name="filter_name" id="filter_name"><option></option></select>
            For Value: <select name="filter_value" id="filter_value"></select>
            <button id="add_filter_button">Add Filter </button>
            <div id="filters_list"><span> Selected Filters: </span></div>

        </div>

        <h2> Choose Plot Type </h2>
        <div class="grey_box">

            <div id="radio">
                <input type="radio" id="radio1" name="plot_type" value="histogram"/><label for="radio1">Cumulative</label>
                <input type="radio" id="radio2" name="plot_type" value="correlation" /><label for="radio2">Correlation</label>
            </div>

        </div>

        <h2> Choose Variables </h2>
        <div class="grey_box">

            <div class="variable_selectors_div" id="histogram_variable_selectors">
                Histogram Variable: <select name="hist_var" id="hist_var"></select>
            </div>

            <div class="variable_selectors_div" id="correlation_variable_selectors">
                X axis: <select name="x_axis" id="x_axis"></select>
                Y axis: <select name="y_axis" id="y_axis"></select>
            </div>

        </div>
        <button id="plot_button">Plot</button>

       

        <div id="plot_div">

            <a href="javascript:toggleQueryBox()">(View Query Text)</a>
            <div id="query_box" class="grey_box">
                <pre></pre>
            </div>

        </div>
    </div>
 
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">

<style>
    
    #main
    {
        width: 1000px;
    }
    
    select 
    {
        width: 150px;
    }
        
    #plot_div 
    {
        display: none;
    }
        #plot_div .data_point
        {
            fill: rgb(49,182,253);
            opacity: 0.5;
            cursor: pointer;
        }
        
            #plot_div .data_point .datum_info
            {
                display: none;
            }
            
        
    #filtering_div
    {
        padding: 10px;
    }
    

    
    #filters_list {
    padding: 10px;
    margin: 10px 0px;
    border-radius: 5px;
    }

        #filters_list button
        {
            background: White;
            border-color: rgb(49,182,253);
            margin: 2px;
        }

        #filters_list > span
        {
            /*color: White;*/
        }
        
    #plot_button
    {
        width: 100%;
        margin: 30px 0px;
    }
    
    pre
    {
        font-size: 12px;
        white-space: pre-wrap;
    }
    
    
</style>

<script>

    var selected_filters = {}; //associative array that stores name-value pairs of filters that user selects

    /*This function builds a coorolation plot
    --Paramters---
    data: an array of data points objects. Each object contains:		
        ○ x: the x-coordinate
		○ y: the y-cordinate
		○ info: the host index that this data point corresponds to
    */
    function plotCorrelation(data) {

        //reset display
        $('svg').remove();
        $('#download_link').remove();

        /*Start bulding plot foundation */
        var dariPlot = new dariPlotter("#plot_div");
        dariPlot.drawXaxis($("#x_axis").val(), data);
        dariPlot.drawYaxis($("#y_axis").val(), data);
        dariPlot.drawHorizontalGrids();

        //Handler to navigate to the respective host page of data point when clicked
        function navigateToHostPage(d, i) {
            var hostInfo = d.info.split('.');
            window.location.href = $.makeDariUrl("byUser", "HostPage", { hostName: hostInfo[0], lifetimeLabel: hostInfo[1], cpus: 1 });
        }
        //Draw the data points onto the plot.
        // Options are such that it will display the "info" member of each datapoint (on mouseover), and navigate to it's hostpage when clicked
        dariPlot.drawDataPoints(data, { text: "info", onclick: navigateToHostPage});

        loadingImg("hide");
    }

    /*This function builds a coorolation plot
    --Paramters---
    data: an array of values of the given variable for "hist_var"		
    */
    function plotHistogram(data) {

        $('svg').remove();
        $('#download_link').remove();

        /*Start bulding plot foundation */
        var dariPlot = new dariPlotter("#plot_div");

        //prepare histogram data from raw data
        var bucketedData = dariPlot.bucketData(data, 20);
        dariPlot.drawXaxis($("#hist_var").val(), bucketedData);
        dariPlot.drawYaxis("Frequency", bucketedData);
        dariPlot.drawHorizontalGrids();

        //draw the histogram bars onto the plot
        dariPlot.drawBars(bucketedData, 0);

        loadingImg("hide");
    }

    /*This function prepares the parameters by which the database will be queried
        and calls the dari JSON api, to retreive the filtered data */
    function getPlottingData() {
        loadingImg("show", "Generating Plot");

        var plot_type = $("input[name='plot_type']:checked").val();
        var formData = {
            x: $("#x_axis").val(),
            y: $("#y_axis").val(),
            hist_var: $("#hist_var").val(),
            plot_type: plot_type
            };
        formData["filters"] = [];

        for (var filter in selected_filters) {
            formData["filters"].push(filter);
            formData[filter] = selected_filters[filter];
        }

        /* Calling JSON API to get the information for host with the given hostname
            Returns an object with two members:
                · query: the string used to query the database
                · data: the data to plot. It's format depends on  the "plot_type" parameter
                    If plot_type =  "correlation", data is an array of data points objects. Each object contains:
                        ○ x: the x-coordinate
                        ○ y: the y-cordinate
                        ○ info: the host index that this data point corresponds to
                    Otherwise, it data is an array of values of the given variable for "hist_var" 
        */
        getDariJson("Advanced", "getFilteredPlottingData", formData, function (result) {


            var csvContent; //string to store the content of the resulting CSV file

            //plotting the data, and converting the data to csv
            if (plot_type == "histogram") {
                plotHistogram(result.data);
                csvContent = result.data.join("\n");
            } else {
                plotCorrelation(result.data);
                csvContent += ([$('#x_axis').val(), $('#y_axis').val(), "host name"].join(",") + "\n");
                var d;
                for (var i = 0; i < result.data.length; i++) {
                    d = result.data[i];
                    csvContent += ([d.x, d.y, d.info].join(",") + "\n");
                }
            }

            //Preparing link to download csv file
            var encodedUri = encodeURI(csvContent);
            var download_link = $('<a></a>')
                .attr("href", 'data:application/csv;charset=UTF-8,' + encodedUri)
                .attr("download", "my_data.csv")
                .attr("id", "download_link")
                .text("Download Data");
            $("#plot_div").append(download_link);

            //display query text
            $("#query_box pre").text(result.query);

            //display plot
            $("#plot_div").show();
        }); //end of getDariJson call

    }

    //Utility function to populate and prepare the selector input for selecting plotting variables
    function populate_plottingVars(selector) {

        var options = {};
        options[""]="";
        options["AvgC0_PerCore"] = "C0/SO";
        options["AvgP0_PerS0"] =  "P0/S0";
        options["S0_PerDay"] = "S0/Day";

        for (var option in options) {
            $(selector).append("<option value='"+option+"'>" + options[option] + "</option>");
        }

        $(selector).picker(); //style the selector
    }

    //Called after a user chooses a filter, to reflect the change both on the display and programattically
    function addFilter(filter_name, filter_value) {
    
        //get filter values and store in selected_filters
        selected_filters[filter_name] = filter_value;

        //create button for this filter, and add to display. When clicked, this filter will be removed
        var filter_button = $("<button>" + filter_name + "=" + filter_value + '</button>');
        filter_button.data('filter_name', filter_name);
        filter_button.click(removeFilter);
        filter_button.button({
            icons: {
                secondary: "ui-icon-close"
            }
        })
        $("#filters_list").append(filter_button);

        $("#filter_name").find('option:selected').remove(); //remove the option so that it can't be selected again
        $("#filter_value").val(''); //reset the selector
        $("#filter_name").val(''); //reset the selector
    }

    //Called after a user removes a filter, to reflect the change both on the display and programattically
    function removeFilter() {
        var filter_name = $(this).data('filter_name');
        delete selected_filters[filter_name];
        $("#filter_name").append("<option>" + filter_name + "</option>");
        $(this).remove();
    }

    //Handler to hide/show the query box
    function toggleQueryBox() {
        $("#query_box").toggle("slow");
    }

    //change display of paramters options based on which type of plot is desired
    function setVariableSelectors() {
        var selected_plot_type = $("input[name='plot_type']:checked").val();
        $(".variable_selectors_div").hide();
        $("#" + selected_plot_type + "_variable_selectors").show();
    }

    //intialization
    $(function () {
        loadingImg("show", "Preparing Filter Options");

        /* Calling JSON API to get the information for host with the given hostname
        Returns an object with each member, corresponding to a filter.  Each member is the name of the filter, 
        and each value is an array of strings that list the possible options the user can select for that filter.
        {
        · "filterName0": [array of strings of possible options}
        · "filterName1": [array of strings of possible options}
        · ….
        · "filterNameN": [array of strings of possible options}
        }

        */
        $.getDariJson("Advanced", "getFilterOptions", {}, function (data) {
            var filters = data;

            //populate filter selector with filter names
            for (var name in filters) {
                $("#filter_name").append("<option>" + name + "</option>");
                filters[name].push(""); //add blank option to list of filter options
                filters[name].sort(); //sort the list of options alphabetically
            }

            //When a filter name is selected, populate the filter options selector with its respective options
            $("#filter_name").change(function () {
                var options = filters[$(this).find('option:selected').text()];
                $("#filter_value").empty();
                for (var i = 0; i < options.length; i++) {
                    $("#filter_value").append("<option>" + options[i] + "</option>");
                }
            });

            //style the selectors
            $("#filter_name").picker();
            $("#filter_value").picker();

            //Add handler to button to add filters
            $("#add_filter_button").click(function () {
                var filter_name = $("#filter_name").find('option:selected').text();
                var filter_value = $("#filter_value").find('option:selected').text();
                addFilter(filter_name, filter_value);
            });

            //if this a pre-saved plot, go ahead and pre-select the filters based on the url parameters, and then plot
            var url_params = eval("(" + '<%= ViewData["parameters"] %>' + ")");
            if (url_params) {
                url_params.filters.forEach(function (filter_name) {
                    $("#filter_name").val(filter_name);
                    $("#filter_value").val(url_params[filter_name]);
                    addFilter(filter_name, url_params[filter_name]);
                });
                $('#x_axis').val(url_params['x']);
                $('#y_axis').val(url_params['y']);
                $('#hist_var').val(url_params['hist_var']);
                //$("input[value='" + url_params['plot_type'] + "']").attr('checked', true);
                var selected_plotType = $("input[value='" + url_params['plot_type'] + "']").attr('id');
                $("label[for='" + selected_plotType + "']").click();

                //programatically initiate plotting
                $("#plot_button").click();

            } else {

                loadingImg("hide");
            }


        }); //end of getDariJson call

        //Populate the selectors for the plotting variables
        populate_plottingVars("#x_axis");
        populate_plottingVars("#y_axis");
        populate_plottingVars("#hist_var");

        //add handler to plotting button
        $("#plot_button").click(getPlottingData);

        //hanndle plot-type changes
        $("#radio").buttonset(); //style the radio button for plot-type
        $("input[name='plot_type']").change(setVariableSelectors); // when changed, change the selectors displayed
        setVariableSelectors(); //set initial set of variable selectors displayed

        //set intital query box state to closed
        $("#query_box").toggle();
    });

</script>


</asp:Content>

