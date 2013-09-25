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

            /*make new cookie */
            string source = (string) filterContext.RouteData.Values["source"];
            string type = (string) filterContext.RouteData.Values["controller"];

            string newLabel = source + " :: ";
            string newUrl ="";


            if (type.Equals("Reports"))
            {
                DateTime epoch = new DateTime(1970, 1, 1, 0, 0, 0, 0);
                string dateString = epoch.AddSeconds(Convert.ToInt32(Request.Params["date"])).ToLocalTime().ToString("MMMM d, yyyy");
                newLabel += ("Reports >> " + Request.Params["analysis"] + " >> " + dateString);
                newUrl = type + "/Output/" + source + Request.Url.Query;
            }
            else if (type.Equals("Advanced"))
            {
                newLabel += "Analytics >> ";
                string plot_type = Request.Params["plot_type"];
                if (plot_type.Equals("histogram"))
                    newLabel += (plot_type + " >> " + Request.Params["hist_var"] + " >> ");
                else
                    newLabel += (plot_type + " >> " + Request.Params["x"] + " vs " + Request.Params["y"]);

                newUrl = type + Request.Url.Query + "&source=" + source + "&replot=true";
            }
            else if (type.Equals("byUser"))
            {
                newLabel += "User History >> ";
                newLabel += Request.Params["hostName"];
                if (Request.Params["save"].Equals("false")) return;

                newUrl = "byUser/HostPage/" + source + Request.Url.Query;
            }





            /*shift last saved cookies */
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





            Response.Cookies.Add(new HttpCookie("url0", newUrl));
            Response.Cookies.Add(new HttpCookie("label0", newLabel));
        }

    }
}