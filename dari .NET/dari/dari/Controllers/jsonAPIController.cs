using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;


namespace dari.Controllers
{
    public class jsonAPIController : Controller
    {
        //
        // GET: /jsonAPI/
        SEMAService semaService = new SEMAService();

        public ActionResult Index()
        {
            return View();
        }


        public JsonResult HostPlatforms(string id)
        {
            Object results;
            if (id=="SEMA")
                results = semaService.getHostPlatforms();
            else
                results = null;
            return Json(results, JsonRequestBehavior.AllowGet);
        }

    }
}
