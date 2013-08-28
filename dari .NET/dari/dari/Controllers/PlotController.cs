using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace dari.Controllers
{
    //[Authorize(Users = "naudegbu, rfkwasni, pspolasa, amrashid")]
    [Authorize()]
    public class PlotController : Controller
    {
        //
        // GET: /Plot/
        // old server FM6VSQL041,3180;
        //new server: FM6SSQL049, 3180 

        string connectionString = "user id=username;" +
                                       "password=password;server=FM6SSQL049,3180;" +
                                       "Trusted_Connection=yes;" +
                                       "database=emma_v5_db; " +
                                       "connection timeout=30";

        public ActionResult Index()
        {
            return View();
        }

        private void processPlotQuery(string timeStamp, string os, string Analysis, string[] series)
        {

            DateTime epoch = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            String date = epoch.AddSeconds(Convert.ToInt32(timeStamp)).ToLocalTime().ToShortDateString();
            saveQuery("SEMA :: Summary >> " + Analysis + " >> " + date + " >> {" + string.Join(",", series) + "}", "Plot/SummaryPlot/?" + Request.Form.ToString());

            SqlConnection myConnection = new SqlConnection(connectionString);

            List<string> classes = new List<string>();
            //add up to 3 classes for plotting
            for (int j = 0; j < Math.Min(series.Length, 3); j++)
            {
                classes.Add(series[j]);
            }

            List<Object> results = new List<Object>();
            List<Object> arrays = new List<Object>();
            List<Object> array_info = new List<Object>();


            try
            {
                myConnection.Open();

                classes.ForEach(delegate(String name)
                {
                    var result = MakeQuery(myConnection, timeStamp, Analysis, name, os);
                    arrays.Add(result.Item1);
                    array_info.Add(result.Item2);
                });

                myConnection.Close();

                var return_data = new
                {
                    arrays = arrays,
                    series_names = classes,
                    max = 100,
                    min = 0,
                    array_info = array_info
                };

                var json = new JavaScriptSerializer().Serialize(return_data);
                Console.WriteLine(json);
                ViewData["result"] = json;
                ViewData["analysis"] = Analysis;
                ViewData["os"] = os;
                ViewData["classification"] = "By Platform";

                System.DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
                ViewData["date"] = dtDateTime.AddSeconds(Convert.ToInt32(timeStamp)).ToString();

            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                Response.Write("<h1>Error:</h1><pre style='color: green;'>" + e.ToString() + "</pre>");
            }
        }

        public ActionResult SummaryPlot(string id, string Date, string os, string Analysis, string[] series)
        {
            processPlotQuery(Date, os, Analysis, series);
            return PartialView("Blank");
        }

        private void saveQuery(string newUrlLabel, string newURL)
        {
            string label;
            string url;
            for (int i = 0; i < 10; i++)
            {
                label = "";
                url = "";

                if (Request.Cookies["label" + i] != null)
                    label = Request.Cookies["label" + i].Value;
                if (Request.Cookies["url" + i] != null)
                    url = Request.Cookies["url" + i].Value;

                Response.Cookies.Add(new HttpCookie("url" + (i + 1), url));
                Response.Cookies.Add(new HttpCookie("label" + (i + 1), label));
            }


            Response.Cookies.Add(new HttpCookie("url0", newURL));
            Response.Cookies.Add(new HttpCookie("label0", newUrlLabel));
        }

        [HttpPost]
        public ActionResult Test(string id, string[] series, FormCollection formCollection)
        {

            string timeStamp = formCollection["Date"];
            string os = formCollection["Os"];
            string Analysis = formCollection["Analysis"];




            processPlotQuery(timeStamp, os, Analysis, series);

            return PartialView("Blank");
        }

        double perc(List<double> list, int key){
            var res = list[(int) (key * list.Count/100)];
            return res;
        }

        private Tuple<List<double>, Object> MakeQuery(SqlConnection myConnection, string timestamp, string analysis, string hostplatform, string os)
        {
            var table = "[Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable";
            var fieldname = "*";
            var timefieldName = "";
            switch (analysis)
            {
                case "Host Uptime and downtime periods":
                    table = "Summary_DowntimePerCPUPrimaryHostIndex";
                    fieldname = "NumDown";
                    timefieldName = "AnalysisTime";
                    break;
                case "Host Memory Utilization":
                    table = "Summary_MemUtilPerCPUMemPrimaryHostIndex";
                    fieldname = "AvgMemUtil";
                    timefieldName = "AnalysisTimestamp";
                    break;
            }

            switch (os)
            {
                case "Windows":
                    table += "_WINtable";
                    break;
                case "Linux":
                    table += "_LINtable";
                    break;
            }




            string query = "SELECT [" + fieldname + "] FROM [emma_v5_db].[dbo].[" + table + "]  where ([" + timefieldName + "] = " + timestamp + ") and ([" + fieldname + "]>-1)";
            string seriesName = "All";
            if (hostplatform != "ALL")
            {
                query += "and ([HostPlatform]='" + hostplatform + "')";
                seriesName = hostplatform;
            }

            return execQuery(myConnection, query, seriesName);
        }


        private Tuple<List<double>, Object> MemUtil(SqlConnection myConnection, string timestamp, string hostplatform)
        {
            string query = "SELECT [AvgMemUtil] FROM [emma_v5_db].[dbo].[Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable]  where ([AnalysisTimestamp] = " + timestamp + ") and ([AvgMemUtil]>-1)";
            string seriesName = "All";
            if (hostplatform != "ALL")
            {
                query += "and ([HostPlatform]='" + hostplatform + "')";
                seriesName = hostplatform;
            }

            return execQuery(myConnection, query, seriesName);
        }

        private Tuple<List<double>, Object> Downtime(SqlConnection myConnection, string timestamp, string hostplatform)
        {
            string query = "SELECT [NumDown]  FROM [emma_v5_db].[dbo].[Summary_DowntimePerCPUPrimaryHostIndex_LINtable] WHERE AnalysisTime=" + timestamp;
            string seriesName = "All";
            if (hostplatform != "ALL")
            {
                query += "and ([HostPlatform]='" + hostplatform + "')";
                seriesName = hostplatform;
            }

            return execQuery(myConnection, query, seriesName);
        }

        private Tuple<List<double>, Object> execQuery(SqlConnection myConnection, string query, string seriesName)
        {
            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();
            double sum = 0;
            double datum;

            List<double> data = new List<double>();

            while (myReader.Read())
            {
                try
                {
                    datum = (double)myReader[0];
                }
                catch
                {
                    try
                    {
                        datum = (double)((int)myReader[0]);
                    }
                    catch(Exception e)
                    {
                        datum = 0.0;
                    }
                }
                data.Add(datum);
                sum += datum;
            }

            List<double> sampled_data = new List<double>();
            var cnt = 0;
            var sampling_rate = data.Count / 1000 + 1;
            data.ForEach(delegate(double val)
            {
                if (((cnt++) % sampling_rate) == 0)
                {
                    sampled_data.Add(val);

                }
            });

            data.Sort();

            var obj = new
            {
                name = seriesName,
                p1 = perc(data, 1),
                p5 = perc(data, 5),
                p10 = perc(data, 10),
                p20 = perc(data, 20),
                p80 = perc(data, 80),
                p90 = perc(data, 90),
                p95 = perc(data, 95),
                p99 = perc(data, 99),
                median = perc(data, 50),
                mean = Math.Round(sum / data.Count, 2),
                min = data[0],
                max = data[data.Count - 1],
                count = data.Count
            };

            myReader.Close();
            return new Tuple<List<double>, Object>(sampled_data, obj);
        }

        public JsonResult options(string analysis, string param, string time)
        {
            /*SqlConnection myConnection = new SqlConnection("user id=username;" +
                                       "password=password;server=FM6VSQL041,3180;" +
                                       "Trusted_Connection=yes;" +
                                       "database=emma_v5_db; " +
                                       "connection timeout=30"); */

            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            var table = "";
            var field = "";
            var timefieldName = "";
            if (analysis == "Host Memory Utilization")
            {
                table = "Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable";
                timefieldName = "AnalysisTimestamp";
            }
            else
            {
                table = "Summary_DowntimePerCPUPrimaryHostIndex_LINtable";
                timefieldName = "AnalysisTime";
            }

            if (param == "HOSTPLATFORM")
                field = "HostPlatform";
            else
                field = timefieldName;

            var query = "SELECT distinct ["+field+"] FROM [emma_v5_db].[dbo].[" + table + "]";
            if (time != null)
                query += " where (" + timefieldName+"="+time+")";

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<object> data = new List<object>();

            while (myReader.Read()){
                data.Add((object)myReader[0]);
            }
            myConnection.Close();

            return Json(data, JsonRequestBehavior.AllowGet);
        }

        
        public ActionResult line(string id)
        {

            //manageCookies("SEMA :: User History >> " + id + " >> ");

            ViewData["host"]=id;
            return PartialView("LineGraph");
        }

        public JsonResult lineData(string hostName, string[] cpus, string start, string end, string lifetimeIdx)
        {

            if (lifetimeIdx != null)
            {
                DateTime epoch = new DateTime(1970, 1, 1, 0, 0, 0, 0);
                string birthString = epoch.AddSeconds(Convert.ToInt32(start)).ToLocalTime().ToString("MMMM d, yyyy");
                string deathString = epoch.AddSeconds(Convert.ToInt32(end)).ToLocalTime().ToString("MMMM d, yyyy");
                string interval = birthString + "- " + deathString;
                saveQuery("SEMA :: User History >> " + hostName + " >> " + interval, "byUser/HostInfo" + Request.Url.Query);
            }

            SqlConnection myConnection = new SqlConnection(connectionString);

            myConnection.Open();

            var query = "SELECT * FROM [LINemma_v5_db_MsrOtherHistory].[dbo].[MsrOtherHistory_" + hostName + "_LINtable]   where (Timestamp > " + start + ") and (Timestamp < " + end + ") and (MSRname='IA32_THERM_STATUS')";

            query += " and (";
            foreach (string cpuNum in cpus)
            {
                query += "(CPUNum=" + cpuNum + ") or ";
            }
            query += "(1=0) ) order by Timestamp";

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<object> data = new List<object>();

            object obj;
            long timestamp;

            var resolution = 1000;
            var range = Convert.ToInt64(end) -  Convert.ToInt64(start);
            var sampling = range / resolution;

            var limit = Convert.ToInt64(start);

            while (myReader.Read())
            {
                
                var msr_val = (long)myReader["MSRVal"];
                int valid = (int)((msr_val >> 31) & 0x1);
                timestamp = (long)myReader["Timestamp"];

                if (timestamp > limit)
                {

                    if (valid == 1)
                    {
                        //limit += sampling;
                        limit = timestamp + sampling; 

                        obj = new
                        {
                            timestamp = timestamp,
                            value = 105 - (int)((msr_val >> 16) & 0x7F),
                            cpu = (long)myReader["CPUNum"]
                        };
                        data.Add(obj);
                    }
                }
            }
            myConnection.Close();
            return Json(data, JsonRequestBehavior.AllowGet);
        }



        public JsonResult getHostNames(string searchKey)
        {
            //SqlConnection myConnection = new SqlConnection("user id=username;" +
            //                           "password=password;server=FM6VSQL041,3180;" +
            //                           "Trusted_Connection=yes;" +
            //                           "database=emma_v5_db; " +
            //                           "connection timeout=30");
            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            var query = "SELECT distinct[Hostname] FROM [emma_v5_db].[dbo].[HostLifetime_LINtable] where Hostname like '" + searchKey + "%'";

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<object> data = new List<object>();

            while (myReader.Read())
            {
                data.Add(myReader[0]);
            }
            myConnection.Close();
            return Json(data, JsonRequestBehavior.AllowGet);
        }


        public JsonResult getHostLifeInfo(string host)
        {
            //SqlConnection myConnection = new SqlConnection("user id=username;" +
            //                           "password=password;server=FM6VSQL041,3180;" +
            //                           "Trusted_Connection=yes;" +
            //                           "database=emma_v5_db; " +
            //                           "connection timeout=30");

            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            var query = @"SELECT[Hostname]
      ,[Birthtime]
      ,[Deathtime]
      ,[HostLifetime_LINtable].[HostIndex]
      ,[NumLogical]
  FROM [emma_v5_db].[dbo].[HostLifetime_LINtable], [emma_v5_db].[dbo].[HostDetails_LINtable]
where ([HostLifetime_LINtable].Hostname = '" + host + @"')
and ([HostLifetime_LINtable].HostIndex = [HostDetails_LINtable].HostIndex)";

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<object> data = new List<object>();

            object obj;

            while (myReader.Read())
            {
                obj = new
                {
                    Birthtime = (long)myReader["Birthtime"],
                    Deathtime = (long)myReader["Deathtime"],
                    cpus = (long)myReader["NumLogical"]
                };
                data.Add(obj);
            }
            myConnection.Close();
            return Json(data, JsonRequestBehavior.AllowGet);
        }


        //public ActionResult ThermStats(/*string[] cpus,*/ string id, string[] series, FormCollection formCollection)
        public ActionResult ThermStats(string host, string start, string end)
        {
            //SqlConnection myConnection = new SqlConnection("user id=username;" +
            //                           "password=password;server=FM6VSQL041,3180;" +
            //                           "Trusted_Connection=yes;" +
            //                           "database=emma_v5_db; " +
            //                           "connection timeout=30");

            SqlConnection myConnection = new SqlConnection(connectionString);

            List<string> classes = new List<string> {host};
            /*
            for (int j = 0; j < Math.Min(series.Length, 3); j++)
            {
                classes.Add(series[j]);
            }
            */
            List<Object> results = new List<Object>();

            List<Object> arrays = new List<Object>();
            List<Object> array_info = new List<Object>();

            try
            {
                myConnection.Open();

                classes.ForEach(delegate(String name)
                {
                    var result = LiveDataQuery(myConnection, host, start, end);
                    arrays.Add(result.Item1);
                    array_info.Add(result.Item2);
                });

                myConnection.Close();

                var return_data = new
                {
                    arrays = arrays,
                    series_names = classes,
                    max = 100,
                    min = 0,
                    array_info = array_info
                };

                var json = new JavaScriptSerializer().Serialize(return_data);
                Console.WriteLine(json);
                ViewData["result"] = json;
                //ViewData["analysis"] = Analysis;
                //ViewData["os"] = os;
                //ViewData["classification"] = "By Platform";

                System.DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
                //ViewData["date"] = dtDateTime.AddSeconds(Convert.ToInt32(timeStamp)).ToString();
                
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                Response.Write("<h1>Error:</h1><pre style='color: green;'>" + e.ToString() + "</pre>");
            }

            return PartialView("Blank");
        }


        private Tuple<List<double>, Object> LiveDataQuery(SqlConnection myConnection, string host, string start, string end)
        {
            List<string> cpus = new List<string>() {"1"};

            var query = "SELECT * FROM [LINemma_v5_db_MsrOtherHistory].[dbo].[MsrOtherHistory_" + host + "_LINtable]   where (Timestamp > " + start + ") and (Timestamp < " + end + ") and (MSRname='IA32_THERM_STATUS')";

            query += " and (";
            foreach (string cpuNum in cpus)
            {
                query += "(CPUNum=" + cpuNum + ") or ";
            }
            query += "(1=0) ) order by Timestamp";


            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();
            double sum = 0;
            double datum;
            long timestamp;

            var resolution = 1000;
            var range = Convert.ToInt64(end) - Convert.ToInt64(start);
            var sampling = range / resolution;
            var limit = Convert.ToInt64(start);

            List<double> data = new List<double>();

            while (myReader.Read())
            {

                var msr_val = (long)myReader["MSRVal"];
                int valid = (int)((msr_val >> 31) & 0x1);
                int value = 105 - (int)((msr_val >> 16) & 0x7F);
                timestamp = (long)myReader["Timestamp"];

                if (timestamp > limit)
                {

                    if (valid == 1)
                    {
                        limit = timestamp + sampling;

                        data.Add(value);
                        sum += value;
                    }
                }

            }


            data.Sort();

            var obj = new
            {
                name = host,
                p1 = perc(data, 1),
                p5 = perc(data, 5),
                p10 = perc(data, 10),
                p20 = perc(data, 20),
                p80 = perc(data, 80),
                p90 = perc(data, 90),
                p95 = perc(data, 95),
                p99 = perc(data, 99),
                median = perc(data, 50),
                mean = Math.Round(sum / data.Count, 2),
                min = data[0],
                max = data[data.Count - 1],
                count = data.Count
            };

            myReader.Close();
            return new Tuple<List<double>, Object>(data, obj);
        }




        public ActionResult PrintHosts()
        {
            //SqlConnection myConnection = new SqlConnection("user id=username;" +
            //                           "password=password;server=FM6VSQL041,3180;" +
            //                           "Trusted_Connection=yes;" +
            //                           "database=emma_v5_db; " +
            //                           "connection timeout=30");
        
            //SqlConnection myConnection2 = new SqlConnection("user id=username;" +
            //                           "password=password;server=FM6VSQL041,3180;" +
            //                           "Trusted_Connection=yes;" +
            //                           "database=emma_v5_db; " +
            //                           "connection timeout=30");

            SqlConnection myConnection = new SqlConnection(connectionString);
            SqlConnection myConnection2 = new SqlConnection(connectionString);

            string hostIndex = null;
            string hostName = null;
            string product = null;
            double averageTemp;

            List<double> Prescott = new List<double>();
            List<double> Penryn = new List<double>();
            double Prescott_sum=0;
            double Penryn_sum=0;


            object[] series_names = new object[] { "Prescott", "Penryn" };
            List<Object> array_info = new List<Object>();
            List<Object> arrays = new List<Object>();


            Response.Write("<pre>");
            Response.Write("hostname, hostIndex, product, meanTemp\n");

            try
            {
                myConnection.Open();
                myConnection2.Open();


                foreach (string productName in series_names)
                {
                    double product_sum_of_means = 0;
                    List<double> data = new List<double>();

                    var hostQuery = @"SELECT TOP 500 [Hostname]
      ,[Birthtime]
            ,[Deathtime]
                 ,[HostLifetime_LINtable].[HostIndex]
                      ,[HostDetails_LINtable].[NumLogical],
      [Product],
      [ProductFamily], CPUNum
                        FROM [emma_v5_db].[dbo].[HostLifetime_LINtable], [emma_v5_db].[dbo].[HostDetails_LINtable], [emma_v5_db].[dbo].[CPUMemPrimaryCPUMemInfoProcessed_LINtable]
                        where CPUNum=1
                        and ([HostLifetime_LINtable].Hostname not like '%[.]%') 
                        and ([HostLifetime_LINtable].Hostname != '(none)')
                        and (Product = '"+productName+@"') 
                        and ([HostLifetime_LINtable].HostIndex = [CPUMemPrimaryCPUMemInfoProcessed_LINtable].CPUPrimaryHostIndex)
                        and ([HostLifetime_LINtable].HostIndex = [HostDetails_LINtable].HostIndex)";

                    SqlCommand listHostsCommand = new SqlCommand(hostQuery, myConnection);
                    SqlDataReader hostsReader = listHostsCommand.ExecuteReader();


                    while (hostsReader.Read())
                    {

                        hostName = (string)hostsReader["Hostname"];
                        hostIndex = (string)hostsReader["hostIndex"];
                        product = (string)hostsReader["Product"];
                        averageTemp = -1;

                        if (hostName == "(None)")
                            continue;

                        if (hostName.Contains('.'))
                            continue;

                        //var query = "SELECT * FROM [LINemma_v5_db_MsrOtherHistory].[dbo].[MsrOtherHistory_" + hostName + "_LINtable]   where (CPUNum=1) and (MSRname='IA32_THERM_STATUS')";
                        var query = "IF OBJECT_ID('[LINemma_v5_db_MsrOtherHistory].[dbo].[MsrOtherHistory_" + hostName +
                            "_LINtable]', 'U') IS NOT NULL SELECT * FROM [LINemma_v5_db_MsrOtherHistory].[dbo].[MsrOtherHistory_" +
                            hostName + "_LINtable]   where (CPUNum=1) and (MSRname='IA32_THERM_STATUS')                 ";

                        SqlCommand myCommand = new SqlCommand(query, myConnection2);
                        SqlDataReader myReader = myCommand.ExecuteReader();

                        double sum = 0;
                        int count = 0;
                        double datum;


                        while (myReader.Read())
                        {

                            var msr_val = (long)myReader["MSRVal"];
                            int valid = (int)((msr_val >> 31) & 0x1);
                            int value = 105 - (int)((msr_val >> 16) & 0x7F);


                            if (valid == 1)
                            {

                                sum += value;
                                count++;
                            }

                        }
                        if (count > 0)
                        {
                            averageTemp = sum / count;
                            data.Add(averageTemp);
                            product_sum_of_means += averageTemp;
                            /*
                            if (product == "Prescott")
                            {
                                Prescott.Add(averageTemp);
                                Prescott_sum += averageTemp;
                            }
                            else
                            {
                                Penryn.Add(averageTemp);
                                Penryn_sum += averageTemp;
                            }
                             */
                        }
                        else
                        {
                            averageTemp = -1;
                        }
                        Response.Write(hostName + "," + hostIndex + "," + product + "," + averageTemp + "\n");

                        myReader.Close();




                    }
                    hostsReader.Close();

                    data.Sort();

                    var series_stats = new
                    {
                        name = productName,
                        p1 = perc(data, 1),
                        p5 = perc(data, 5),
                        p10 = perc(data, 10),
                        p20 = perc(data, 20),
                        p80 = perc(data, 80),
                        p90 = perc(data, 90),
                        p95 = perc(data, 95),
                        p99 = perc(data, 99),
                        median = perc(data, 50),
                        mean = Math.Round(product_sum_of_means / data.Count, 2),
                        min = data[0],
                        max = data[data.Count - 1],
                        count = data.Count
                    };
                    arrays.Add(data);
                    array_info.Add(series_stats);

                }//end of product loop
                myConnection.Close();
                myConnection2.Close();



                Response.Write("</pre>");

            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                Response.Write("<h1>Error:</h1><pre style='color: green;'>" + e.ToString() + "</pre>");


               

            }

            var return_data = new
            {
                arrays = arrays,
                series_names = series_names,
                max = 100,
                min = 0,
                array_info = array_info
            };

            var json = new JavaScriptSerializer().Serialize(return_data);
            Console.WriteLine(json);
            ViewData["result"] = json;
            ViewData["analysis"] = "Mean of Means of Temperature";
            ViewData["os"] = "Linux";
            ViewData["classification"] = "By Processor Family";
            return PartialView("Blank");
        }


    }  // end of class

} // end of namespace
