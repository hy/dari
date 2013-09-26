using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dari.Controllers
{
    [HandleError]
    [InitializeFilter]
    public class HomeController : Controller
    {
        // Front Page
        public ActionResult Index()
        {
            string label;
            string url;
            string recentPlotsHTML = "";
            bool hasNoRecentPlots = true; ;
            
            //Get Saved Queries for Display
            for (int i = 0; i < 10; i++)
            {
                label = "";
                url = "";

                if (Request.Cookies["label" + i] != null)
                    label = Request.Cookies["label" + i].Value;
                if (Request.Cookies["url" + i] != null)
                    url = Request.Cookies["url" + i].Value;

                if (url.Length > 0 && label.Length > 0)
                {
                    hasNoRecentPlots = false;
                    recentPlotsHTML += ("<a  href='" + url + "'>" + label + "</a><br />");
                }
            }
            if (hasNoRecentPlots)
                recentPlotsHTML = "You have no recent plots. Click the buttons above, to begin making custom plots for reporting and analysis";
            ViewData["recentPlots"] = recentPlotsHTML;

            return View();

        }

        public ActionResult UnsupportedBrowser()
        {
            return PartialView("UnsupportedBrowser");
        }


        [HttpPost]
        public ActionResult saveSelectedSource(string source_name)
        {

            Response.Cookies.Add(new HttpCookie("last_source", source_name));
            return new EmptyResult();
        }


    }
}
