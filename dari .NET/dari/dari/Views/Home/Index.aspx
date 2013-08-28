<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Home Page
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
   
   <style>
       
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
       
       #row2 .button 
       {
            width: 45%;
            text-align: center;
            font-size: 25px;
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
	
	
   </style>

   <script>

       $(function () {
           $('.scroll-pane').jScrollPane();
       });

   </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="row1" class="row">
         <div id="title" class="box_content">
            <span>D</span>ata <br />
            <span>A</span>nalysis & <br />
            <span>R</span>eporting <br />
            <span>I</span>nterface
         </div>
         <div style="float: right;">
               <h1>About DARI</h1>
               <div id="about_dari_text" class="scroll-pane">

               <p>
               DARI Is a web based interface built on the D3 framework, sdfsdf
The goal of this tutorial is to explain action filters. An action filter is an attribute that you can apply to a controller action -- or an entire controller -- that modifies the way in which the action is executed. The ASP.NET MVC framework includes several action filters:

OutputCache – This action filter caches the output of a controller action for a specified amount of time.
HandleError – This action filter handles errors raised when a controller action executes.
Authorize – This action filter enables you to restrict access to a particular user or role.
You also can create your own custom action filters. For example, you might want to create a custom action filter in order to implement a custom authentication system. Or, you might want to create an action filter that modifies the view data returned by a controller action.

In this tutorial, you learn how to build an action filter from the ground up. We create a Log action filter that logs different stages of the processing of an action to the Visual Studio Output window.
                </p>
               </div>
         </div>
    </div>
    <div id="row2" class="row">
        <a class="button" style="" href="/Summary">Aggregate Reports</a>
        <a class="button" style="float: right;" href="/byUser">History by Host</a>
    </div>
    <div id="row3" class="row">
        <h1>Recent Plots</h1>
        <%=ViewData["recentPlots"]%>
    </div>
</asp:Content>
