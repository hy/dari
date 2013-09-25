using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;

namespace dari.Controllers
{
    [Authorize()]
    [InitializeFilterAttribute]
    public abstract class DARIController : Controller
    {

        private JSONService jsonService = new JSONService();

        public EmptyResult sendString(string reponse_text)
        {
            Response.Write(reponse_text);
            return null;
        }


        public string getJSON(string source, string request, Dictionary<string, object> parameters)
        {
            return jsonService.get(source, request, parameters);
        }


        public EmptyResult jsonResponse(string source, string request, Dictionary<string, object> parameters)
        {
            string results = getJSON(source, request, parameters);
            return sendString(results);
        }


    }

    public class DARIjson : EmptyResult
    {

    }
}
