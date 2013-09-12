using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dari.Controllers
{
    [HandleError]
    public class HomeController : Controller
    {
        //[Authorize(Roles = @"FM6SWWW062\DARI_Access")]
        [Authorize()]
        public ActionResult Index()
        {
            //return RedirectToAction("Index", "Summary");

            string label0 = "";
            string url0 = "";
            if (Request.Cookies["label0"] != null)
                label0 = Request.Cookies["label0"].Value;
            if (Request.Cookies["url0"] != null)
                url0 = Request.Cookies["url0"].Value;


            ViewData["notSupported"] = (Request.Browser.Browser.Equals("IE") && Convert.ToDecimal(Request.Browser.Version) < 9);
            
            ViewData["recentPlot"] = "<a  href='/Plot/SummaryPlot/?" + url0 + "'>" + label0 + "</a>";

            string label;
            string url;
            string recentPlotsHTML = "";
            for (int i = 0; i < 10; i++)
            {
                label = "";
                url = "";

                if (Request.Cookies["label" + i] != null)
                    label = Request.Cookies["label" + i].Value;
                if (Request.Cookies["url" + i] != null)
                    url = Request.Cookies["url" + i].Value;

                //recentPlotsHTML += ("<a  href='/Plot/SummaryPlot/?" + url + "'>" + label + "</a><br />");
                recentPlotsHTML += ("<a  href='" + url + "'>" + label + "</a><br />");

            }
            ViewData["recentPlots"] = recentPlotsHTML;

            return View();
            //return PartialView("Home");


        }

        public ActionResult About()
        {
            return View();
        }


    }
}
