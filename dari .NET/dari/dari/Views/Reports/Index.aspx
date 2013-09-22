<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Monthly Reports
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <p class="instructions">Select your options, in order. If you must go back and change an option, continue to go down from there in the same order. </p>
     <form id="param_form">
        <div id="panels"></div>
        <input id="tblPrefix" name="tblPrefix" type="hidden"/>
        <%--<input id="plotButton" class="button" type="submit" value="Plot data >>" disabled/>--%>
    </form>
        <button id="plotButton"> Plot data </button>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">

<script>

    var params = ["OS", "Analysis", "Classification", "Date", "Analysis_Parameters", "Classes"];
    var dates = {};
    var selections = {};
    var formData = {}


    var analysis_options;

    function getAnalysisOptions(os) {
        //to do: empty all the selectors

        getDariJson("Reports", "getAnalysisOptions", { os: os }, function (data) {

            analysis_options = data;
            for (var analysis_type in data) {

                var analysis_selector = $('select[name="Analysis"]');
                analysis_selector.append($('<option></option>').attr('value', analysis_type).text(analysis_type));
            }

        });
    }

    function resetDependants(current_param) {

        var dependantParam = false;
        for (var i = 0; i < params.length; i++) {

            if (current_param == params[i]) {
                dependantParam = true;
            } else if (dependantParam) {
                $('select[name="' + params[i] + '"]').html("<option></option>");
            }
        }

    }

    //document ready
    $(function () {


        params.forEach(function (param, i) {

            $('#panels').append('<h1 id="' + param + '">' + param + ' <strong></strong></h1><div></div>');

            var latestDiv = $('#panels div').last();

            if (param != "Classes") {

                latestDiv.append('<select name="' + param + '"><option></option></select>');

                $('select').last().picker();
            }

        });

        //add
        var os_selector = $('select[name="OS"]');
        os_selector.append($('<option></option>').attr('value', "WIN").text("Windows"));
        os_selector.append($('<option></option>').attr('value', "LIN").text("Linux"));
        os_selector.change(function () {
            getAnalysisOptions($(this).val());
        })

        $('#panels').accordion({ heightStyle: "fill" });

        $('select').change(function () {

            var current_param = $(this).attr("name");

            //display selection in heading
            $('#' + current_param + " strong").text("(" + $(this).find('option:selected').text() + ")");

            //Open next panel
            $('#' + current_param).next().next('#panels h1').click();

            //Store value
            formData[current_param] = $(this).val();

            //reset all the following selectors;
            resetDependants(current_param);

            switch (current_param) {

                case "Analysis":
                    var selectedAnalysis = $(this).val();
                    selections["selectedAnalysis"] = selectedAnalysis;

                    dates = {};
                    analysis_options[selectedAnalysis].forEach(function (p, i) {
                        dates[p.bit_map] = p.time_stamps;
                        $('[name=Classification]').append($('<option></option>').attr('value', p.bit_map).text(p.pc_header));
                    });

                    break;

                case "Classification":
                    var selectedClassification = $(this).val();
                    selections["selectedClassification"] = selectedClassification;
                    $('#Classes').next('div').empty(); //remove?


                    $('#Date strong').empty();
                    $('[name=Date]').html('<option></option>');

                    dates[selectedClassification].forEach(function (opt2, j) {
                        var date_stamp = new Date(opt2 * 1000);
                        $('select[name=Date]').append($('<option></option>').attr('value', opt2).text(date_stamp.toLocaleDateString()));
                    })

                    break;

                case "Date":
                    formData["Date"] = $(this).val();
                    $('[name=Analysis_Parameters]').html('<option></option>');

                    getDariJson("Reports", "getAnalysisParams", formData, function (data) {

                        var analysis_params = data.analysis_params;
                        var classes = data.classes;
                        $("#tblPrefix").val(data.tblPrefix); //may remove this for the sake of agnosticsm to SEMA architecture

                        analysis_params.forEach(function (p, i) {

                            $('[name=Analysis_Parameters]').append('<option value=' + p + '>' + p + '</option>');
                        });


                        $('#Classes').next('div').empty();

                        classes.forEach(function (p, i) {
                            var checkItem = $('<input type="checkbox" name="series" value="' + p.NodeID + '">')
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

                            $('#Classes').next('div').append(checkItem).append(p.NodeInfo + '<br>');
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

        $("#plotButton").click(function () {
            var values = $("#param_form").serialize();
            window.location = "Reports/Output/" + data_source + "?" + values;
        });

    });    // end of document ready

</script>

<style>

    #main
    {
        width: 1000px;
        
    }

</style>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">
</asp:Content>
