using System;
using System.Globalization;
using System.IO;
using System.Web;
using Pentag.SLIDS.Controls;
using Pentag.SLIDS.DAL;

namespace Pentag.SLIDS
{
    public partial class Statistics : BasePage
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

            StatisticDateSearchFilterControl.Initialize(true, "Register date");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            Ado.SearchParameters filter = new Ado.SearchParameters(txtDonorNumberSearch.Text,
                                                                   StatisticDateSearchFilterControl.StringDateFrom,
                                                                   StatisticDateSearchFilterControl.StringDateTo);
            StatisticalExport export = new StatisticalExport();
            MemoryStream stream = export.CreateExcel(filter);
            byte[] file = stream.ToArray();

            string fileLength = file.Length.ToString(CultureInfo.InvariantCulture);

            Response.AddHeader("content-disposition", "attachment; filename=SLIDS_Statistics.xlsx");

            Response.AddHeader("content-type", "application/application/excel");
            Response.AddHeader("Content-Length", fileLength);

            Response.BinaryWrite(file);
            Response.Flush();
            Response.End();
        }
    }
}