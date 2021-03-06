﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	SearchHosts
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

   <div id="header">Search for Hosts:</div>

    <span class="instructions">Use drop down menus to narrow down results as needed or just type in host name directly.</span>

    <div class="selectorGroup">
        <span>Operating System:</span>
            <select id="osSelector">
            <option></option>
            <option>Linux</option>
            <option>Windows</option>
            </select>
    </div>
    <div class="selectorGroup">
        <span>Host Platform: </span>
            <select id="platformSelector"></select>
    </div>
    <div class="selectorGroup">
        <span>Product Family: </span>
            <select id="productFamilySelector"></select>
    </div>
    <div class="selectorGroup">
        <span>By Name:</span>
        <div class="styled-select">
            <input id="hostSearch" type="text" /> <img id="small_loader" class="ajax" src="/Content/images/small_ajax.gif"/> 
        </div>
    </div>

    <a class="button" id="goToPlotButton"></a>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <script>

        //initialization
        $(function () {

            //initializing the picker style on all the select inputs
            $("select").picker();

            /*Calling the dari JSON API function "HostPlatforms". This will return data to a callback function 
            as array of strings of the names of all the possible host platforms in the system.
            These will be used to populate the platformSelector
            */
            $.getDariJson("byUser","HostPlatforms",null, function (data) {
                $('#platformSelector').empty();
                $('#platformSelector').append('<option></option>');
                data.forEach(function (platformName) {
                    $('#platformSelector').append('<option>' + platformName + '</option>');
                });

                loadingImg("hide");
            });

            /*Calling the dari JSON API function "ProductFamilies". This will return data to a callback function 
            as an array of strings of the names of all the possible product families in the system.
            These will be used to populate the productFamilySelector
            */
            $.getDariJson("byUser", "ProductFamilies", null, function (data) {
                $('#productFamilySelector').empty();
                $('#productFamilySelector').append('<option></option>');
                data.forEach(function (productFamilyName) {
                    $('#productFamilySelector').append('<option>' + productFamilyName + '</option>');
                });
            });


            /* initializing the the autocomplete jquery ui, on the hostSearch input box */
            $("#hostSearch").autocomplete({
                source: function (request, response) {
                    $('#small_loader').show();

                    /*Calling the dari JSON API function "getHostNames". This will return data to a callback function 
                    as An array of  strings of all matching host names.
                    */
                    $.getDariJson("byUser", "getHostNames", {
                        hostPlatform: $("#platformSelector option:selected").text(),
                        productFamily: $("#productFamilySelector option:selected").text(),
                        os: $("#osSelector option:selected").text(),
                        key: request.term
                    }, function (data) {
                    
                        //The results will be used to populate the autocomplete options
                        response(data);
                        $('#small_loader').hide();
                    });
                },
                select: function (event, ui) {
                    //when a hostname is selected, show the button, to navigate it to the plotting page
                    $('#goToPlotButton').show().css('display', 'block'); ;
                    $('#goToPlotButton').text("Plot " + ui.item.value + " >>");
                    $("#goToPlotButton").attr("href", $.makeDariUrl("byUser","HostPage",{hostName: ui.item.value}));

                },
                minLength: 0
            });

            //also activate autocompelte results, when the input is first clicked
            $("#hostSearch").click(function () {
                $(this).autocomplete("search");
            });

        });
    </script>

    <style>
    

    #header {
    color: rgb(49,182,253);
    font-size: 35px;
    }
    
    .selectorGroup
    {
        width: 600px;
        padding: 20px;
    }
    
    .selectorGroup > span 
    {
        text-align: right;
        width: 200px;
        display: inline-block;
        padding-right: 20px;
        font-size: 25px;
    }

    select, input {
       width: 240px;
       }
   
       #goToPlotButton
       {
           background: rgb(49,182,253);
            display: block;
            padding: 30px 0px;
            text-align: center;
            margin: 20px 5%;
            bottom: 0px;
            width: 90%;
            color: white;
            font-size: 30px;
            text-decoration: none;
            box-shadow: 1px 1px 5px 0px #0F0A0A;
            border-radius: 5px;
            display: block;
            display: none;
       }
       
       .ui-autocomplete
       {
        background: rgb(69,132,211);
        color: White;
       }
       
           .ui-autocomplete a
           {
            background: rgb(69,132,211);
            color: White;
           }
           .ui-autocomplete a:hover
           {
            color: rgb(69,132,211);
            background: rgb(255,255,153);
           }

</style>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="absolutelyPositionedContent" runat="server">
</asp:Content>
