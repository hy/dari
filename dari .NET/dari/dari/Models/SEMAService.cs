﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Collections;

namespace dari.Models
{
    public class SEMAService
    {

        string connectionString = "user id=username;" +
                                       "password=password;server=FM6SSQL049,3180;" +
                                       "Trusted_Connection=yes;" +
                                       "database=emma_v5_db; " +
                                       "connection timeout=30";

        //Functions for Per-User History

        public Object getHostPlatforms(){
            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            string query = @"SELECT distinct
      [HostPlatform]
  FROM [emma_v5_db].[dbo].[CPUMemBasedPrimaryIndexMap_LINtable]
union
SELECT distinct
      [HostPlatform]
  FROM [emma_v5_db].[dbo].[CPUMemBasedPrimaryIndexMap_WINtable]";

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<string> data = new List<string>();

            while (myReader.Read())
            {
                data.Add(myReader[0].ToString());
            }
            myConnection.Close();

            return data;
        }

        public Object getProductFamilies()
        {

            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            string query = @"SELECT Distinct
      [ProductFamily]
  FROM [emma_v5_db].[dbo].[CPUPrimaryCPUInfoProcessed_LINtable]
Union
  SELECT Distinct
      [ProductFamily]
  FROM [emma_v5_db].[dbo].[CPUPrimaryCPUInfoProcessed_WINtable]";

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<string> data = new List<string>();

            while (myReader.Read())
            {
                data.Add(myReader[0].ToString());
            }
            myConnection.Close();

            return data;
        }

        public Object getHostNames(Dictionary<string, object> parameters)
        {
            string hostPlatform = (string) parameters["hostPlatform"];
            string productFamily = (string) parameters["productFamily"];
            string os = (string) parameters["os"];
            string key = (string) parameters["key"];


            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            string query = @"SELECT top 10 [Hostname]
  FROM [emma_v5_db].[dbo].[CPUPrimaryCPUInfoProcessed_LINtable]
  , [emma_v5_db].[dbo].[CPUBasedPrimaryIndexMap_LINtable]
  , [emma_v5_db].[dbo].[HostLifetime_LINtable]
where CPUNum=1 
and [CPUBasedPrimaryIndexMap_LINtable].HostIndex=[CPUPrimaryCPUInfoProcessed_LINtable].CPUPrimaryHostIndex
and [HostLifetime_LINtable].HostIndex = [CPUBasedPrimaryIndexMap_LINtable].HostIndex
";

            if (hostPlatform.Length>0)
                query += ("and [CPUBasedPrimaryIndexMap_LINtable].HostPlatform = '" + hostPlatform + "'");

            if (productFamily.Length>0)
                query += ("and [CPUPrimaryCPUInfoProcessed_LINtable].ProductFamily = '" + productFamily + "'");

            if (key.Length>0)
                query += ("and [Hostname] like '"+key+"%'");

            if (os == "Windows")
                query = query.Replace("_LIN", "_WIN");

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<string> data = new List<string>();

            while (myReader.Read())
            {
                data.Add(myReader[0].ToString());
            }
            myConnection.Close();

            return data;
        }

