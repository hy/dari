using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;

namespace dari.Controllers
{
    public class AdvancedController : Controller
    {
        //
        // GET: /Advanced/
        JSONService jsonService = new JSONService();

        public ActionResult Index()
        {
            return View("correlation");
        }

        public JsonResult getFilterOptions(string source)
        {
            Object results = jsonService.get(source, "getFilterOptions", null);
            return Json(results, JsonRequestBehavior.AllowGet);
        }

        public JsonResult getCoorelationData(string source, string x, string y, string[] filters)
        {

            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["x"] = x;
            parameters["y"] = y;
            parameters["filters"] = filters;
            foreach (var filter in filters)
            {
                parameters[filter] = Request.Params[filter];
            }

            Object results = jsonService.get(source, "correlation", parameters);

            return Json(results, JsonRequestBehavior.AllowGet);
        }

        public ActionResult correlation()
        {
            return View();
        }


    }
}
