using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;
using System.Web.Script.Serialization;
using System.Collections;

namespace dari.Controllers
{
    [HighlightLinkFilter(linkName = "monthly_reports_link_class")]
    public class ReportsController : DARIController
    {

        public ActionResult Index()
        {
            return View();
        }

        [SaveQueryFilter]
        public ActionResult Output(string source, string os, string analysis, string classification, string date,
            string[] series, string Analysis_Parameters, string tblPrefix)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;
            parameters["analysis"] = analysis;
            parameters["classification"] = classification;
            parameters["date"] = date;
            parameters["NodeID"] = new ArrayList(series);
            parameters["ParameterName"] = Analysis_Parameters;
            parameters["tablePrefix"] = tblPrefix;

            ViewData["parameters"] = new JavaScriptSerializer().Serialize(parameters);

            ViewData["reportInfo"] = getJSON(source, "getReportInfo", parameters);

            return View();
        }

        public EmptyResult getData(string source, string os, string analysis, string classification, string date,
            string[] NodeID, string ParameterName, string tablePrefix, string format)
        {

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;
            parameters["analysis"] = analysis;
            parameters["classification"] = classification;
            parameters["date"] = date;
            parameters["NodeID"] = new ArrayList(NodeID);
            parameters["ParameterName"] = ParameterName;
            parameters["tablePrefix"] = tablePrefix;
            parameters["format"] = format;

            return jsonResponse(source, "getData", parameters);
        }


        public EmptyResult getAnalysisOptions(string source, string os)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;

            return jsonResponse(source, "getAnalysisOptions", parameters);

        }

        public EmptyResult getAnalysisParams(string source, string os, string analysis, string classification, string Date)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;
            parameters["analysis"] = analysis;
            parameters["classification"] = classification;
            parameters["date"] = Date;

            return jsonResponse(source, "getAnalysisParams", parameters);

        }

    }
}
