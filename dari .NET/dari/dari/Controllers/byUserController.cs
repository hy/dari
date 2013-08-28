using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;

namespace dari.Controllers
{
    //[Authorize(Users = @"AMR\naudegbu, AMR\rfkwasni, AMR\pspolasa, AMR\amrashid")]
    //[Authorize(Users = "naudegbu, rfkwasni, pspolasa, amrashid")]
    [Authorize()]
    public class byUserController : Controller
    {
        //
        // GET: /byUser/
        JSONService jsonService = new JSONService();

        public ActionResult Index()
        {
            return View("searchForHosts");
        }

        public JsonResult HostPlatforms(string source)
        {
            Object results;
            results = jsonService.get(source, "getHostPlatforms");
            return Json(results, JsonRequestBehavior.AllowGet);
        }

        public JsonResult ProductFamilies(string source)
        {
            Object results;
            results = jsonService.get(source, "getProductFamilies");
            return Json(results, JsonRequestBehavior.AllowGet);
        }

        public JsonResult getHostNames(string source, string hostPlatform, string productFamily, string os, string key)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["hostPlatform"] = hostPlatform;
            parameters["productFamily"] = productFamily;
            parameters["os"] = os;
            parameters["key"] = key;

            Object results;
            results = jsonService.get(source, "getHostNames", parameters);
            return Json(results, JsonRequestBehavior.AllowGet);
        }

        public JsonResult getHostInfo(string source, string hostname)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["hostname"] = hostname;

            Object results;
            results = jsonService.get(source, "getHostInfo", parameters);
            return Json(results, JsonRequestBehavior.AllowGet);
        }


        public ActionResult HostInfo(string hostName, string lifetimeIdx, string start, string end, string[] cpus)
        {
            ViewData["hostName"] = hostName;
            ViewData["lifetimeIdx"] = lifetimeIdx;
            ViewData["start"] = start;
            ViewData["end"] = end;
            ViewData["cpus"] = cpus;
            return View("HostInfo");
        }
    }
}
