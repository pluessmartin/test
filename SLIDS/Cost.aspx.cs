using Pentag.SLIDS.Constants;
using Pentag.SLIDS.Controls;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public partial class Cost : BasePage
    {
        #region Properties
        protected int CostID
        {
            get { return hidCostID.Value == String.Empty ? 0 : Convert.ToInt32(hidCostID.Value); }
            set { hidCostID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected int CostTypeID
        {
            get { return hidCostTypeID.Value == String.Empty ? 0 : Convert.ToInt32(hidCostTypeID.Value); }
            set { hidCostTypeID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected ucOrganCostAllocation ucOrganCostAllocation
        {
            get { return ucOrganCostAllocationControl; }
        }

        protected List<OrganCost> OrganCostList
        {
            get { return ucOrganCostAllocation.OrganCostList; }

            set { ucOrganCostAllocation.OrganCostList = value; }
        }
        #endregion

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            // Initialize user control and pass CostID to process OrganCosts
            ucOrganCostAllocationControl.Initialize(hidCostID);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Donor General Cost called");

            if (IsPostBack) return;

            string donorID = HttpUtility.UrlDecode(Request.QueryString["donorID"]);
            if (donorID != null) Master.DonorID = Convert.ToInt32(donorID);

            // check if donor was selected, if not do nothing
            if (Master.DonorID <= 0) return;

            // set visibilty of "Add new..."-button initially depending on user rights
            btnAddNewCost.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);

            // Bind dropdownlists and check-box repeaters
            BindDropDownLists();

            if (CostID == 0) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
        }

        public IQueryable<DAL.Cost> gvCost_GetData()
        {
            return GetCosts()
                .Where(c => c.DonorID == Master.DonorID)
                .Where(c => c.CostType.CostGroup.ID == (int)CostGroup.Donor);
        }

        public IQueryable<TransplantOrgan> gvTransplantOrgan_GetData()
        {
            return GetTransplantOrgans()
                .Where(to => to.DonorID == Master.DonorID);
        }

        protected void gvCost_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvCost.DataBind();
            if (gvCost.SelectedIndex == -1 || gvCost.SelectedDataKey == null) return;

            CostID = Convert.ToInt32(gvCost.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void ddlCostType_SelectedIndexChanged(object sender, EventArgs e)
        {
            // If adding a new Cost, set default values to organ cost allocations depending on selected CostTypeID
            if (CostID != 0) return;

            // Get previously selected CostType
            int previouslySelectedCostTypeID = CostTypeID;

            // Set actual selected CostTypeID
            CostTypeID = Convert.ToInt32(Convert.ToInt32(ddlCostType.SelectedValue));

            // Remove previously added Default OrganCosts if necessary
            if (previouslySelectedCostTypeID > 0 && previouslySelectedCostTypeID != CostTypeID)
            {
                if (OrganCostList != null) ucOrganCostAllocation.RemoveAutomatedAddedEntries();
            }

            ucOrganCostAllocation.InitializeOrganCostListWithDefaultOrganCosts(
                Convert.ToInt32(ddlCostType.SelectedValue));

            // Set Total of initialized OrganCostDistributions in txtAmount.Text if at least one OrganCost is existant (otherwise amount needs to stay as it is because of costs not related to OrganCosts
            if (ucOrganCostAllocation.CalcTotal && OrganCostList != null && OrganCostList.Count > 0)
            {
                Decimal? totalAmount = ucOrganCostAllocation.OrganCostList.Select(oca => oca.Amount).Sum();
                txtAmount.Text = Convert.ToDecimal(totalAmount).ToString("N2");
            }
        }

        protected void btnAddNewCost_Click(object sender, EventArgs e)
        {
            CostID = 0;

            gvCost.SelectRow(-1);

            InitialiseCostDetailView();

            OrganCostList = new List<OrganCost>();
            ucOrganCostAllocation.BindOrganCostAllocation();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;
                ucOrganCostAllocation.Save();

                DAL.Cost c = AssignValuesToCost();

                ucOrganCostAllocation.AssignOrganCostsToCost();

                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }

                CostID = c.ID;

                // Refresh DataGridView
                gvCost.DataBind();
                SelectRowInGridView(gvCost, CostID);
            }
            catch (DbUpdateConcurrencyException concurrencyEx)
            {
                HandlePageRefreshAfterConcurrencyException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + concurrencyEx.Message);
            }
            catch (NullReferenceException nullReferenceEx)
            {
                // record has been deleted in the meantime!
                HandlePageRefreshAfterNullReferenceException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + nullReferenceEx.Message);
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not save Cost! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (gvCost.SelectedDataKey != null)
                {
                    DAL.Cost t = GetCostByID(Convert.ToInt32(gvCost.SelectedDataKey.Value));
                    if (t == null)
                    {
                        throw new NullReferenceException(String.Format("Cost with ID {0} could not be found!", gvCost.SelectedDataKey.Value));
                    }

                    t.IsDeleted = true;
                }
                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgDeleteSuccess, SLIDSMaster.LabelState.Success);

                    // Reset CostID and refresh DataGrid
                    CostID = 0;
                    gvCost.SelectedIndex = -1;
                    gvCost.DataBind();
                    pnlCostDetails.Visible = false;
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }
            }
            catch (DbUpdateConcurrencyException concurrencyEx)
            {
                HandlePageRefreshAfterConcurrencyException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + concurrencyEx.Message);
            }
            catch (NullReferenceException nullReferenceEx)
            {
                // record has been deleted in the meantime!
                HandlePageRefreshAfterNullReferenceException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyDeleteNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + nullReferenceEx.Message);
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not delete Cost! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        internal decimal totalAmount = 0;
        internal decimal totalAllocated = 0;

        protected void gvCost_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            gridView_RowDataBound(sender, e);
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Align Amount and total organ allocated costs to the right
                e.Row.Cells[3].HorizontalAlign = HorizontalAlign.Right;
                e.Row.Cells[4].HorizontalAlign = HorizontalAlign.Right;

                DAL.Cost costItem = (DAL.Cost)e.Row.DataItem;
                if (costItem.Amount.HasValue)
                {
                    totalAmount += costItem.Amount.Value;
                }
                totalAllocated += decimal.Parse(GetTotalOrganAllocatedCosts(costItem));

            }
            else if (e.Row.RowType == DataControlRowType.Footer)
            {
                //Delete one row
                e.Row.Cells.RemoveAt(0);

                // Set Total
                Literal lblTotalAmount = (Literal)e.Row.FindControl("lblTotalAmount");
                lblTotalAmount.Text = totalAmount.ToString("N2");
                totalAmount = 0;

                Literal lblTotalAllocated = (Literal)e.Row.FindControl("lblTotalAllocated");
                lblTotalAllocated.Text = totalAllocated.ToString("N2");
                totalAllocated = 0;
            }

        }

        #region Validation

        protected void cvKreditor_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = (Convert.ToInt32(ddlKreditorHospital.SelectedValue) > 0 &&
                            String.IsNullOrWhiteSpace(txtKreditorName.Text))
                           ||
                           (Convert.ToInt32(ddlKreditorHospital.SelectedValue) == 0 &&
                            !String.IsNullOrWhiteSpace(txtKreditorName.Text))
                           ||
                           (Convert.ToInt32(ddlKreditorHospital.SelectedValue) == 0 &&
                            String.IsNullOrWhiteSpace(txtKreditorName.Text));
        }
        #endregion

        #region Privates
        private void LoadAndViewDataDetails()
        {
            // Clear Organ cost list
            if (OrganCostList != null) OrganCostList.Clear();

            DAL.Cost c = GetCostByID(CostID);
            if (c == null) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
            BindDropDownLists();
            PopulateCostDetailView(c);

            OrganCostList = c.OrganCost.ToList();
            ucOrganCostAllocation.BindOrganCostAllocation(resetEdit: true);
        }

        private DAL.Cost AssignValuesToCost()
        {
            bool isRowAdded = CostID == 0;
            DAL.Cost c;

            if (isRowAdded)
            {
                // create new datarow
                c = new DAL.Cost();
                Data.Cost.Add(c);
            }
            else
            {
                // update existing datarow
                c = GetCostByID(CostID);
            }

            c.DonorID = Master.DonorID;
            c.CostTypeID = Convert.ToInt32(ddlCostType.SelectedValue) > 0
                               ? (int?)Convert.ToInt32(ddlCostType.SelectedValue)
                               : null;
            c.KreditorHospitalID = Convert.ToInt32(ddlKreditorHospital.SelectedValue) > 0
                                       ? (int?)Convert.ToInt32(ddlKreditorHospital.SelectedValue)
                                       : null;
            c.Name = !String.IsNullOrWhiteSpace(txtName.Text) ? txtName.Text : String.Empty;
            c.KreditorName = !String.IsNullOrWhiteSpace(txtKreditorName.Text) ? txtKreditorName.Text : null;
            c.InvoiceNo = !String.IsNullOrWhiteSpace(txtInvoiceNo.Text) ? txtInvoiceNo.Text : null;
            c.Amount = !String.IsNullOrWhiteSpace(txtAmount.Text)
                           ? (decimal?)Convert.ToDecimal(txtAmount.Text)
                           : null;
            c.Comment = !String.IsNullOrWhiteSpace(txtComment.Text) ? txtComment.Text : null;

            if (Convert.ToInt32(ddlCostType.SelectedValue) > 0) c.CostType = GetCostTypeByID(Convert.ToInt32(ddlCostType.SelectedValue));
            if ((Convert.ToInt32(ddlKreditorHospital.SelectedValue) > 0)) c.Hospital = GetHospitalByID(Convert.ToInt32(ddlKreditorHospital.SelectedValue));

            return c;
        }

        private void PopulateCostDetailView(DAL.Cost c)
        {
            if (c == null) throw new Exception("Cost datarow was not provided!");

            ddlCostType.SelectedValue = c.CostTypeID != null
                                            ? c.CostTypeID.ToString()
                                            : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            ddlKreditorHospital.SelectedValue = c.KreditorHospitalID != null
                                                    ? c.KreditorHospitalID.ToString()
                                                    : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtName.Text = c.Name;
            txtKreditorName.Text = c.KreditorName;
            txtInvoiceNo.Text = c.InvoiceNo;
            txtAmount.Text = c.Amount != null ? Convert.ToDecimal(c.Amount).ToString("N2") : String.Empty;
            txtComment.Text = c.Comment;
        }

        private void BindDropDownLists()
        {
            // Cost Type
            ddlCostType.ClearSelection();
            ddlCostType.DataSource = Data.CostType.Where(ct => ct.CostGroupID == (int)CostGroup.Donor).ToList();
            ddlCostType.DataValueField = "ID";
            ddlCostType.DataTextField = "Name";
            ddlCostType.DataBind();
            ddlCostType.Items.Insert(0,
                                     new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                  DropDownDefaultValue.DDL_DEFAULT_VALUE));

            DAL.Cost c = GetCostByID(CostID);

            // Kreditor Hospital
            int kreditorHospitalID = c != null && c.KreditorHospitalID != null ? (int)c.KreditorHospitalID : 0;
            ddlKreditorHospital.ClearSelection();
            ddlKreditorHospital.DataSource = GetSwissHospitals()
                .Where(h => h.isActive || h.ID == kreditorHospitalID)
                .OrderByDescending(h => h.IsTransplantation)
                .ThenBy(h => h.Display).ToList();
            ddlKreditorHospital.DataValueField = "ID";
            ddlKreditorHospital.DataTextField = "Display";
            ddlKreditorHospital.DataBind();
            ddlKreditorHospital.Items.Insert(0,
                                             new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                          DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void InitialiseCostDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();

            ddlCostType.SelectedIndex = 0;
            ddlKreditorHospital.SelectedIndex = 0;
            txtName.Text = String.Empty;
            txtKreditorName.Text = String.Empty;
            txtInvoiceNo.Text = String.Empty;
            txtAmount.Text = String.Empty;
            txtComment.Text = String.Empty;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            pnlCostDetails.Visible = true;
            pnlCostDetails.Enabled = !DonorIsArchived(Master.DonorID);

            ucOrganCostAllocation.OrganCostAllocationGridView.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);

            btnSave.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            btnDelete.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && CostID != 0 && !DonorIsArchived(Master.DonorID);

            // Invoice
            lblInvoiceNo.Visible = Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant;
            txtInvoiceNo.Visible = Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant;
            lblAmount.Visible = Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant;
            txtAmount.Visible = Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant;

            // Comment
            lblComment.Visible = Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant;
            txtComment.Visible = Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant;
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            gvCost.DataBind();

            if (gvCost.SelectedIndex >= 0) LoadAndViewDataDetails();
            else pnlCostDetails.Visible = false;
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            CostID = 0;
            gvCost.SelectedIndex = -1;
            gvCost.DataBind();
            pnlCostDetails.Visible = false;
        }
        #endregion
    }
}