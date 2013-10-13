using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;
using System.Collections;

namespace dari.Controllers
{
    /********* byUser Controller*********
     * This class processes all the requests made for plotting perUser data
     */
    [HighlightLinkFilter(currentSection = "user_history")]
    public class byUserController : DARIController
    {
        /* Index(): This serves the start page for plotting userData- the page facilitates searching for hosts 
         Returns: web page
         */
        public ActionResult Index()
        {
            return View("searchHosts");
        }

        /*This serves the page for featuring all the information about a given host
         * Parameters
         * hostName (required): gives the name of the host to be featured on this page
         * lifetimeIdx: The index of the lifetime to be plotted for this host
         *              The presence of this value, also indicates that the other parameters are present
         * start: the start time that the plot should cover
         * end: the end time the the plot should cover
         * cpus: An array of numbers that indicate which cpus should be plotted
         * os: The operating system where this host is found (for SEMA)
         * 
         * Returns: web page
         */
        public ActionResult HostPage(string hostName, string lifetimeIdx, string start, string end, string[] cpus, string os)
        {
            //all the variables are sent to the browser side so that the relevant actions up to plotting, can be executed through ajax
            ViewData["hostName"] = hostName;
            ViewData["lifetimeIdx"] = lifetimeIdx;
            ViewData["start"] = start;
            ViewData["end"] = end;
            ViewData["cpus"] = cpus;
            ViewData["os"] = os;
            return View("HostPage");
        }


        /* HostPlatforms(): Calls the JSON API to load all the possible host platforms in the database
        * Returns: JSON string
        */
        public DARIjson HostPlatforms(string source)
        {
            return jsonResponse(source, "getHostPlatforms", null);
        }

        /* ProductFamilies(): Calls the JSON API to load all the possible product families in the database
        * Returns: JSON string
        */
        public DARIjson ProductFamilies(string source)
        {
            return jsonResponse(source, "getProductFamilies", null);
        }

        /* getHostNames(): Calls the JSON API to get a list of host names that match the given parameters
         * Parameters (none required except key)
         * hostPlatform: if provided, the returned hosts should have this platform
         * productFamily: if provided, the returned hosts should have this product family
         * os: if provided, the returned hosts should have this operating system
         * key: the results should have names that begin with the letters in this string
         * 
        * Returns: JSON string
        */
        public DARIjson getHostNames(string source, string hostPlatform, string productFamily, string os, string key)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["hostPlatform"] = hostPlatform;
            parameters["productFamily"] = productFamily;
            parameters["os"] = os;
            parameters["key"] = key;

            return jsonResponse(source, "getHostNames", parameters);
        }

        /* getHostInfo(): Calls the JSON API to get all information on all the lifetimes of the given hostname
         * 
        * Returns: JSON string
        */
        public DARIjson getHostInfo(string source, string hostname)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters["hostname"] = hostname;

            return jsonResponse(source, "getHostInfo", parameters);
        }

        /* getHostInfo(): Calls the JSON API to all the data to make a plot based on the given parameters. This query request is also saved
         * with all its parameters so that it can be generated again from a link
         * 
         * Parameters
         * hostName: the host to plot
         * cpu: An array of numbers that indicate which cpus to plot
         * start: the start date for the plot
         * end: the end date for the plot
         * lifetimeIdx: the lifetime that was chosen for the host. This is saved sowhen this request is plotted from a link at a later time, 
         *              the page knows which lifetime was selected
         * save: this is for the "SaveQueryFilter", to know whether or not to save this query. If this is just a zoomin/out of a saved plot,
         *          it will not be saved again
        * Returns: JSON string
        */
        [SaveQueryFilter]
        public DARIjson getHostData(string source, string hostName, string[] cpus, string start, string end, string lifetimeIdx, string save)
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
