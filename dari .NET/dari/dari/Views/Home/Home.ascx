<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<dynamic>" %>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Welcome to DARI</title>


      <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  <script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>


    <style>
        
        body 
        {
            padding: 0px;
            margin: 0px;
            background: rgb(255,255,153);
            font-family: Calibri;
        text-shadow: 1px 1px 3px Black;
            

        }
        
        a 
        {
            color: rgb(142,121,94);
            text-decoration: underline;
            
        }
    #main 
    {
        display:block;
        width: 1000px;
        margin-top: 0px;
        margin-left: auto;
        margin-right: auto;
        height: 800px;
        background: green;
        
        border: rgb(169,165,124) 1px solid; 
        
          -moz-box-shadow:    1px 1px 10px 1px #0F0A0A;
  -webkit-box-shadow: 1px 1px 10px 1px #0F0A0A;
  box-shadow:         1px 1px 10px 1px #0F0A0A;
  
        color: White;
        }
        
    #footer 
    {
        display:block;
        width: 800px;
        margin-top: 10px;
        margin-left: auto;
        margin-right: auto;
        text-align: right;
        text-shadow: 1px 1px;

        color: rgb(169, 165, 124);
        }
        
    div 
    {

    }
    
    .box 
    {
        

   -moz-box-shadow:    inset 0 0 10px #000000;
   -webkit-box-shadow: inset 0 0 10px #000000;
   box-shadow:         inset 0 0 10px #000000;
    }
    
    .box > div 
    {
        margin: 5px 10px;
        
    }
     .box > span 
    {
        display: block;
width: 100%;
text-align: center;
margin: 5px 0px;
    }
    
    
    #row1
    {
        height: 5%;
        background: rgb(210,203,103);
        }
    #row2
    {
        height: 45%;
        }
    #row3
    {
        height: 5%;
        background: rgb(156,190,189);
        }
    #row4
    {
        height: 45%;
        background: rgb(255,192,0);
        }
        
        
         #col1_row1
      {
          display: inline-block;
        height: 100%;
        width: 80%;
        float: left;
        text-align: right;
      }       
        
        #col2_row1
      {
          display: inline-block;
        background: rgb(200,159,93);
        height: 100%;
        float: right;
        width: 10%;
      }       
     #col3_row1
      {
          display: inline-block;
        background: rgb(223,220,183);
        height: 100%;
        float: right;
        width: 10%;
      }  
        
      #row2_col1
      {
          display: inline-block;
          width: 40%;
        background: rgb(169,165,124);
        height: 100%;
        float: left;
      }
      
      #title{
        
        rgb(49,182,253);
        margin-left: 40px;
        font-size: 70px;
        font-family: Calibri;
        font-weight:900;
        text-shadow: 1px 1px 3px Black;

        -webkit-text-stroke: 1px White;
-webkit-text-fill-color: rgb(169,165,124);

      }  
      
      #title span
      {
          -webkit-text-fill-color: rgb(223,220,183);
      }

      #row2_col2
      {
          display: inline-block;
          width: 60%;
        background: rgb(146,208,80);
        height: 100%;
        float: right;
        position:relative;
      }  
       #row2_col2 > a 
      {
        position: absolute;        
          -moz-box-shadow:    1px 1px 10px 1px #0F0A0A;
  -webkit-box-shadow: 1px 1px 10px 1px #0F0A0A;
  box-shadow:         1px 1px 10px 1px #0F0A0A;
  width: 80%;
  margin: 0 10%;
   height: 35%;

  /* background: rgb(169,165,124); */
   cursor: pointer;
   text-align:center;
   vertical-align:middle;
   
   
   display: table-cell;
    text-align: center;
    vertical-align: middle;
    border: 1px dotted #656565;
    
    line-height: 125px;
    color: White;
    text-decoration: none;
    font-size: 20px;
   
      }     
      #row2_col2 svg
      {
          position:absolute;
          left:0; top:0; width:100%; height:100%
      }
        
      #row4_col1
      {
          display: inline-block;
          width: 100%;
        background: rgb(255,192,0);
        height: 100%;
        float: left;
        font-size: 25px;
      }  

      #row4_col1 div
      {
          margin: 20px 30px;
      }
      
      #row4_col1 a
      {
          font-size: 20px;
          text-shadow: 0 0;
      }

