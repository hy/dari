using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;
using System.Collections;

namespace dari.Controllers
{
    public class byUserController : DARIController
    {

        public ActionResult Index()
        {
            ViewData["user_history_link_class"] = "current_section";
            return View("searchHosts");
        }

        public ActionResult HostPage(string hostName, string lifetimeIdx, string start, string end, string[] cpus, string os)
        {
            ViewData["user_history_link_class"] = "current_section";


            ViewData["hostName"] = hostName;
            ViewData["lifetimeIdx"] = lifetimeIdx;
            ViewData["start"] = start;
            ViewData["end"] = end;
            ViewData["cpus"] = cpus;
            ViewData["os"] = os;
            return View("HostPage");
        }

        public EmptyResult HostPlatforms(string source)
        {
            return jsonResponse(source, "getHostPlatforms", null);
        }

        public EmptyResult ProductFamilies(string source)
        {
            return jsonResponse(source, "getProductFamilies", null);
        }

        public EmptyResult getHostNames(string source, string hostPlatform, string productFamily, string os, string key)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["hostPlatform"] = hostPlatform;
            parameters["productFamily"] = productFamily;
            parameters["os"] = os;
            parameters["key"] = key;

            return jsonResponse(source, "getHostNames", parameters);
        }

        public EmptyResult getHostInfo(string source, string hostname)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["hostname"] = hostname;

            return jsonResponse(source, "getHostInfo", parameters);
        }

        [SaveQueryFilter]
        public EmptyResult getHostData(string source, string hostName, string[] cpus, string start, string end, string lifetimeIdx, string save)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["hostName"] = hostName;
            parameters["cpus"] = new ArrayList(cpus);
            parameters["start"] = start;
            parameters["end"] = end;
            parameters["lifetimeIdx"] = lifetimeIdx;

            return jsonResponse(source, "getHostData", parameters);

        }
    }
}
