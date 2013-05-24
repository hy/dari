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
    public class PlotController : Controller
    {
        //
        // GET: /Plot/

        public ActionResult Index()
        {
            return View();
        }


        public ActionResult Test(string id, string[] series)
        {
            int timeStamp = 1290037523;
            SqlConnection myConnection = new SqlConnection("user id=username;" +
                                       "password=password;server=FM6VSQL041,3180;" +
                                       "Trusted_Connection=yes;" +
                                       "database=emma_v5_db; " +
                                       "connection timeout=30");

            List<string> classes = new List<string>();
            //add up to 3 classes for plotting
            for (int j = 0; j < Math.Min(series.Length, 3); j++)
            {
                classes.Add(series[j]);
            }
            //classes.Add("SERVER");
            //classes.Add("DESKTOP");
            //classes.Add("ALL");
            List<Object> results = new List<Object>();

            List<Object> arrays = new List<Object>();
            List<Object> array_info = new List<Object>();
            try
            {
                myConnection.Open();

                classes.ForEach(delegate(String name)
                {
                    var result = MemUtil(myConnection, timeStamp.ToString(), name);
                    arrays.Add(result.Item1);
                    array_info.Add(result.Item2);
                });

                myConnection.Close();
                /*
                var min = (servers.Item1[0] < desktops.Item1[0]) ? servers.Item1[0]: desktops.Item1[0];
                var max = (servers.Item1[servers.Item1.Count - 1] > desktops.Item1[desktops.Item1.Count - 1]) ? servers.Item1[servers.Item1.Count - 1] : desktops.Item1[desktops.Item1.Count - 1];
                */
                //dynamic dataInfo = servers.Item2;
                //string name = dataInfo.name;

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
                ViewData["analysis"] = "Host Memory Utilization";
                ViewData["os"] = "Linux";
                ViewData["classification"] = "By Platform";

                System.DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
                ViewData["date"] = dtDateTime.AddSeconds(timeStamp).ToString();
                
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                Response.Write("<h1>Error:</h1><h2>" + e.ToString() + "</h2>");
            }

            return PartialView("Blank");
        }

        double perc(List<double> list, int key){
            var res = list[(int) (key * list.Count/100)];
            return res;
        }

        private Tuple<List<double>, Object> MemUtil(SqlConnection myConnection, string timestamp, string hostplatform)
        {
            string query = "SELECT [AvgMemUtil] FROM [emma_v5_db].[dbo].[Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable]  where ([AnalysisTimestamp] = " + timestamp + ") and ([AvgMemUtil]>-1)";
            //string query = "SELECT [AvgMemUtil] FROM [emma_v5_db].[dbo].[Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable]  where ([AnalysisTimestamp] = " + timestamp + ")";
            string seriesName = "All";
            if (hostplatform != "ALL")
            {
                query += "and ([HostPlatform]='" + hostplatform + "')";
                seriesName = hostplatform;
            }
            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();
            double sum = 0;
            double datum;

            List<double> data = new List<double>();

            while (myReader.Read())
            {
                datum = (double)myReader["AvgMemUtil"];
                data.Add(datum);
                sum += datum;
            }

            List<double> sampled_data = new List<double>();
            var cnt = 0;
            var sampling_rate = data.Count / 1000 + 1;
            data.ForEach(delegate(double val) {
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
                mean = Math.Round(sum / data.Count,2),
                min = data[0],
                max = data[data.Count - 1],
                count = data.Count
            };

            myReader.Close();
            return new Tuple<List<double>, Object>(sampled_data, obj);
        }
    }
}
