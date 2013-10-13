using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dari.Controllers
{
    /*This class controlls all the code that serves general pages for DARI */
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
            
            //Get Saved Queries from the cookies for Display
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

        //Page for browser uncompatibility notification
        public ActionResult UnsupportedBrowser()
        {
            return PartialView("UnsupportedBrowser");
        }

        //This is a request to store the last selected source from the browser
        [HttpPost]
        public void saveSelectedSource(string source_name)
        {

            Response.Cookies.Add(new HttpCookie("last_source", source_name));
            //return new EmptyResult();
        }


    }
}
