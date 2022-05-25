using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web.UI.WebControls;
using Pentag.SLIDS.Controls;
using Pentag.SLIDS.DAL;
using Pentag.SLIDS.Reports.DAL;

namespace Pentag.SLIDS.Reports
{
    public partial class FinancialReport : BasePage
    {
        #region Properties

        protected DateTime? RegisterDateFrom
        {
            get { return hidRegisterDateFrom.Value == String.Empty ? (DateTime?) null : Convert.ToDateTime(hidRegisterDateFrom.Value); }
            set { hidRegisterDateFrom.Value = value.ToString(); }
        }

        protected DateTime? RegisterDateTo
        {
            get { return hidRegisterDateTo.Value == String.Empty ? (DateTime?)null : Convert.ToDateTime(hidRegisterDateTo.Value); }
            set { hidRegisterDateTo.Value = value.ToString(); }
        }

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

            StatisticDateSearchFilterControl.Initialize(true, "Register date");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public IQueryable<ProcurementHospitalWithCosts> gvProcurementHospital_GetProcurementHospitalWithCosts(DateTime from, DateTime to)
        {
            /**
             * SELECT
	                Hospital.Name,
	                Hospital.Display,
	                ICCosts = SUM(CASE WHEN CostType.Name = 'Basic Amount IC' OR CostType.Name = 'Flat charges IC' OR CostType.Name = 'Flat charges IC detection Hospital' THEN Cost.Amount ELSE 0 END),
	                OCCosts = SUM(CASE WHEN CostType.Name = 'Basic Amount OR' OR CostType.Name = 'Flat charges OR' THEN Cost.Amount ELSE 0 END),
	                TotalCosts = SUM(CASE WHEN CostType.Name = 'Basic Amount IC' OR CostType.Name = 'Flat charges IC' OR CostType.Name = 'Flat charges IC detection Hospital' OR  CostType.Name = 'Basic Amount OR' OR CostType.Name = 'Flat charges OR' THEN Cost.Amount ELSE 0 END)
                FROM 
	                Hospital
	                INNER JOIN Cost
		                ON Cost.KreditorHospitalID = Hospital.ID
	                INNER JOIN Donor
		                ON Donor.ID = Cost.DonorId
	                INNER JOIN CostType
		                ON CostType.ID = Cost.CostTypeID
                WHERE
	                Hospital.isActive = 1
	                AND
	                Donor.RegisterDate BETWEEN '20140101' AND '20141231'
	                AND
	                Donor.IsDeleted = 0
	                AND
	                Cost.IsDeleted = 0
                GROUP BY
	                Hospital.Name,
	                Hospital.Display
              *
              */
            return Data.Cost.Where(c => c.Donor.RegisterDate >= from && c.Donor.RegisterDate <= to && !c.Donor.IsDeleted && !c.IsDeleted && c.Hospital.isActive)
                .GroupBy(c=> new  { c.Hospital.ID, c.Hospital.Name, c.Hospital.Display})
                .Select(c => new ProcurementHospitalWithCosts()
                {
                    ID = c.Key.ID,
                    Name = c.Key.Name,
                    Display = c.Key.Display,
                    ICCosts = c.Sum(cost => (cost.CostType.Name == "Basic Amount IC" || cost.CostType.Name == "Flat charges IC" || cost.CostType.Name == "Flat charges IC detection Hospital" || cost.CostType.Name == "Flat charges IC referral Hospital") ? cost.Amount : 0),
                    OCCosts = c.Sum(cost => (cost.CostType.Name == "Basic Amount OR" || cost.CostType.Name == "Flat charges OR") ? cost.Amount : 0),
                    TotalCosts = c.Sum(cost => (cost.CostType.Name == "Basic Amount IC" || cost.CostType.Name == "Flat charges IC" || cost.CostType.Name == "Flat charges IC detection Hospital" || cost.CostType.Name == "Flat charges IC referral Hospital" || cost.CostType.Name == "Basic Amount OR" || cost.CostType.Name == "Flat charges OR") ? cost.Amount : 0)
                })
                .Where(t => t.TotalCosts > 0);
        }


        /// <summary>
        /// Binds GridView gvProcurementHospital
        /// </summary>
        /// <returns></returns>
        public IQueryable<ProcurementHospitalWithCosts> gvProcurementHospital_GetProcurementHospital()
        {
            if (RegisterDateFrom == null || RegisterDateTo == null) return null;

            DateTime registerDateFrom = Convert.ToDateTime(RegisterDateFrom);
            DateTime registerDateTo = Convert.ToDateTime(RegisterDateTo);

            return gvProcurementHospital_GetProcurementHospitalWithCosts(registerDateFrom, registerDateTo);
        }

