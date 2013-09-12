using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dari.Controllers
{
    public class SaveQueryFilterAttribute : ActionFilterAttribute
    {
        public string newUrlLabel;

        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            var Request = filterContext.HttpContext.Request;
            var Response = filterContext.HttpContext.Response;

            //var controllerName = filterContext.RouteData.Values["controller"];
            //var actionName = filterContext.RouteData.Values["action"];
            //var sourceName = filterContext.RouteData.Values["source"];

            //string newURL;

            //if ((controllerName == "Summary") && (actionName == "plotData"))
            //    newURL = "Summary/plotDataSaved/" + sourceName + "?" + filterContext.HttpContext.Request.Form.ToString();
            //else if ((controllerName == "Plot") && (actionName == "plotData"))
            //    newURL = "Summary/plotData/" + sourceName + "?" + filterContext.HttpContext.Request.Form.ToString();
            //else
            //    return;
            string label;
            string url;
            for (int i = 0; i < 10; i++)
            {
                label = "";
                url = "";

                if (Request.Cookies["label" + i] != null)
                    label = Request.Cookies["label" + i].Value;
                if (Request.Cookies["url" + i] != null)
                    url = Request.Cookies["url" + i].Value;

                Response.Cookies.Add(new HttpCookie("url" + (i + 1), url));
                Response.Cookies.Add(new HttpCookie("label" + (i + 1), label));
            }

            string[] tokens = Request.RawUrl.Split(new char[] { '/' });
            string source = tokens.Last();
            string type = tokens[1];
            string newLabel = source + " :: " + type + " >> ";
            string newUrl ="";
            if (type.Equals("Summary"))
            {
                newLabel += (Request.Params["analysis"] + " >> " + Request.Params["date"] + " >> ");
                newUrl = type + "/plotDataSaved/" + source + "?" + Request.Form.ToString();
            }
            Response.Cookies.Add(new HttpCookie("url0", newUrl));
            Response.Cookies.Add(new HttpCookie("label0", newLabel));
        }

    }
}