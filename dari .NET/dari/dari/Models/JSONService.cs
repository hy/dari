using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net;
using System.Web.Script.Serialization;
using System.IO;
using System.Configuration;

namespace dari.Models
{
    public class JSONService
    {
        SEMAService semaService = new SEMAService();

        /*Routes the request to the relevant data source */
        public string get(string source, string request, Dictionary<string, object> parameters = null)
        {

            string results="";

            foreach (dariDataConnectionElement dataSource in (new DariDataSources().collection))
            {
                if (dataSource.Name.Equals(source))
                {
                    return makeExternalRequest(dataSource.Url, request, parameters);
                }

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
            if (!address.Equals("native"))
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
            else
            {
                return semaServer(request, parameters);
            }
        }
    }

}