        /// <summary>
        /// Binds GridView gvReminderLetter
        /// </summary>
        /// <returns></returns>
        public IQueryable<Hospital> gvReminderLetter_GetProcurementHospital()
        {
            if (RegisterDateFrom == null || RegisterDateTo == null) return null;

            DateTime registerDateFrom = Convert.ToDateTime(RegisterDateFrom);
            DateTime registerDateTo = Convert.ToDateTime(RegisterDateTo);

            List<Hospital> filteredHospitals = new List<Hospital>();
            List<Hospital> hospitals = GetHospitals().Where(h => h.isActive)
                                                     .Where(h => h.IsProcurement || h.IsReferral)
                                                     .Where(h => h.Cost.Any(c => !c.Donor.IsDeleted))
                                                     .Where(h => h.Cost.Any(c => !c.IsDeleted))
                                                     .Where(h => h.Cost.Any(c => string.IsNullOrEmpty(c.InvoiceNo)))
                                                     .Where(h => h.Cost.Any(c => RegisterDateFrom != null
                                                                                 && c.Donor.RegisterDate != null
                                                                                 && c.Donor.RegisterDate >= registerDateFrom))
                                                     .Where(h => h.Cost.Any(c => RegisterDateTo != null
                                                                                 && c.Donor.RegisterDate != null
                                                                                 && c.Donor.RegisterDate <= registerDateTo))
                                                     .ToList();

            foreach (Hospital hospital in hospitals)
            {
                foreach (SLIDS.DAL.Cost cost in hospital.Cost.Where(c => !c.IsDeleted
                                                                         && string.IsNullOrEmpty(c.InvoiceNo)
                                                                         && c.Donor.RegisterDate != null
                                                                         && c.Donor.RegisterDate >= registerDateFrom
                                                                         && c.Donor.RegisterDate <= registerDateTo
                                                                         && ((c.Donor.ProcurementHospitalID == c.Hospital.ID
                                                                             || c.Donor.ReferralHospitalID == c.Hospital.ID
                                                                             || c.Donor.DetectionHospitalID == c.Hospital.ID)
                                                                             || (c.KreditorHospitalID == c.Hospital.ID && string.IsNullOrEmpty(c.InvoiceNo)))
                                                                         ))
                {
                    if(!filteredHospitals.Contains(hospital)) filteredHospitals.Add(hospital);
                }
            }

            return filteredHospitals.AsQueryable();
        }

        /// <summary>
        /// Allows row select on click of GridView row and aligns amount columns to the right
        /// </summary>
        /// <param name="sender">sender</param>
        /// <param name="e">GridViewRowEventArgs</param>
        protected void gvProcurementHospital_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink(gvProcurementHospital, "Select$" + e.Row.RowIndex);

                e.Row.Cells[3].HorizontalAlign = HorizontalAlign.Right;
                e.Row.Cells[4].HorizontalAlign = HorizontalAlign.Right;
                e.Row.Cells[5].HorizontalAlign = HorizontalAlign.Right;
            }
        }

        /// <summary>
        /// Allows row select on click of GridView row
        /// </summary>
        /// <param name="sender">sender</param>
        /// <param name="e">GridViewRowEventArgs</param>
        protected void gvReminderLetter_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink(gvReminderLetter, "Select$" + e.Row.RowIndex);
            }
        }

        /// <summary>
        /// Triggers new binding of GridViews gvProcurementHospital and gvReminderLetter with entered datetime in ucStatisticDateSearchFilter
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            RegisterDateFrom = StatisticDateSearchFilterControl.DateFrom != null
                                      ? Convert.ToDateTime(StatisticDateSearchFilterControl.DateFrom)
                                      : (DateTime?)null;

            RegisterDateTo = StatisticDateSearchFilterControl.DateTo != null
                                    ? Convert.ToDateTime(StatisticDateSearchFilterControl.DateTo)
                                    : (DateTime?)null;

            pnlProcurementHospital.Visible = true;
            gvProcurementHospital.DataBind();

            pnlReminderLetter.Visible = true;
            gvReminderLetter.DataBind();
        }

        /// <summary>
        /// Gets total amount of IC costs
        /// </summary>
        /// <param name="hospital">hospital</param>
        /// <returns>total IC costs of hospital</returns>
        protected String GetTotalICAmount(Hospital hospital)
        {
            if (RegisterDateFrom == null || RegisterDateTo == null) return String.Empty;

            DateTime registerDateFrom = Convert.ToDateTime(RegisterDateFrom);
            DateTime registerDateTo = Convert.ToDateTime(RegisterDateTo);

            return GetTotalICAmount(hospital, registerDateFrom, registerDateTo);
        }

        /// <summary>
        /// Gets total amount of OR costs
        /// </summary>
        /// <param name="hospital">hospital</param>
        /// <returns>total OR costs of hospital</returns>
        protected String GetTotalORAmount(Hospital hospital)
        {
            if (RegisterDateFrom == null || RegisterDateTo == null) return String.Empty;

            DateTime registerDateFrom = Convert.ToDateTime(RegisterDateFrom);
            DateTime registerDateTo = Convert.ToDateTime(RegisterDateTo);

            return GetTotalORAmount(hospital, registerDateFrom, registerDateTo);
        }

        /// <summary>
        /// Gets total amount of IC and OR costs
        /// </summary>
        /// <param name="hospital">hospital</param>
        /// <returns>total IC and OR costs of hospital</returns>
        protected String GetTotalICORAmount(Hospital hospital)
        {
            if (RegisterDateFrom == null || RegisterDateTo == null) return String.Empty;

            DateTime registerDateFrom = Convert.ToDateTime(RegisterDateFrom);
            DateTime registerDateTo = Convert.ToDateTime(RegisterDateTo);

            return GetTotalICORAmount(hospital, registerDateFrom, registerDateTo);
        }
    }
}