.button {
   border-top: 1px solid #96d1f8;
   background: #65a9d7;
   background: -webkit-gradient(linear, left top, left bottom, from(#3e779d), to(#65a9d7));
   background: -webkit-linear-gradient(top, #3e779d, #65a9d7);
   background: -moz-linear-gradient(top, #3e779d, #65a9d7);
   background: -ms-linear-gradient(top, #3e779d, #65a9d7);
   background: -o-linear-gradient(top, #3e779d, #65a9d7);
   /* padding: 18px 36px;  */
   -webkit-border-radius: 21px;
   -moz-border-radius: 21px;
   border-radius: 21px;
   -webkit-box-shadow: rgba(0,0,0,1) 0 1px 0;
   -moz-box-shadow: rgba(0,0,0,1) 0 1px 0;
   box-shadow: rgba(0,0,0,1) 0 1px 0;
   text-shadow: rgba(0,0,0,.4) 0 1px 0;
   color: white;
   font-size: 22px;
   font-family: Georgia, serif;
   text-decoration: none;
   vertical-align: middle;
   }
.button:hover {
   border-top-color: #28597a;
   background: #28597a;
   color: #ccc;
   }
.button:active {
   border-top-color: #1b435e;
   background: #1b435e;
   }

      
      .button_hover
      {
   background: rgb(210,203,108);
      }
      row
      {
          border-bottom: white 3px solid;
      }
    </style>

    <script>

        $(document).ready(function () {

            $("#col2_row4 > a ").hover(
            function () {
                $(this).css('background-color', 'rgb(210,203,108)')
            },
            function () {
                $(this).css('background-color', '')
            }
                );


            $("#dialog-modal").dialog({
                height: 140,
                modal: true
            });


        });
    </script>
</head>


<body>

<div id="main">
    <div id="row1" class="row">
        <div id="col1_row1" class="box">
             <div> Welcome <strong><%= HttpContext.Current.User.Identity.Name %></strong>! You are currently connected to </div>
        </div>
        <div id="col3_row1" class="box"> <span><small>(Change)</small></span></div>
        <div id="col2_row1" class="box"> <span>SEMA</span> </div>
    </div>
    <div id="row2" class="row">
        <div id="row2_col1" class="box">

            <div id="title" class="box_content">
            <span>D</span>ata <br />
            <span>A</span>nalysis & <br />
            <span>R</span>eporting <br />
            <span>I</span>nterface
            </div>
        </div>
        <div id="row2_col2" class="box">
        <%--<svg width="190px" height="160px" viewBox="0 0 190 160" version="1.1" xmlns="http://www.w3.org/2000/svg">--%>
              <a href="/byUser" class="button" style="top: 10%;">
                Plot History by User
            </a>
            <a href="/Summary" class="button" style="bottom: 10%;">
                Plot Summary Data
            </a>
      <path d="M10 80  C 40 10, 65 10, 95 80 S 150 150, 180 80 Z" stroke="White" fill="transparent"/>
    </svg>
        </div>
    </div>
    <div id="row3" class="row box"></div>
    <div id="row4" class="row">
        <div id="row4_col1" class="box">
            <div>
            My Recent Plots <br />
            <%=ViewData["recentPlots"]%>
            </div>
        </div>
    </div>
</div>
<div id="footer">
Request Access | About Dari | Version 1.0.1.3 Copyright 2013  
</div>

<% var notSupported = (bool)ViewData["notSupported"];
   if (notSupported)
   {
    %>
<div id="dialog-modal" title="Lack of Browser Support">
  <p>Sorry, your browser is not supported at this time. Dari is not supported by IE8 and below.</p>
</div>
<%} %>
</body>
</html>

