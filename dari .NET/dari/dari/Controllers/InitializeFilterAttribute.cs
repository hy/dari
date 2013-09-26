using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using dari.Models;

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

            //populate data source selector
            List<string> dataSourceOptions = new List<string>();
            foreach (dariDataConnectionElement dataSource in (new DariDataSources().collection))
            {
                dataSourceOptions.Add(dataSource.Name);
            }
            filterContext.Controller.ViewData["dataSourceOptions"] = dataSourceOptions;

            //update data source selector
            var last_source = "SEMA";
            if (filterContext.RouteData.Values["source"] !=null)
                last_source = (string) filterContext.RouteData.Values["source"];
            else if (Request.Cookies["last_source"] != null)
                last_source = Request.Cookies["last_source"].Value;

            filterContext.Controller.ViewData["initial_data_source"]=last_source;

        }


        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var Request = filterContext.HttpContext.Request;
            var Response = filterContext.HttpContext.Response;

            //check browser
            if ((Request.Browser.Browser.Equals("IE") && Convert.ToDecimal(Request.Browser.Version) < 9))
            {
                if (((string)filterContext.RouteData.Values["controller"]) != "Home")
                {
                    filterContext.Result = new RedirectToRouteResult(
                        new RouteValueDictionary { { "controller", "Home" }, { "action", "UnsupportedBrowser" } });
                }
            }

        }
    }
}
