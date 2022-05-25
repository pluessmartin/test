using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using Pentag.SLIDS.Controls;
using Pentag.SLIDS.DAL;

namespace Pentag.SLIDS
{
    public partial class IncitentStatistics : BasePage
    {
        private ucStatisticDateSearchFilter StatisticDateSearchFilterControl
        {
            get { return ucStatisticDateSearchFilterControl; }
        }

        /// <summary>
        /// Initialises UserControl ucStatistiDateSearchFilter which contains date from and date to filter data
        /// </summary>
        /// <param name="e">EventArgs</param>
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            StatisticDateSearchFilterControl.Initialize(true, "Incitent date");
            StatisticDateSearchFilterControl.StringDateFrom = new DateTime(DateTime.Now.Year, 1, 1).ToString("dd.MM.yyyy");
            StatisticDateSearchFilterControl.StringDateTo = new DateTime(DateTime.Now.Year, 12, 31).ToString("dd.MM.yyyy");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            Dictionary<string, int> dictionaryProcess = new Dictionary<string, int>();
            Dictionary<string, int> dictionaryCategory = new Dictionary<string, int>();
            var incidents = this.GetIncident(DateTime.Parse(StatisticDateSearchFilterControl.StringDateFrom), DateTime.Parse(StatisticDateSearchFilterControl.StringDateTo));

            foreach(var incident in incidents)
            {
                if (incident.IncidentProcess != null)
                {
                    if (dictionaryProcess.ContainsKey(incident.IncidentProcess.Description))
                    {
                        dictionaryProcess[incident.IncidentProcess.Description] = dictionaryProcess[incident.IncidentProcess.Description] + 1;
                    }
                    else
                    {
                        dictionaryProcess.Add(incident.IncidentProcess.Description, 1);
                    }
                }
                if (incident.IncidentCategory != null)
                {

                    if (dictionaryCategory.ContainsKey(incident.IncidentCategory.Description))
                    {
                        dictionaryCategory[incident.IncidentCategory.Description] = dictionaryCategory[incident.IncidentCategory.Description] + 1;
                    }
                    else
                    {
                        dictionaryCategory.Add(incident.IncidentCategory.Description, 1);
                    }
                }
            }

            DataTable dataCategory = new DataTable();
            DataRow row = dataCategory.NewRow();
            int i = 0;
            foreach (var entry in dictionaryCategory)
            {

                dataCategory.Columns.Add(entry.Key, typeof(string));
                row[i] = entry.Value;
                i++;
            }
            if(i == 0)
            {
                dataCategory.Columns.Add("keine Daten", typeof(string));
            }
            dataCategory.Rows.Add(row);
            dataCategory.AcceptChanges();

            DataTable dataProcess = new DataTable();
            DataRow _row = dataProcess.NewRow();
            int _i = 0;
            foreach (var entry in dictionaryProcess)
            {

                dataProcess.Columns.Add(entry.Key, typeof(string));
                _row[_i] = entry.Value;
                _i++;
            }

            if (_i == 0)
            {
                dataProcess.Columns.Add("keine Daten", typeof(string));
            }


            dataProcess.Rows.Add(_row);
            dataProcess.AcceptChanges();


            StatisticalExport export = new StatisticalExport();
            MemoryStream stream = export.CreateExcel(dataProcess, dataCategory);
            byte[] file = stream.ToArray();

            string fileLength = file.Length.ToString(CultureInfo.InvariantCulture);

            Response.AddHeader("content-disposition", "attachment; filename=SLIDS_Incitents.xlsx");

            Response.AddHeader("content-type", "application/application/excel");
            Response.AddHeader("Content-Length", fileLength);

            Response.BinaryWrite(file);
            Response.Flush();
            Response.End();
        }
    }
}