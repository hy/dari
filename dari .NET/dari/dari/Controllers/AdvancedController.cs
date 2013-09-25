using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;
using System.Web.Script.Serialization;

namespace dari.Controllers
{
    public class AdvancedController : DARIController
    {
        //
        // GET: /Advanced/

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

            ViewData["analytics_link_class"] = "current_section";
            return View("correlation");
        }

        public EmptyResult getFilterOptions(string source)
        {
            //Object results = jsonService.get(source, "getFilterOptions", null);
            //return Json(results, JsonRequestBehavior.AllowGet);
            return jsonResponse(source, "getFilterOptions", null);
        }

        [SaveQueryFilter(newUrlLabel = "Analytics")]
        public EmptyResult getCoorelationData(string source, string x, string y, string hist_var, string plot_type, string[] filters)
        {

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["x"] = x;
            parameters["y"] = y;
            parameters["hist_var"] = hist_var;
            parameters["plot_type"] = plot_type;
            parameters["filters"] = filters;
            foreach (var filter in filters)
            {
                parameters[filter] = Request.Params[filter];
            }

            //Object results = jsonService.get(source, "correlation", parameters);

            //return Json(results, JsonRequestBehavior.AllowGet);
            return jsonResponse(source, "correlation", parameters);
        }

        public ActionResult correlation()
        {
            ViewData["analytics_link_class"] = "current_section";
            return View();
        }


    }
}