        public Object getHostInfo(Dictionary<string, object> parameters)
        {
            string hostName = (string) parameters["hostname"];

            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            string query = @"SELECT [Hostname]
		,[HostPlatform]
      ,[Birthtime]
      ,[Deathtime]
      ,[NumLogical]
      ,[NumCores]
      ,[NumPhysical]
      ,[TotalMemory]
        ,[CPUPrimaryHostIndex]
      ,[HostLifetime_LINtable].[HostIndex]
  FROM [emma_v5_db].[dbo].[HostLifetime_LINtable],[emma_v5_db].[dbo].[HostDetails_LINtable], [emma_v5_db].[dbo].[CPUBasedPrimaryIndexMap_LINtable]
  where [emma_v5_db].[dbo].[HostLifetime_LINtable].[HostIndex] = [emma_v5_db].[dbo].[HostDetails_LINtable].[HostIndex]
  and [emma_v5_db].[dbo].[HostLifetime_LINtable].[HostIndex] = [emma_v5_db].[dbo].[CPUBasedPrimaryIndexMap_LINtable].[HostIndex]
  and  [Hostname]='" + hostName + "'";

                query += (" UNION " + query.Replace("_LIN", "_WIN"));

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<object> data = new List<object>();
            Dictionary<string,object> instanceInfo;

            while (myReader.Read())
            {
                instanceInfo = new Dictionary<string, object>();
                
                instanceInfo["Birthtime"] = (long)myReader["Birthtime"];
                instanceInfo["Deathtime"] = (long)myReader["Deathtime"];
                instanceInfo["NumLogical"] = (long)myReader["NumLogical"];
                instanceInfo["NumCores"] = (long)myReader["NumCores"];
                instanceInfo["NumPhysical"] = (long)myReader["NumPhysical"];
                instanceInfo["TotalMemory"] = (long)myReader["TotalMemory"];
                instanceInfo["HostIndex"] = (string)myReader["HostIndex"];
                instanceInfo["PrimaryHostIndex"] = (string)myReader["CPUPrimaryHostIndex"];
                instanceInfo["HostPlatform"] = (string)myReader["HostPlatform"];

                DateTime epoch = new DateTime(1970,1,1,0,0,0,0);
                string birthString = epoch.AddSeconds( (long)instanceInfo["Birthtime"] ).ToLocalTime().ToString("MMMM d, yyyy");
                string deathString = epoch.AddSeconds((long)instanceInfo["Deathtime"]).ToLocalTime().ToString("MMMM d, yyyy");

                instanceInfo["timeIntervalLabel"] = birthString + "- " + deathString;
                
                data.Add(instanceInfo);
            }
            myReader.Close();

            List<object> cpuInfo;

            foreach (Dictionary<string,object> hostInstance in data){

                query = @"SELECT [CPUPrimaryHostIndex]
      ,[CPUNum]
      ,[IsLogPrimary]
      ,[IsCorePrimary]
      ,[Product]
      ,[ProductFamily]
      ,[MgProcess]
      ,[MaxClockSpeed]
      ,[FSBFreqMHz]
      ,[Signature]
      ,[ExtFamily]
      ,[ExtModel]
      ,[Family]
      ,[Model]
      ,[Stepping]
      ,[CPUType]
      ,[Codename]
      ,[BrandString]
      ,[LogID]
      ,[CoreID]
      ,[PhysID]
      ,[ApicID]
      ,[NumLogical]
      ,[NumCores]
      ,[NumPhysical]
      ,[LogPerPhys]
      ,[CorePerPhys]
      ,[LogPerCore]
      ,[Siblings]
      ,[Cousins]
      ,[TC_Kuops]
      ,[IL1]
      ,[DL1]
      ,[L2]
      ,[L3]
      ,[ITLB_Entries]
      ,[DTLB_Entries]
  FROM [emma_v5_db].[dbo].[CPUPrimaryCPUInfoProcessed_LINtable]
  where [CPUPrimaryHostIndex] = '" + hostInstance["PrimaryHostIndex"] + "'";
                query += (" UNION " + query.Replace("_LIN", "_WIN"));


                myCommand = new SqlCommand(query, myConnection);
                myReader = null;
                myReader = myCommand.ExecuteReader();
                object obj;

                cpuInfo = new List<object>();

                while (myReader.Read())
                {
                    obj = new
                    {
                        CPUNum = (int)myReader["CPUNum"],
                        ProductFamily = (string)myReader["ProductFamily"],
                        CoreID = (int)myReader["CoreID"],
                        PhysID = (int)myReader["PhysID"],
                        BrandString = (string)myReader["BrandString"]
                    };

                    cpuInfo.Add(obj);

                    hostInstance["cpus"] = cpuInfo;
                }

                myReader.Close();
            }


            myConnection.Close();
            return data;
        }




        //Functions for Agregated Reports
        private Object metaQueries(string table, string field, string condition = "1=1", string distinct = "distinct ")
        {

            if (table.StartsWith("turbo")) return getTurboData();

            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();


            var query = "SELECT " + distinct  + field + " FROM " + table + "";
                query += (" where (" + condition + ")");

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<object> data = new List<object>();

            while (myReader.Read())
            {
                data.Add((object)myReader[0]);
            }
            myConnection.Close();

            return data;
        }


        public Object getReportDates(Dictionary<string, object> parameters)
        {
            string analysisType = (string) parameters["analysis"];
            string os = (string) parameters["os"];

            string tableStr;
            string fieldName;

            switch (analysisType){
                case "Host Memory Utilization":
                    tableStr = "Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable";
                    fieldName = "AnalysisTimestamp";
                    break;
                case "Host Uptime and downtime periods":
                    tableStr = "Summary_DowntimePerCPUPrimaryHostIndex_LINtable";
                    fieldName = "AnalysisTime";
                    break;
                default:
                    return null; //put error code
            }
                
            string tableName = (os=="Windows")? tableStr.Replace("_LIN", "_WIN") : tableStr;
            var results = metaQueries(tableName, fieldName);

            return results;
        }

