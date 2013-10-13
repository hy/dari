using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;
using System.Web.Script.Serialization;

namespace dari.Controllers
{
    /*
     * ADVANCED Controller:
     * This Implements the code that controlls the the "Analytics" section of DARI.
     * All variables are strings or arrays of strings
     */
    [HighlightLinkFilter(currentSection = "analytics")]
    public class AdvancedController : DARIController
    {
        /* Index(): This is the default action. It can take none or all of the paramters
         * If it has no paramters, it will simply take the user to a blank Analytics page, to  start 
         * a new analysis from scratch.
         * If it does have parameters, the "replot" paramter will be true, and thus this function, will exctract 
         * all the paramters and meeded to remake the plot:
         * 
         * Parameters
         * replot: A variable that if empty, says there are no params, otherwise, there are
         * plot_type: The type of plot generated ("histogram" or "correlation")
         * x: The x axis variable (for correlation plots. Will be empty if plot_type is histogram)
         * y: The y axis variable (for correlation plots. Will be empty if plot_type is histogram)
         * hist_var: The continuous variable (for histograms. Will be empnty of plot_type is correlation)
         * filters: An array of names of the filters
         * 
         * For each filter name found in filters[], there will be an additonal paramater found in the query string,
         * with that name
         * 
         * Returns: web page
         */
        public ActionResult Index(string source, string x, string y, string hist_var, string plot_type, string[] filters, string replot)
        {
            if (replot != null)
            {
                Dictionary<string, object> parameters = new Dictionary<string, object>();
                parameters["x"] = x;
                parameters["y"] = y;
                parameters["hist_var"] = hist_var;
                parameters["plot_type"] = plot_type;
                parameters["filters"] = filters;

                //retrieve all filters listed in the query string, by their name
                foreach (var filter in filters)
                {
                    parameters[filter] = Request.Params[filter];
                }

                ViewData["parameters"] = new JavaScriptSerializer().Serialize(parameters);
            }
            else
            {
                ViewData["parameters"] = "null";
            }
            return View("Analytics");
        }


        /* getFilterOptions(): Calls the JSON API to load the interface with all the possible
         * with the options for filtering
         * Returns: JSON string
         */
        public DARIjson getFilterOptions(string source)
        {
            return jsonResponse(source, "getFilterOptions", null);
        }

        /* getFilteredPlottingData(): Calls the JSON API to get the data used to make the desired plot
         * Returns: JSON string
         */
        [SaveQueryFilter]
        public DARIjson getFilteredPlottingData(string source, string x, string y, string hist_var, string plot_type, string[] filters)
        {

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["x"] = x;
            parameters["y"] = y;
            parameters["hist_var"] = hist_var;
            parameters["plot_type"] = plot_type;
            parameters["filters"] = filters;

            //retrieve all filters listed in the query string, by their name
            foreach (var filter in filters)
            {
                parameters[filter] = Request.Params[filter];
            }

            return jsonResponse(source, "getFilteredPlottingData", parameters);
        }



    }
}
