using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net;
using System.Web.Script.Serialization;
using System.IO;

namespace dari.Models
{
    public class JSONService
    {
        SEMAService semaService = new SEMAService();
        public string get(string source, string request, Dictionary<string, object> parameters = null)
        {

            string results;
            switch (source)
            {
                case "SEMA":
                    results = semaServer(request, parameters);
                    break;
                case "SEMA2":
                    results = makeExternalRequest("http://localhost:29842/dari_api?", request, parameters);
                    break;
                default:
                    results = null;
                    break;
            }

            return results;
        }

        //simulating SEMA server
        private string semaServer(string request, Dictionary<string, object> parameters = null)
        {
            Object results = null;
            switch (request)
            {
                case "getHostPlatforms":
                    results = semaService.getHostPlatforms();
                    break;

                case "getProductFamilies":
                    results = semaService.getProductFamilies();
                    break;

                case "getHostNames":
                    results = semaService.getHostNames(parameters);
                    break;

                case "getHostInfo":
                    results = semaService.getHostInfo(parameters);
                    break;

                case "getHostData":
                    results = semaService.getHostData(parameters);
                    break;
                    

                    /* for agregate data */
                    /*
                case "getReportDates":
                    results = semaService.getReportDates(parameters);
                    break;

                case "getReportClasses":
                    results = semaService.getReportClasses(parameters);
                    break;

                case "getPlottingData":
                    results = semaService.getPlottingData(parameters);
                    break;
                    */

                /* for advanced analysis*/
                case "correlation":
                    results = semaService.correlation(parameters);
                    break;
                case "getFilterOptions":
                    results = semaService.getFilterOptions();
                    break;


                /* for monthly reporting*/
                case "getAnalysisOptions":
                    results = semaService.getAnalysisOptions(parameters);
                    break;
                case "getAnalysisParams":
                    results = semaService.getAnalysisParams(parameters);
                    break;
                case "getData":
                    results = semaService.getData(parameters);
                    break;
                case "getReportInfo":
                    results = semaService.getReportInfo(parameters);
                    break;

                default:
                    results = null;
                    break;
            }

            string results_str = new JavaScriptSerializer().Serialize(results);
            return results_str;
        }


        private string makeExternalRequest(string address, string request, Dictionary<string, object> parameters)
        {
            string request_params = new JavaScriptSerializer().Serialize(parameters);
            WebRequest webRequest = WebRequest.Create(
              address + "request=" + request + "&parameters=" + request_params);

            WebResponse response = webRequest.GetResponse();

            Stream dataStream = response.GetResponseStream();
            StreamReader reader = new StreamReader(dataStream);
            string responseFromServer = reader.ReadToEnd();

            return responseFromServer;
        }
    }
}