        public Object getReportClasses(Dictionary<string, object> parameters)
        {
            string analysisType = (string) parameters["analysis"];
            string os = (string) parameters["os"];
            string classification = (string) parameters["classification"];
            string time = (string) parameters["time"];

            string tableName;
            string fieldName;
            string condition;

            switch (analysisType)
            {
                case "Host Memory Utilization":
                    tableName = "[emma_v5_db].[dbo].Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable";
                    condition = "AnalysisTimestamp="+ time;
                    break;
                case "Host Uptime and downtime periods":
                    tableName = "[emma_v5_db].[dbo].Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable";
                    condition = "AnalysisTime="+ time;
                    break;
                default:
                    return null; //put error code
            }



            fieldName = classification;
            condition += (" and [emma_v5_db].[dbo].[CPUPrimaryCPUInfoProcessed_LINtable].[CPUPrimaryHostIndex]=" + tableName + ".HostIndex ");
            tableName += ", [emma_v5_db].[dbo].[CPUPrimaryCPUInfoProcessed_LINtable]";


            if (os == "Windows")
            {
                tableName = tableName.Replace("_LIN", "_WIN");
                condition = condition.Replace("_LIN", "_WIN");
                fieldName = fieldName.Replace("_LIN", "_WIN");
            }
            var results = metaQueries(tableName, fieldName, condition);

            return results;
        }

        private double perc(List<object> list, int key)
        {
            double res;
            if( list.Count > 0)
                res = (double) (list[(int)(key * list.Count / 100)]);
            else
                res = -1.0;
            return (double) res;
        }

