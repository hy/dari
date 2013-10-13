using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using dari.Models;

namespace dari.Controllers
{
    /*This class implements the filter that is called before all the DARI controllers, to handle issues like
     * *making sure that the write browser is used
     * *mananging the current what is the data source DARI is currently connected to
     */
    public class InitializeFilterAttribute : ActionFilterAttribute
    {
        //This function popupulates the datasource menu with options from the configuration file,
        //It also checks the URL to make sure the right datasource is saved,
        //If there is no source in the url, it will update the display with the last selected data source
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

        //Check the browser. If the browser is not supported, then redirect to the notification page
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
