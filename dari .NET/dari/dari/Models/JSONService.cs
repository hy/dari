using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace dari.Models
{
    public class JSONService
    {
        SEMAService semaService = new SEMAService();
        public Object get(string source, string request, Dictionary<string, object> parameters = null)
        {

            Object results;
            switch (source)
            {
                case "SEMA":
                    results = semaServer(request, parameters);
                    break;
                default:
                    results = null;
                    break;
            }

            return results;
        }

        //simulating SEMA server
        private Object semaServer(string request, Dictionary<string, object> parameters = null)
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
                    

                    /* for agregate data */
                case "getReportDates":
                    results = semaService.getReportDates(parameters);
                    break;

                case "getReportClasses":
                    results = semaService.getReportClasses(parameters);
                    break;

                case "getPlottingData":
                    results = semaService.getPlottingData(parameters);
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

                default:
                    results = null;
                    break;
            }

            return results;
        }
    }
}