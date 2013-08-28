<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<dynamic>" %>
<head>
    <script src="//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.9.1.min.js"></script>

    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  <script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
<style>
    
    body 
    {
        background: rgb(49,182,253);
        margin: 0px;
        font-family: Calibri;
    }
    
    #main 
    {
        background: White;
        color: Black;
        width: 800px;
        height: 600px;
        margin: auto;
                  -moz-box-shadow:    1px 1px 10px 1px #0F0A0A;
  -webkit-box-shadow: 1px 1px 10px 1px #0F0A0A;
  box-shadow:         1px 1px 10px 1px #0F0A0A;
        position: relative;

    }
    #main > *
    {
        margin-left: auto;
        margin-right: auto;
    }
    #header 
    {
        background: rgb(69,132,211);
        color: White;
        padding: 20px;
    }
    
    .instructions
    {
        font-style: italic;
        padding: 20px 50px;
        display: inline-block;
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
    .ajax 
        {
            display: none;
        }

    .styled-select {
       width: 240px;
        height: 34px;
        overflow: hidden;
        background: url(/public/down_arrow_brown.jpg) no-repeat right rgb(255,255,153);
        border: 2px solid rgb(244,189,58);
        border-radius: 5px;
        display: inline-block;
        color: rgb(244,189,58);
        box-shadow: 1px 1px 5px 0px #0F0A0A;
       }
   
       .styled-select select, .styled-select input {
       background: transparent;
       width: 268px;
       padding: 5px;
       font-size: 16px;
       line-height: 1;
       border: 0;
       border-radius: 0;
       height: 34px;
       -webkit-appearance: none;
       color: rgb(147,106,8);
       }
       
       #goToPlotButton
       {
           background: rgb(49,182,253);
            display: block;
            padding: 30px 0px;
            text-align: center;
            margin: 20px 5%;
            position: absolute;
            bottom: 0px;
            width: 90%;
            color: white;
            font-size: 30px;
            text-decoration: none;
            box-shadow: 1px 1px 5px 0px #0F0A0A;
            border-radius: 5px;
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

    <script>

        $(document).ready(function () {

            $.getJSON('/byUser/HostPlatforms', { source: "SEMA" }, function (data) {
                $('#platformSelector').empty();
                $('#platformSelector').append('<option></option>');
                data.forEach(function (platformName) {
                    $('#platformSelector').append('<option>' + platformName + '</option>');
                });
            });

            $.getJSON('/byUser/ProductFamilies', { source: "SEMA" }, function (data) {
                $('#productFamilySelector').empty();
                $('#productFamilySelector').append('<option></option>');
                data.forEach(function (productFamilyName) {
                    $('#productFamilySelector').append('<option>' + productFamilyName + '</option>');
                });
            });


            $("#hostSearch").autocomplete({
                source: function (request, response) {

                    $('#small_loader').show();

                    $.getJSON('/byUser/getHostNames', { source: "SEMA",
                        hostPlatform: $("#platformSelector option:selected").text(),
                        productFamily: $("#productFamilySelector option:selected").text(),
                        os: $("#osSelector option:selected").text(),
                        key: request.term
                    }, function (data) {
                        response(data);
                        $('#small_loader').hide();
                    });
                },
                select: function (event, ui) {
                    //selectedHost = ui.item.value
                    $('#goToPlotButton').show();
                    $('#goToPlotButton').text("Plot " + ui.item.value + " >>");
                    //$("#goToPlotButton").attr("href", "/Plot/line/" + ui.item.value)
                    $("#goToPlotButton").attr("href", "/byUser/HostInfo/?hostName=" + ui.item.value)

                },
                minLength: 0
            });

            $("#hostSearch").click(function () {
                $(this).autocomplete("search");
            });

        });
    </script>
</head>
<body>

<div id="main">
<div id="header">Search for Hosts:</div>

    <span class="instructions">Use drop down menus to narrow down results as needed or just type in host name directly.</span>

    <div class="selectorGroup">
        <span>Operating System:</span>
        <div class="styled-select">
            <select id="osSelector">
            <option></option>
            <option>Linux</option>
            <option>Windows</option>
            </select>
        </div>
    </div>
    <div class="selectorGroup">
        <span>Host Platform: </span>
        <div class="styled-select">
            <select id="platformSelector"></select>
        </div>
    </div>
    <div class="selectorGroup">
        <span>Product Family: </span>
        <div class="styled-select">
            <select id="productFamilySelector"></select>
        </div>
    </div>
    <div class="selectorGroup">
        <span>By Name:</span>
        <div class="styled-select">
            <input id="hostSearch" type="text" /> <img id="small_loader" class="ajax" src="/public/images/small_ajax.gif"/> 
        </div>
    </div>

    <a id="goToPlotButton"></a>

</div>

</body>