using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dari.Controllers
{
    public class HighlightLinkFilterAttribute : ActionFilterAttribute
    {
        public string linkName { get; set; }

        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            filterContext.Controller.ViewData[this.linkName] = "current_section";

        }


    }
}