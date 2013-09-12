<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	summaryUI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <p class="instructions">Select your options, in order. If you must go back and change an option, continue to go down from there in the same order. </p>
     <form method="post" action="/Summary/plotData/SEMA">
        <div id="panels"></div>
        <input id="plotButton" class="button" type="submit" value="Plot data >>" disabled>
    </form>

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
    background: rgb(240, 240, 240);
}

#main
{
    /* display: none; */
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

    //TO DO: validate form before submitting

    var params = ["OS", "Analysis", "Classification", "Date", "Analysis_Parameters", "Classes"];
    var colors = ["MediumPurple", "steelblue", "DarkSeaGreen", "MediumPurple", "steelblue", "DarkSeaGreen"];

    var options = {};
    options["OS"] = ["Windows", "Linux"];
    options["Analysis"] = [
    //        "CPU Utilization and C Power States",
            "Host Memory Utilization",
            "Host Uptime and downtime periods",
    //        "CPU Thermal Sensor",
    //        "MultiCoreConcureentIdle"
    ];

    options["Classification"] = ["HostPlatform", "ProductFamily", "MaxClockSpeed", "BrandString", "NumPhysical", "NumCores", "NumLogical", "CorePerPhys"];
    options["Date"] = []
    options["Analysis_Parameters"] = [];
    options["Classes"] = [];

    Analysis_Parameters = {};
    Analysis_Parameters["CPU Utilization and C Power States"] = ["Busy", "Idle", "C0", "C1", "C2", "C3", "C1C2C3", "C2C3"];
    Analysis_Parameters["Host Memory Utilization"] = ["PERCENT_MEMUTIL"];
    Analysis_Parameters["Host Uptime and downtime periods"] = ["NUMPERDAY_DOWN", "NUMPERDAY_MIXED", "NUMPERDAY_OFF", "NUMPERDAY_OFFONLY", "NUMPERDAY_SUSPEND",
         "NUMPERDAY_SUSPENDONLY", "PERCENT_DOWNTIME", "PERCENT_MIXEDTIME", "PERCENT_OFFONLYTIME", "PERCENT_OFFTIME", "PERCENT_SUSPENDONLYTIME",
          "PERCENT_SUSPENDTIME", "PERCENT_UPTIME", "REGISTERED_TIME", "SEMAOFF_TIME"];

    var selections = {};
    var formData = {}

    $(document).ready(function () {

        //$('#plotButton').hide();

        params.forEach(function (param, i) {

            $('#panels').append('<h1 id="' + param + '">' + param + ' <strong></strong></h1><div></div>');

            var latestDiv = $('#panels div').last();

            if (param != "Classes") {

                latestDiv.append('<div class="styled-select"><select name="' + param + '"><option></option></select></div>');

                options[param].forEach(function (opt2, j) {
                    $('.styled-select select').last().append($('<option></option>').attr('value', opt2).text(opt2));
                })
            } else {
                //selectorDiv.css("overflow-y", "scroll");
            }

        });

        $('#panels').accordion({ heightStyle: "fill" });

        $('select').change(function () {

            //display selection in heading
            $('#' + $(this).attr('name') + " strong").text("(" + $(this).find('option:selected').text() + ")");

            //Open next panel
            $('#' + $(this).attr('name')).next().next('#panels h1').click();

            formData[$(this).attr('name')] = $(this).find(":selected").text();

            switch ($(this).attr("name")) {

                case "Analysis":
                    var selectedAnalysis = $(this).find(":selected").text();
                    selections["selectedAnalysis"] = selectedAnalysis;

                    $('#Analysis_Parameters strong').empty();
                    $('[name=Analysis_Parameters]').html('<option></option>');
                    Analysis_Parameters[selectedAnalysis].forEach(function (p, i) {

                        $('[name=Analysis_Parameters]').append('<option value=' + p + '>' + p + '</option>');
                    });


                    //$.getJSON('/Summary/getReportDates/SEMA', { analysis: selectedAnalysis }, function (dates) 
                    //$.getJSON('/Summary/getReportDates/SEMA', formData, function (dates) {
                    getDariJson("Summary", "getReportDates", formData, function (dates) {
                        $('#Date strong').empty();
                        $('[name=Date]').html('<option></option>');
                        dates.forEach(function (opt2, j) {
                            var date_stamp = new Date(opt2 * 1000);
                            $('select[name=Date]').append($('<option></option>').attr('value', opt2).text(date_stamp.toLocaleDateString()));
                        })
                    });
                    break;

                case "Classification":
                    var selectedClassification = $(this).find(":selected").text();
                    selections["selectedClassification"] = selectedClassification;
                    $('#Classes').next('div').empty();
                    break;

                case "Date":
                    formData["time"] = $(this).val();
                    //$.getJSON('/Summary/getReportClasses/SEMA', { analysis: selections["selectedAnalysis"], classification: selections["selectedClassification"], time: $(this).val() }, function (classes) {
                    //$.getJSON('/Summary/getReportClasses/SEMA', formData, function (classes) {
                    getDariJson("Summary", "getReportClasses", formData, function (classes) {

                        $('#Classes').next('div').empty();

                        classes.forEach(function (p, i) {
                            var checkItem = $('<input type="checkbox" name="series" value="' + p + '">')
                                    .change(function () {
                                        if ($('input:checkbox:checked').length > 3) {
                                            $(this).attr("checked", false);
                                            alert('Cannot check more than 3 items.');
                                        } else if ($('input:checkbox:checked').length > 0) {
                                            $('#plotButton').animate({
                                                opacity: 1
                                            });
                                            $('#plotButton').attr('disabled', false);
                                        } else {
                                            $('#plotButton').animate({
                                                opacity: 0
                                            });
                                            $('#plotButton').attr('disabled', true);
                                        }
                                    });

                            $('#Classes').next('div').append(checkItem).append(p + '<br>');
                        });

                    });
                    break;
            }

        });

        function openThis() {
            $(this).next().animate({ height: '100px' }, { easing: "swing" });
            $(this).unbind('click', openThis);
            $(this).click(closeThis);
        }

        function closeThis() {
            $(this).next().animate({ height: '0px' }, { easing: "swing" });
            $(this).unbind('click', closeThis);
            $(this).click(openThis);
        }

        $('.param_div div').first().animate({ height: '50px' }, { easing: "swing" });

    });

</script>

<style>
    .styled-select 
    {
        width: 80%;
        margin: auto;
        display: block;
    }
    
    .styled-select select 
    {
        width: 100%;
    }
    
    #plotButton
    {
        width: 100%;
        opacity: 0;
    }
</style>
</asp:Content>
