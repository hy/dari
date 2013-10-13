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
    
    /********* Reports Controller*********
     * This class processes all the requests made for monthly reports
     */
    [HighlightLinkFilter(currentSection = "monthly_reports")]
    public class ReportsController : DARIController
    {
        // Serves the page that allows the user to select parameters for the report
        public ActionResult Index()
        {
            return View("ReportOptions");
        }

        /*This serves the page that displays the desired report based on the given parameters.
         * The paramters are packed and sent to the client side, which then uses thme to make ajax requests to retreive the data
         * This request is also saved
         * 
        * Parameters
        * os: (for SEMA) used to find the data, and also displayed
         * analyisi:  report parameter
         * classfication: to get the data from the database
         * date:  to get the date of the report and to display
         * series: the list of classes being plotted
         * Analysis_Parameters a report paramter, that's also displayed
         * tblPrefix: (for SEMA), to find the data in the database
         * series_name: the list of the names of the classes being plotted
         * classification_name: the name of the classification for display
        * 
        * Returns: web page
        */
        [SaveQueryFilter]
        public ActionResult Output(string source, string os, string analysis, string classification, string date,
            string[] series, string Analysis_Parameters, string tblPrefix, string[] series_name, string classification_name)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;
            parameters["analysis"] = analysis;
            parameters["classification"] = classification;
            parameters["classification_name"] = classification_name;
            parameters["date"] = date;
            parameters["NodeID"] = new ArrayList(series);
            parameters["ParameterName"] = Analysis_Parameters;
            parameters["tablePrefix"] = tblPrefix;
            parameters["series_names"] = new ArrayList(series_name);

            ViewData["parameters"] = new JavaScriptSerializer().Serialize(parameters);

            return View("ReportDisplay");
        }


        /* getData(...): This gets the data that is used to make the report plot.
         * 
        * Parameters
        * os: (for SEMA) used to find the data, and also displayed
         * analyisi:  report parameter
         * classfication: to get the data from the database
         * date:  to get the date of the report and to display
         * NodeID: the list of classes being plotted
         * tblPrefix: (for SEMA), to find the data in the database
         * format: string to say which type of report to make- "histogram", "probPlot", or "basicStats"
        * 
        * Returns: JSON string
        */
        public DARIjson getData(string source, string os, string analysis, string classification, string date,
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

        /* getAnalysisOptions(): This retrieves all the possible options for analysis. Options are here, are used to 
         * retreive the second set of possible options.
         * 
         * Returns: JSON string 
         */
        public DARIjson getAnalysisOptions(string source, string os)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["os"] = os;

            return jsonResponse(source, "getAnalysisOptions", parameters);

        }

        /* getAnalysisOptions(): This retrieves the rest of the possible options, based on the given parameters.
        * 
        * Returns: JSON string 
        */
        public DARIjson getAnalysisParams(string source, string os, string analysis, string classification, string Date)
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
