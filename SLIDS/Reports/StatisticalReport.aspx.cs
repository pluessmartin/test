using System;
using Pentag.SLIDS.Controls;

namespace Pentag.SLIDS.Reports
{
    public partial class StatisticalReport : BasePage
    {
        #region Properties

        private ucStatisticDateSearchFilter StatisticDateSearchFilterControl
        {
            get { return ucStatisticDateSearchFilterControl; }
        }

        #endregion

        /// <summary>
        /// Initialises UserControl ucStatistiDateSearchFilter which contains date from and date to filter data
        /// </summary>
        /// <param name="e">EventArgs</param>
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            StatisticDateSearchFilterControl.Initialize(true);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // hide reports when search filter is empty
            phReports.Visible = (!String.IsNullOrEmpty(ucStatisticDateSearchFilterControl.DateFromTextBox.Text)
                     && !String.IsNullOrEmpty(ucStatisticDateSearchFilterControl.DateToTextBox.Text));

            if (!IsPostBack) return;

            // Set values of hidden fields
            hidOrganGroupHeart.Value = Convert.ToString((int)ItemGroupValue.Heart);
            hidOrganGroupLung.Value = Convert.ToString((int)ItemGroupValue.Lung);
            hidOrganGroupLiver.Value = Convert.ToString((int)ItemGroupValue.Liver);
            hidOrganGroupKidney.Value = Convert.ToString((int)ItemGroupValue.Kidney);
            hidOrganGroupPancreas.Value = Convert.ToString((int)ItemGroupValue.Pancreas);
            hidOrganGroupSmallBowel.Value = Convert.ToString((int)ItemGroupValue.SmallBowel);

            hidOrganItemGroupType.Value = Convert.ToString((int) ItemGroupType.Organ);
            hidTransportItemGroupType.Value = Convert.ToString((int) ItemGroupType.TransportItem);
        }

        /// <summary>
        /// Triggers action to create statistical report
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            Session.Remove("DataContext");

            phReports.Visible = true;

            // Microsoft Bug workaround: if ProcessingMode is not set, ReportViewer won't be visible once it was hidden
            rvStatisticalReport.ProcessingMode = Microsoft.Reporting.WebForms.ProcessingMode.Remote;
            rvStatisticalReport.ProcessingMode = Microsoft.Reporting.WebForms.ProcessingMode.Local;

            rvStatisticalReport.LocalReport.Refresh();
        }
    }
}