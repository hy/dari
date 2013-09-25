using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dari.Controllers
{
    public class InitializeFilterAttribute : ActionFilterAttribute
    {
        //
        // GET: /InitializeFilterAttribute/

        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            var Request = filterContext.HttpContext.Request;
            var Response = filterContext.HttpContext.Response;

            var last_source = "SEMA";
            if (filterContext.RouteData.Values["source"] !=null)
                last_source = (string) filterContext.RouteData.Values["source"];
            else if (Request.Cookies["last_source"] != null)
                last_source = Request.Cookies["last_source"].Value;

            filterContext.Controller.ViewData["initial_data_source"]=last_source;

        }
    }
}
