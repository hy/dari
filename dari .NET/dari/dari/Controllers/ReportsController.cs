using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;
using System.Web.Script.Serialization;

namespace dari.Controllers
{
    [Authorize()]
    [InitializeFilterAttribute]
    public class ReportsController : Controller
    {


        JSONService jsonService = new JSONService();

        public ActionResult Index()
        {
            ViewData["monthly_reports_link_class"] = "current_section";
            return View();
        }

        //TODO: save this query
        public ActionResult Output(string source, string os, string analysis, string classification, string date,
            string[] series, string Analysis_Parameters, string tblPrefix)
        {
            ViewData["monthly_reports_link_class"] = "current_section";

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;
            parameters["analysis"] = analysis;
            parameters["classification"] = classification;
            parameters["date"] = date;
            parameters["NodeID"] = series;
            parameters["ParameterName"] = Analysis_Parameters;
            parameters["tablePrefix"] = tblPrefix;

            ViewData["parameters"] = new JavaScriptSerializer().Serialize(parameters);

            return View();
        }

        public JsonResult getData(string source, string os, string analysis, string classification, string date,
            string[] NodeID, string ParameterName, string tablePrefix, string format)
        {
            ViewData["monthly_reports_link_class"] = "current_section";

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;
            parameters["analysis"] = analysis;
            parameters["classification"] = classification;
            parameters["date"] = date;
            parameters["NodeID"] = NodeID;
            parameters["ParameterName"] = ParameterName;
            parameters["tablePrefix"] = tablePrefix;
            parameters["format"] = format;

            Object results = jsonService.get(source, "getData", parameters);

            return Json(results, JsonRequestBehavior.AllowGet);
        }


        public JsonResult getAnalysisOptions(string source, string os)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;

            Object results = jsonService.get(source, "getAnalysisOptions", parameters);
            return Json(results, JsonRequestBehavior.AllowGet);

        }

        public JsonResult getAnalysisParams(string source, string os, string analysis, string classification, string Date)
        {

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;
            parameters["analysis"] = analysis;
            parameters["classification"] = classification;
            parameters["date"] = Date;

            Object results = jsonService.get(source, "getAnalysisParams", parameters);
            return Json(results, JsonRequestBehavior.AllowGet);

        }

    }
}
