<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    DARI | Home
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
   
   <style>
       
        div .row
        {
            margin: 20px auto;
            vertical-align: top;
        }
 	
            div .row .color1
            {
                background-color: rgb(165,208,40);
            }
            div .row .color2
            {
                background-color: rgb(245,192,64);
            }
            div .row .color3
            {
                background-color: rgb(49,182,253);
            }
	       
        .title 
        {
            font-size: 35px;
            font-family: Neo Sans Intel Medium;
        }
	
       
       #row2 {
        height: 200px;
        position: relative;
        }
       
           #row2 .button 
           {
                width: 27%;
                text-align: center;
                font-size: 25px;
                height: 200px;
                position: absolute;
                top: 0px;
                
                color: White;
                
                background-image: linear-gradient(to top,rgba(255,255,255,.3) 0%,rgba(255,255,255,0) 100%);
                
                border: 2px solid rgba(0,0,0,.1);
                box-shadow: 1px 1px 3px 0 gray;
           }
       
           #row2 .button:hover 
           {
                color: White;
                background-image: linear-gradient(to bottom,rgba(255,255,255,.3) 0%,rgba(255,255,255,0) 100%);
           }
               #row2 .button img
               {
                   height: 150px;
                   width: 150px;
               }  
       #row3 
       {
           margin-top: 50px;
       } 
       
   </style>

   <script>
       //intialization
       $(function () {
            //display and color the 3 buttons 
           var left_positions = ["0px", "33%", "66%"];
           $("#row2 .button").each(function (idx, el) {
               var left_position = left_positions[idx];
               $(this).css('left', left_position);
               $(this).addClass('color' + (idx + 1));
           });

       });

   </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div id="row1" class="row">

        <h2 class="title">Data Analysis and Reporting Interface</h2>

    </div>

    <div id="row2" class="row">

        <a class="button" href="/Reports">Monthly Reports <img src="/Content/images/calendar_icon.png"/></a>
        <a class="button" href="/byUser">User Histories <img src="../../Content/images/computer_icon.png"/></a>
        <a class="button" href="/Advanced">Analytics <img src="../../Content/images/graph_icon.png"/></a>

    </div>

    <div id="row3" class="row">

        <h1>Recent Plots</h1>
        <%=ViewData["recentPlots"]%>

    </div>

</asp:Content>
