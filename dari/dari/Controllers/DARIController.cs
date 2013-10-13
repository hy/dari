using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dari.Models;

namespace dari.Controllers
{
    /* This is the parent class for all the controllers 
     * 
     * It defines special functions that allow for DARI's features
     * 
     * 
     * All of the actions take strings or arrays of strings as parameters.
     * Almost all of the actions take a string called "source" as a parameter.
     * 
     * The "Authorize" filter ensures that user must be authorized to access these features
     * The "Initilize" filter ensures that the browser will be checked for compatibility, and that the current source
     * will be managed and updated appropriately
     */
    [Authorize()]
    [InitializeFilterAttribute]
    public abstract class DARIController : Controller
    {
        //intilize the class that allows requests to the external data source
        private JSONService jsonService = new JSONService();


        //makes the request and serves the result
        public DARIjson jsonResponse(string source, string request, Dictionary<string, object> parameters)
        {
            string results = jsonService.get(source, request, parameters);
            Response.Write(results);
            return null;
        }


    }


    /* Defined as the type retuned for actions that serve json requests, and return them in a format specified by DARI */
    public class DARIjson : EmptyResult
    {

    }
}
