using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;

namespace dari.Models
{
    public class DariDataSources
    {
        dariDataConfigSection config;
        public dariDataConnectionElementCollection collection;

        public DariDataSources()
        {
            config = ConfigurationManager.GetSection("dariDataConfig") as dariDataConfigSection;
            collection = config.dariDataConnections;
        }

    }

    public class dariDataConnectionElement : ConfigurationElement
    {
        [ConfigurationProperty("name", IsKey = true, IsRequired = true)]
        public string Name
        {
            get { return (string)this["name"]; }
            set { this["name"] = value; }
        }

        [ConfigurationProperty("url", IsRequired = true, DefaultValue = "http://localhost")]
        public string Url
        {
            get { return (string)this["url"]; }
            set { this["url"] = value; }
        }

    }

    [ConfigurationCollection(typeof(dariDataConnectionElement))]
    public class dariDataConnectionElementCollection : ConfigurationElementCollection
    {
        protected override ConfigurationElement CreateNewElement()
        {
            return new dariDataConnectionElement();
        }

        protected override object GetElementKey(ConfigurationElement element)
        {
            return ((dariDataConnectionElement)element).Name;
        }
    }

    public class dariDataConfigSection : ConfigurationSection
    {
        [ConfigurationProperty("dariDataConnections", IsDefaultCollection = true)]
        public dariDataConnectionElementCollection dariDataConnections
        {
            get { return (dariDataConnectionElementCollection)this["dariDataConnections"]; }
            set { this["dariDataConnections"] = value; }
        }
    }  
}