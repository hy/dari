using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dari.Controllers
{
    /*This Filter is used to color the link in the navigation menu, for the releavant section
     * depending on which controller is active */
    public class HighlightLinkFilterAttribute : ActionFilterAttribute
    {
        public string currentSection { get; set; }

        //Sets the relevant element class
        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            filterContext.Controller.ViewData[this.currentSection + "_link_class"] = "current_section";

        }


    }
}