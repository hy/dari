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

    var params = ["OS", "Analysis", "Classification", "Date", "Analysis_Parameters", "Classes"]; //array of all paramters needed to build report
    var formData = {}; //object that stores associative array mapping names of paramters to their values
    var dates = {}; //object that stores asssociative array mapping classifications bit masks to their respective array of dates
    var analysis_options; //object that stores object where each member is a potential option for analysis type, it maps to values used to fill the remaining paramter options

    /*this function calls the json api to get all the analysis options
    --Paramters---
    os: operating system selected by the user
    */
    function getAnalysisOptions(os) {

        /* Calling "getAnalysisOptions" in JSON API to get all the possible options so that the user can select the analysis type,  
        and its dependent available classification types, and the further dependent analysis time stamps 
        It returns an object to a call back function where each member, corresponds to a possible analysis type, 
        where the name of the member is the name of the analysis type (ex. "Host Memory Utilization"), 
        and the value is an array of objects corresponding to classification types for that analysis type.
        The classification types object has the following members:
        · time_stamps: an array of integers listing the possible time stamps for this analysis, and classification type
        · bit_maps: the "prodclasbitmask" for this classification, so that it can be programmatically identified
        · pc_header: the string representation of this classification type
        */
        getDariJson("Reports", "getAnalysisOptions", { os: os }, function (data) {

            //save the analysis options, and then add an option for each analysis type into the selector
            analysis_options = data;
            for (var analysis_type in data) {

                var analysis_selector = $('select[name="Analysis"]');
                analysis_selector.append($('<option></option>').attr('value', analysis_type).text(analysis_type));
            }

        });
    }


    /* Since, many of the parameter options depend on a previously selected option, 
    this is a utlity function used to reset all the appropriate selectors after a given selector is changed*/
    function resetDependants(current_param) {
        
        //flag indicating that dependant paramter has been found
        var dependantParam = false;

        //iterate through all the paramters
        for (var i = 0; i < params.length; i++) {

            //if the changed paramter is reached in the array, 
            if (current_param == params[i]) {
                //all of the following paramters are dependant,
                dependantParam = true;
            } else if (dependantParam) {
                //and they should be reset
                $('select[name="' + params[i] + '"]').html("<option></option>");
                $('#' + params[i] + ' strong').text("");
            }
        }

    }

    //initialization
    $(function () {


        /* for each paramter, create a panel for the display */
        params.forEach(function (param, i) {

            //add header and panel
            $('#panels').append('<h1 id="' + param + '">' + param + ' <strong></strong></h1>');
            var newPanel = $('<div></div>').appendTo('#panels');

            //add a selector to each panel (except for the 'classes' panel);
            if (param != "Classes") {
                
                //append the selector, with a blank option, and style it as a dari "picker"
                $('<select name="' + param + '"><option></option></select>').appendTo(newPanel).picker();

            } else {
                //if this panel is for the classes, it will contain a list of checkboxes, which should be left justified
                newPanel.css('text-align', 'left');
                newPanel.css('height', '150px');
            }

        });

        //intialize the selector for the operating system parameter
        var os_selector = $('select[name="OS"]');
        os_selector.append($('<option></option>').attr('value', "WIN").text("Windows"));
        os_selector.append($('<option></option>').attr('value', "LIN").text("Linux"));
        os_selector.change(function () {
            getAnalysisOptions($(this).val());
        })

        //intialize the jquery ui display of the panels
        $('#panels').accordion({ heightStyle: "content" });

        //control what each selector does once changed
        $('select').change(function () {

            //the selector is identified by it's name attribute 
            var current_param = $(this).attr("name");

            //display selection in heading
            $('#' + current_param + " strong").text("(" + $(this).find('option:selected').text() + ")");

            //Open next panel
            $('#' + current_param).next().next('#panels h1').click();

            //Store selected value
            formData[current_param] = $(this).val();

            //reset all the following selectors;
            resetDependants(current_param);

            //the following actions, depend on which selector was changed
            switch (current_param) {

                case "Analysis":

                    /*set the classification options for this analysis type programmatically and on the display */
                    dates = {};
                    analysis_options[formData.Analysis].forEach(function (p, i) {
                        dates[p.bit_map] = p.time_stamps; //programmatically map the classifications to their respective list of time stamps
                        $('[name=Classification]').append($('<option></option>').attr('value', p.bit_map).text(p.pc_header)); //each classification is programmatically stored as a bit mask and displayed as a readable "pc_header"
                    });

                    break;

                case "Classification":

                    //get date array for selected classfication, and add each date as an option to the date selector
                    dates[formData.Classification].forEach(function (opt2, j) {
                        var date_stamp = new Date(opt2 * 1000);
                        $('select[name=Date]').append($('<option></option>').attr('value', opt2).text(date_stamp.toLocaleDateString()));
                    })

                    break;

                case "Date":

                    /* Calling "getAnalysisParams" in JSON API to get all the possible choices for analysis parameters.
                    It returns an object to a call back function with the following members:
                    	· analysis_params: array of strings naming possible parameters for this analysis
	                    · classes: array of objects corresponding to possible classes. Each object contains:
		                    ○ NodeID: integer of the node class
		                    ○ NodeInfo: the string representation of that node class
	                    · tblPrefix: (for programmatic use with SEMA- soon should be obsolete) the table, where the data can be found
                    */
                    getDariJson("Reports", "getAnalysisParams", formData, function (data) {

                        //store the returned values
                        var analysis_params = data.analysis_params;
                        var classes = data.classes;
                        $("#tblPrefix").val(data.tblPrefix); //may remove this for the sake of agnosticsm to SEMA architecture

                        //display all the options for the analysis parameters selector
                        analysis_params.forEach(function (p, i) {
                            $('[name=Analysis_Parameters]').append('<option value=' + p + '>' + p + '</option>');
                        });

                        //clear all the classes options
                        $('#Classes').next('div').empty();

                        //add checkboxes for each class to the class panel
                        classes.forEach(function (p, i) {
                            var checkItem = $('<input type="checkbox" name="series" value="' + p.NodeID + '">')
                                    .data('name', p.NodeInfo)
                                    .change(function () {
                                    //adding handler that will make sure that no more than 3, are checked, and will show button if at least one is checked
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

        //when the plot button is clicked, prepare the report generating url, and then navigate to it
        $("#plotButton").click(function () {

            var url = $.makeDariUrl("Reports", "Output", { classification_name: $("[name=Classification] :selected").text() }); //making base url
            var values = $("#param_form").serialize(); //getting form values
            $('input:checkbox:checked').each(function () {
                values += ("&series_name=" + encodeURIComponent($(this).data('name'))); //getting checked item values
            });

            window.location = (url + "&" + values); //append paramters to the base url, and navigate to it
        });

    });//end of initialization

</script>

<style>

    #main
    {
        width: 1000px;
        
    }

    #panels > div
    {
        text-align: center;
    }
    
    #plotButton {
        width: 100%;
    }
    
    #param_form 
    {
        /*height: 500px;*/
    }
</style>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">
</asp:Content>