        public Object getPlottingData(Dictionary<string, object> parameters)
        {
            string analysisType = (string) parameters["analysis"];
            string os = (string) parameters["os"];
            string classification = (string) parameters["classification"];
            string time = (string) parameters["time"];
            string[] series = (string[]) parameters["className"];
            string variable = (string) parameters["variable"];

            string tableName;
            string fieldName;
            string condition;


            List<object> arrays = new List<object>();
            List<object> series_names = new List<object>();
            List<object> array_info = new List<object>();

            foreach (string className in series)
            {

                switch (analysisType)
                {
                    case "Host Memory Utilization":
                        tableName = "[emma_v5_db].[dbo].Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable";
                        condition = "AnalysisTimestamp=" + time;
                        fieldName = "AvgMemUtil";
                        break;
                    case "Host Uptime and downtime periods":
                        tableName = "[emma_v5_db].[dbo].Summary_MemUtilPerCPUMemPrimaryHostIndex_LINtable";
                        condition = "AnalysisTime=" + time;
                        fieldName = variable;
                        break;
                    case "turbo":
                        tableName = "turbo";
                        condition = "";
                        fieldName = "";
                        break;
                    default:
                        return null; //put error code
                }


                condition += (" and [emma_v5_db].[dbo].[CPUPrimaryCPUInfoProcessed_LINtable].[CPUPrimaryHostIndex]=" + tableName + ".HostIndex ");
                condition += (" and " + classification + "='" + className + "'");
                tableName += ", [emma_v5_db].[dbo].[CPUPrimaryCPUInfoProcessed_LINtable]";

                if (os == "Windows")
                {
                    tableName = tableName.Replace("_LIN", "_WIN");
                    condition = condition.Replace("_LIN", "_WIN");
                    fieldName = fieldName.Replace("_LIN", "_WIN");
                }
                var results = metaQueries(tableName, fieldName, condition, "");


                List<object> data = (List<object>)results;
                List<double> sampled_data = new List<double>();
                var sum = 0.0;
                var cnt = 0;
                var sampling_rate = data.Count / 1000 + 1;
                data.ForEach(delegate(object val)
                {
                    sum += (double)val;
                    if (((cnt++) % sampling_rate) == 0)
                    {
                        sampled_data.Add((double)val);

                    }
                });

                data.Sort();

                var obj = new
                {
                    name = className,
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

                arrays.Add(sampled_data);
                series_names.Add(className);
                array_info.Add(obj);
            }

            var return_data = new
            {
                arrays = arrays,
                series_names = series_names,
                max = 100,
                min = 0,
                array_info = array_info
            };

            return return_data;

        }




        /*advanced analysis */
        private Object getTurboData(){

            var query = @"use emma_v5_db

SELECT  A.HostIndex,MAX(B.TotalUptime * 100.0/B.TotalRegistered) as S0_PerDay,AVG(A.PercentC0PerS0) as AvgC0_PerCore ,MAX(A.TFM_PerC0) as MaxP0_PerC0,
       
        MAX(A.TFM_PerC0) * MAX(B.TotalUptime * 100.0/B.TotalRegistered)  * (MAX(A.PercentC0PerS0) + 0.5 * MIN(A.PercentC0PerS0))/100  as P0_Per_Day,
        
  
AVG(A.TFM_PerC0 * A.PercentC0PerS0 ) as AvgP0_PerS0
, (MAX(A.PercentC0PerS0) + 0.5 * MIN(A.PercentC0PerS0)) as Package_C0


    from Sum_CPUCPstats_PerPhyCore_BasicStats_WINtable as A, Summary_DowntimePerCPUPrimaryHostIndex_WINtable as B,
CPUPrimaryCPUInfoProcessed_WINtable as C, CPUBasedPrimaryIndexMap_WINtable as D
where A.HostIndex=B.HostIndex and B.TotalRegistered > 0 and C.CPUPrimaryHostIndex=B.HostIndex and C.CPUNum=1 and C.Product='Ivy Bridge' and A.TotalCollectionHours > 150
and D.CPUPrimaryHostIndex=C.CPUPrimaryHostIndex and D.HostPlatform='LAPTOP' and D.IsPrimary=1  and C.NumCores=2 --and A.CPUNum=2
group by A.HostIndex order by A.HostIndex
";


            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<object> data = new List<object>();

            while (myReader.Read())
            {
                data.Add((object)myReader["P0_Per_Day"]);
            }
            myConnection.Close();

            return data;
        }

        public class filterParams
        {

            public List<object> filters { get; set; }
            public Dictionary<string, string> filterValues { get; set; }
        }
        public Object correlation(Dictionary<string, object> parameters)
        {

            var columns = new Dictionary<string, string>
                {
                    { "Product", "C.Product" }, 
                    { "HostPlatform", "D.HostPlatform" },
                    { "NumCores", "C.NumCores" }
                };

            var conditions = "";
            foreach(var filter in (string[]) parameters["filters"]){
                conditions += string.Format(" and {0}='{1}'", columns[filter], parameters[filter]);
            }


            var query = string.Format(@"use emma_v5_db

SELECT  A.HostIndex,MAX(B.TotalUptime * 100.0/B.TotalRegistered) as S0_PerDay,AVG(A.PercentC0PerS0) as AvgC0_PerCore ,MAX(A.TFM_PerC0) as MaxP0_PerC0,
       
        MAX(A.TFM_PerC0) * MAX(B.TotalUptime * 100.0/B.TotalRegistered)  * (MAX(A.PercentC0PerS0) + 0.5 * MIN(A.PercentC0PerS0))/100  as P0_Per_Day,
        
  
AVG(A.TFM_PerC0 * A.PercentC0PerS0 ) as AvgP0_PerS0
, (MAX(A.PercentC0PerS0) + 0.5 * MIN(A.PercentC0PerS0)) as Package_C0


    from Sum_CPUCPstats_PerPhyCore_BasicStats_WINtable as A, Summary_DowntimePerCPUPrimaryHostIndex_WINtable as B,
CPUPrimaryCPUInfoProcessed_WINtable as C, CPUBasedPrimaryIndexMap_WINtable as D
where A.HostIndex=B.HostIndex and B.TotalRegistered > 0 and C.CPUPrimaryHostIndex=B.HostIndex and C.CPUNum=1 and A.TotalCollectionHours > 150
and D.CPUPrimaryHostIndex=C.CPUPrimaryHostIndex and D.IsPrimary=1 {0}
group by A.HostIndex order by A.HostIndex
", conditions);
            string x = (string)parameters["x"]; //AvgC0_PerCore
            string y = (string)parameters["y"]; //AvgP0_PerS0

            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            SqlCommand myCommand = new SqlCommand(query, myConnection);
            SqlDataReader myReader = null;
            myReader = myCommand.ExecuteReader();

            List<object> data = new List<object>();
            object obj;

            while (myReader.Read())
            {
                obj = new
                {
                    x = myReader[x],
                    y = myReader[y],
                    info = myReader["HostIndex"]
                };
                data.Add(obj);
            }
            myConnection.Close();

            return data;
        }

        public Object getFilterOptions() {

            SqlConnection myConnection = new SqlConnection(connectionString);
            myConnection.Open();

            Dictionary<string, List<object>> filters = new Dictionary<string, List<object>>();
            filters["Product"] = new List<object>();
            filters["HostPlatform"] = new List<object>();
            filters["NumCores"] = new List<object>();

            foreach (KeyValuePair<string, List<object>> pair in filters)
            {
                string query = String.Format(@"SELECT DISTINCT {0}
from CPUPrimaryCPUInfoProcessed_WINtable, CPUBasedPrimaryIndexMap_WINtable
where CPUBasedPrimaryIndexMap_WINtable.HostIndex = CPUPrimaryCPUInfoProcessed_WINtable.CPUPrimaryHostIndex",pair.Key);

                query += (" UNION " + query.Replace("_LIN", "_WIN"));

                SqlCommand myCommand = new SqlCommand(query, myConnection);
                SqlDataReader myReader = null;
                myReader = myCommand.ExecuteReader();

                //List<object> data = new List<object>();

                while (myReader.Read())
                {
                    pair.Value.Add(myReader[0]);
                }
                myReader.Close();

            }
            myConnection.Close();

            return filters;
        }
    }
}