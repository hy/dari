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

        <h2> Choose Variables </h2>
        <div class="grey_box">
            X axis: <select name="x_axis" id="x_axis"></select>
            Y axis: <select name="y_axis" id="y_axis"></select>
        </div>
        <button id="plot_button">Plot</button>
        <div id="ajax_loader">
            <div><img src="../../Content/images/filter_loading.gif"/> &nbsp <span>Preparing Filter Options</span>... </div>
        </div>
    </div>

    <div id="plot_div"></div>
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
    .data_point
    {
        fill: rgb(49,182,253);
        opacity: 0.5;
        cursor: pointer;
        }
        
    #filtering_div
    {
        padding: 10px;
    }
    
    #ajax_loader
    {
        position: absolute;
        top: 0px;
        left: 0px;
        width: 100%;
        height: 100%;
        text-align: center;
        vertical-align: center;
        background: White;
    }
    
    #ajax_loader div
    {
        position: absolute;
        top: 30%;
    width: 100%;
    margin: 0 auto;
    text-align: center;
    color: rgb(49,182,253);
font-size: 30px;
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
</style>

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

    function plotTemp(x_axis, y_axis) {
        $('#loading_gif').show();

        //var formData = { x: "AvgC0_PerCore", y: "AvgP0_PerS0" };
        //var formData = { x: "MaxP0_PerC0", y: "AvgC0_PerCore" };
        var formData = { x: x_axis, y: y_axis };
        formData["filters"] = [];

        for (var filter in selected_filters) {
            formData["filters"].push(filter);
            formData[filter] = selected_filters[filter];
        }

        getDariJson("Advanced", "getCoorelationData", formData,
            function (data) {

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
                        window.location.href = "/byUser/HostInfo/?hostName=" + $(this).siblings('text').text().split('.')[0];
                    });



                loadingImg("hide");
            }
        );


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

    function loadingImg(action, message) {
        if (action == "show") {
            $("#ajax_loader span").text(message);
            $("#ajax_loader").show();
        } else {
            $("#ajax_loader").hide('slow');
        }

    }

    $(document).ready(function () {

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

            $("#add_filter_button").click(function () {


                var filter_name = $("#filter_name").find('option:selected').text();
                var filter_value = $("#filter_value").find('option:selected').text();

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
            });

            $("#ajax_loader").hide('slow');


        }); //end of getDariJson

        populate_plottingVars("#x_axis");
        populate_plottingVars("#y_axis");

        $("#plot_button").click(function () {
            loadingImg("show", "Generating Plot");
            plotTemp($("#x_axis").val(), $("#y_axis").val());
        });

    });

</script>


</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">
</asp:Content>
