<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Home Page
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
   
   <style>
       
       #main
    {
        box-shadow: none;
        -webkit-box-shadow: none;
    }
       
       #main > div {
        padding: 50px;
        }
       
       .row
       {
           margin: 20px auto;
           vertical-align: top;
       }
       
       #row1 > div  
       {
           display:inline-block;
           width: 45%;
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
       
             #title{

        font-size: 60px;
        font-family: Calibri;
        font-weight:900;
        /*text-shadow: 1px 1px 3px Black;*/

        -webkit-text-stroke: 1px White;
-webkit-text-fill-color: rgb(49,182,253);
border-radius: 5px;
        
        padding: 20px;
        background: rgb(69,132,211);
        box-shadow: 1px 1px 5px 0px #0F0A0A;
      }  
      
      #title span
      {
          -webkit-text-fill-color: White;
      }
      
      #about_dari_text {
width: 90%;
background: rgba(244,189,58,0.5);
padding: 10px;
border: 0px solid rgba(244,189,58,0.9);
height: 300px;
}
      
      .scroll-pane
{
	width: 100%;
	height: 200px;
	overflow: auto;
}
.horizontal-only
{
	height: auto;
	max-height: 200px;
}
	.title 
	{
	    font-size: 35px;
	    font-family: Neo Sans Intel Medium;
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
	
	
   </style>

   <script>

       $(function () {
           $('.scroll-pane').jScrollPane();
       });

       $(document).ready(function () {
           //var button_colors = ["rgb(165,208,40)", "rgb(245,192,64)", "rgb(49,182,253)"];
           var left_positions = ["0px", "33%", "66%"];
           $("#row2 .button").each(function (idx, el) {
               //var button_color = button_colors[idx];
               var left_position = left_positions[idx];
               //$(this).css('background-color', button_color);
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
        <a class="button" style="" href="/Summary">Monthly Reports <img src="/Content/images/calendar_icon.png"/></a>
        <a class="button" href="/byUser">User Histories <img src="../../Content/images/computer_icon.png"/></a>
        <a class="button" href="/Advanced">Analytics <img src="../../Content/images/graph_icon.png"/></a>
    </div>
    <div id="row3" class="row">
        <h1>Recent Plots</h1>
        <%=ViewData["recentPlots"]%>
    </div>
</asp:Content>
