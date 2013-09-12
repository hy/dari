using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;
using System.Web.Script.Serialization;

namespace dari.Controllers
{
    public class SummaryController : Controller
    {
        //
        // GET: /Summary/
        JSONService jsonService = new JSONService();

        private void saveQuery(string newUrlLabel, string newURL)
        {
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


            Response.Cookies.Add(new HttpCookie("url0", newURL));
            Response.Cookies.Add(new HttpCookie("label0", newUrlLabel));
        }

        public ActionResult Index()
        {
            return View("SummaryUI");
        }

        public JsonResult getReportDates(string source, string analysis, string os)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["analysis"] = analysis;
            parameters["os"] = os;

            Object results = jsonService.get(source, "getReportDates", parameters);
            return Json(results, JsonRequestBehavior.AllowGet);

        }

        public JsonResult getReportClasses(string source, string analysis, string os, string Classification, string time)
        {
            
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["analysis"] = analysis;
            parameters["os"] = os;
            parameters["classification"] = Classification;
            parameters["time"] = time;

            Object results = jsonService.get(source, "getReportClasses", parameters);
            return Json(results, JsonRequestBehavior.AllowGet);

        }

        [HttpPost]
        [SaveQueryFilter(newUrlLabel = "SEMA :: User History >> ")]
        public ActionResult plotData(string source, string analysis, string os, string classification, string Date, string Analysis_Parameters, string[] series)
        {
            //saveQuery("SEMA :: Summary >> " + analysis + " >> " + Date + " >> {" + string.Join(",", series) + "}", "Plot/SummaryPlot/?" + Request.Form.ToString());
            return executePlotData(source,analysis,os,classification,Date,Analysis_Parameters,series);
        }

        [HttpGet]
        public ActionResult plotDataSaved(string source, string analysis, string os, string classification, string Date, string Analysis_Parameters, string[] series)
        {
            return executePlotData(source, analysis, os, classification, Date, Analysis_Parameters, series);
        }

        private ActionResult executePlotData(string source, string analysis, string os, string classification, string Date, string Analysis_Parameters, string[] series)
        {

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["analysis"] = analysis;
            parameters["os"] = os;
            parameters["classification"] = classification;
            parameters["time"] = Date;
            parameters["className"] = series;
            parameters["variable"] = Analysis_Parameters;

            ViewData["parameters"] = new JavaScriptSerializer().Serialize(parameters);
            ViewData["analysis"] = analysis;
            ViewData["os"] = os;
            ViewData["classification"] = classification;
            ViewData["variable"] = Analysis_Parameters;

            System.DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            ViewData["date"] = dtDateTime.AddSeconds(Convert.ToInt32(Date)).ToString();

            //saveQuery("SEMA :: Summary >> " + Analysis + " >> " + date + " >> {" + string.Join(",", series) + "}", "Plot/SummaryPlot/?" + Request.Form.ToString());
            ViewData["newLabel"] = source + " :: Summary >> " + analysis + " >> " + ViewData["date"] + " >> {" + series + "}";
            ViewData["newURL"] = "Summary/plotDataSaved/?" + Request.Form.ToString();

            ViewData["series"] = new JavaScriptSerializer().Serialize(series);

            return View("Plotter");
        }

        public JsonResult getPlottingData(string source, string analysis, string os, string classification, string time, string variable, string [] className)
        {

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["analysis"] = analysis;
            parameters["os"] = os;
            parameters["classification"] = classification;
            parameters["time"] = time;
            parameters["className"] = className;
            parameters["variable"] = variable;

            Object results = jsonService.get(source, "getPlottingData", parameters);

            return Json(results, JsonRequestBehavior.AllowGet);
        }


    }
}
