<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Advanced Analysis
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
        box-shadow: none;
        -webkit-box-shadow: none;
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
/* background-color: rgb(49,182,253); */
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
margin: 10px;
    }
    
    pre
    {
        font-size: 12px;
white-space: pre-wrap;
        }
    
    
    
    /*overriding default graphing styles*/
    
    line.moving, path.line
    {
        stroke: none;
    }
    
    path.shaded 
    {
        fill: none;
    }
    
    .fill_color0
    {
        fill: rgb(49,182,253);
    }
    
</style>

<script src="../../public/histogram-chart2.js"></script>
<script>

    var filters;
    var selected_filters = {};

    var selectedHost = "";
    var margin = { top: 20, right: 20, bottom: 30, left: 50 },
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

    var parseDate = d3.time.format("%d-%b-%y").parse;

    var x = d3.scale.linear()
    .range([0, width]);

    var y = d3.scale.linear()
    .range([height, 0]);

    var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

    var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

    var color = ["", "steelblue", "#90CA77", "#E9B64D"];

    function plotCorrelation(data) {

        $('svg').remove();

        var svg = d3.select("#plot_div").append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        x.domain(d3.extent(data, function (d) { return d.x; }));
        y.domain(d3.extent(data, function (d) { return d.y; }));

        svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis)
            .append("text")
            .attr("y", -20)
            .attr("x", width / 3)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(x_axis);

        svg.append("g")
            .attr("class", "y axis")
            .call(yAxis)
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(y_axis);


        svg.selectAll(".data_point")
                .data(data)
            .enter().append("g")
                .attr("class", "data_point");

        svg.selectAll(".data_point")
        .data(data)
        .append("circle")
        .attr("class", "dot")
        .attr("r", 3.5)
        .attr("cx", function (d) { return x(d.x); })
        .attr("cy", function (d) { return y(d.y); })
        .style("fill", function (d) { return color[d.cpu]; });

        svg.selectAll(".data_point")
        .data(data).append("text")
                .attr("class", "datum_info")
                .text(function (d) { return d.info })
                .attr("x", function (d) { return x(d.x) + 5; })
                .attr("y", function (d) { return y(d.y); })
                .style("fill", "black");

        $('.dot').mouseover(
            function () {
                $(this).siblings('text').show();
            });

        $('.dot').mouseout(
            function () {
                $(this).siblings('text').hide();
            });

        $('.dot').click(
            function () {
                var hostInfo = $(this).siblings('text').text().split('.');
                window.location.href = "/byUser/HostPage/?hostName=" + hostInfo[0] + "&lifetimeLabel=" + hostInfo[1]+"&cpus=1";
            });

        loadingImg("hide");
    }

    function plotHistogram(data) {

        $('svg').remove();

        var svg = d3.select("#plot_div").append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var distributions = [data];
        var series_names = ["variable"];
        var numOfTicks = 100;
        var min = d3.min(data);
        var max = d3.max(data);



        d3.select("#plot_div svg")
    .datum(distributions)
    .call(histogramChart(numOfTicks, "hist", series_names)
    .bins(
    d3.scale.linear()
            .domain([min, max])
            .ticks(numOfTicks)
            )
    .tickFormat(d3.format(".0f")));

        loadingImg("hide");
    }

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


        getDariJson("Advanced", "getCoorelationData", formData, function (result) {


            var csvContent;


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

            var encodedUri = encodeURI(csvContent);
            var download_link = $('<a></a>')
                .attr("href", 'data:application/csv;charset=UTF-8,' + encodedUri)
                .attr("download", "my_data.csv")
                .text("Download Data");
            //$('#plot_div a').attr("href", 'data:application/csv;charset=UTF-8,' + encodedUri);
            //$('#plot_div a').attr("download", "my_data.csv");

            $("#query_box pre").text(result.query);
            $("#plot_div").append(download_link);
            $("#plot_div").show();
        });

    }

    function populate_plottingVars(selector) {

        var options = {};
        options[""]="";
        options["AvgC0_PerCore"] = "C0/SO";
        options["AvgP0_PerS0"] =  "P0/S0";
        options["S0_PerDay"] = "S0/Day";

        for (var option in options) {
            $(selector).append("<option value='"+option+"'>" + options[option] + "</option>");
        }

        $(selector).picker();
    }

    function removeFilter() {
        var filter_name = $(this).data('filter_name');
        delete selected_filters[filter_name];
        $("#filter_name").append("<option>" + filter_name + "</option>");
        $(this).remove();
    }

    function toggleQueryBox() {
        $("#query_box").toggle("slow");
    }

    function setVariableSelectors() {
        var selected_plot_type = $("input[name='plot_type']:checked").val();
        $(".variable_selectors_div").hide();
        $("#" + selected_plot_type + "_variable_selectors").show();
    }

    $(function () {
        $("#radio").buttonset();
        setVariableSelectors();

        $("#query_box").toggle();
        $("input[name='plot_type']").change(setVariableSelectors);
    });

    $(document).ready(function () {

        loadingImg("show", "Preparing Filter Options");

        $.getDariJson("Advanced", "getFilterOptions", {}, function (data) {
            filters = data;

            for (var name in filters) {
                $("#filter_name").append("<option>" + name + "</option>");
                filters[name].push("");
                filters[name].sort();
            }

            $("#filter_name").change(function () {
                var options = filters[$(this).find('option:selected').text()];
                $("#filter_value").empty();
                for (var i = 0; i < options.length; i++) {
                    $("#filter_value").append("<option>" + options[i] + "</option>");
                }
            });
            $("#filter_name").picker();
            $("#filter_value").picker();

            function addFilter(filter_name, filter_value) {
                selected_filters[filter_name] = filter_value;

                var filter_button = $("<button>" + filter_name + "=" + filter_value + '</button>');
                filter_button.data('filter_name', filter_name);
                filter_button.click(removeFilter);
                filter_button.button({
                    icons: {
                        secondary: "ui-icon-close"
                    }
                })

                $("#filters_list").append(filter_button);
                $("#filter_name").find('option:selected').remove();
                $("#filter_value").val(''); //reset
                $("#filter_name").val(''); //reset
            }

            $("#add_filter_button").click(function () {


                var filter_name = $("#filter_name").find('option:selected').text();
                var filter_value = $("#filter_value").find('option:selected').text();
                addFilter(filter_name, filter_value);
            });

            var url_params = eval("(" + '<%= ViewData["parameters"] %>' + ")");
            if (url_params) {
                url_params.filters.forEach(function (filter_name) {
                    addFilter(filter_name, url_params[filter_name]);
                });
                $('#x_axis').val(url_params['x']);
                $('#y_axis').val(url_params['y']);
                $('#hist_var').val(url_params['hist_var']);
                $("input[value='" + url_params['plot_type'] + "']").attr('checked', true);
                $("#plot_button").click();

            } else {

                loadingImg("hide");
            }


        }); //end of getDariJson

        populate_plottingVars("#x_axis");
        populate_plottingVars("#y_axis");
        populate_plottingVars("#hist_var");


        $("#plot_button").click(getPlottingData);

    });

</script>


</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">
</asp:Content>
