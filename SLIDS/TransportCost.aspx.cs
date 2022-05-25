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
    public partial class TransportCost : BasePage
    {
        #region Properties
        public int CostID
        {
            get { return hidCostID.Value == String.Empty ? 0 : Convert.ToInt32(hidCostID.Value); }
            set { hidCostID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected int CurrentTransportIDToSelect
        {
            get { return hidTransportIDToSelect.Value == String.Empty ? 0 : Convert.ToInt32(hidTransportIDToSelect.Value); }
            set { hidTransportIDToSelect.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected int CurrentCostTypeID
        {
            get { return hidCostTypeID.Value == String.Empty ? 0 : Convert.ToInt32(hidCostTypeID.Value); }
            set { hidCostTypeID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected Decimal CurrentAmount
        {
            get { return hidAmount.Value == String.Empty ? 0 : Convert.ToDecimal(hidAmount.Value); }
            set { hidAmount.Value = value.ToString(CultureInfo.InvariantCulture); }
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

        protected bool TransportSelectionIsMandatory
        {
            get
            {
                return hidTransportSelectionIsMandatory.Value == String.Empty ||
                       Convert.ToBoolean(hidTransportSelectionIsMandatory.Value);
            }
            set { hidTransportSelectionIsMandatory.Value = value.ToString(); }
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
            logger.Debug("Donor Transport Cost called");

            if (IsPostBack) return;

            string donorID = HttpUtility.UrlDecode(Request.QueryString["donorID"]);
            if (donorID != null) Master.DonorID = Convert.ToInt32(donorID);

            // check if donor was selected, if not do nothing
            if (Master.DonorID <= 0) return;

            // set visibilty of "Add new..."-button initially depending on user rights
            btnAddNewTransportCost.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);

            // Bind dropdownlists and check-box repeaters
            BindDropDownLists();

            if (CostID == 0) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
        }

        public IQueryable<DAL.Cost> gvTransportCost_GetData()
        {
            return GetCosts()
                .Where(c => c.DonorID == Master.DonorID)
                .Where(
                    c =>
                    c.CostType.CostGroup.ID == (int)CostGroup.Transport ||
                    c.CostType.CostGroupID == (int)CostGroup.TransportGlobal);
        }

        protected void gvTransportCost_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvTransportCost.SelectedIndex == -1 || gvTransportCost.SelectedDataKey == null) return;

            CostID = Convert.ToInt32(gvTransportCost.SelectedDataKey.Value);

            LoadAndViewDataDetails();
            gvTransportCost.DataBind();
        }

        public IQueryable<DAL.Transport> gvTransport_GetData()
        {
            return GetTransportsByDonorID(Master.DonorID);
        }

        public IQueryable<DAL.Transport> gvTransportsToSelect_GetData()
        {
            return GetTransportsByDonorID(Master.DonorID);
        }

        protected void ddlTransportCostType_SelectedIndexChanged(object sender, EventArgs e)
        {
            ManageTransportSelection(Convert.ToInt32(ddlTransportCostType.SelectedValue));

            InitializeOrganCostListWithDefaultOrganCosts(sender, e);
        }

        protected void InitializeOrganCostListWithDefaultOrganCosts(object sender, EventArgs e)
        {
            // Only set default organ costs on new entered costs (CostID = 0)
            if (CostID != 0) return;

            // Get previously selected TransportID, CostType and Amount so possible previously calculated organs can be removed from list before adding the current ones
            int previouslySelectedTransportID = CurrentTransportIDToSelect;
            int previouslySelectedCostTypeID = CurrentCostTypeID;
            Decimal previouslyAssignedAmount = CurrentAmount;

            // Set current selected TransportID and CostTypeID properties
            CurrentTransportIDToSelect = gvTransportsToSelect.SelectedDataKey != null &&
                                         Convert.ToInt32(gvTransportsToSelect.SelectedDataKey.Value) >= 0
                                             ? Convert.ToInt32(gvTransportsToSelect.SelectedDataKey.Value)
                                             : 0;
            CurrentCostTypeID = Convert.ToInt32(Convert.ToInt32(ddlTransportCostType.SelectedValue));
            Decimal amount;
            CurrentAmount = !String.IsNullOrWhiteSpace(txtAmount.Text) && Decimal.TryParse(txtAmount.Text, out amount)
                                ? Convert.ToDecimal(txtAmount.Text)
                                : 0;

            if (!String.IsNullOrWhiteSpace(txtAmount.Text)) txtAmount.Text = CurrentAmount.ToString("N2");

            // Remove previously added Default OrganCosts if necessary
            if ((previouslySelectedTransportID != CurrentTransportIDToSelect)
                || (previouslySelectedCostTypeID != CurrentCostTypeID)
                || (previouslyAssignedAmount != CurrentAmount))
            {
                if (OrganCostList != null) ucOrganCostAllocation.RemoveAutomatedAddedEntries();
            }

            // If adding a new Cost, set default values to organ cost allocations depending on selected CostTypeID
            ucOrganCostAllocation.InitializeOrganCostListWithDefaultOrganCosts(CurrentCostTypeID,
                                                                               CurrentTransportIDToSelect, CurrentAmount);

            // Set Total of initialized OrganCostDistributions in txtAmount.Text if at least one OrganCost is existant (otherwise amount needs to stay as it is because of costs not related to OrganCosts)
            if (ucOrganCostAllocation.CalcTotal && OrganCostList != null && OrganCostList.Count > 0)
            {
                Decimal? totalAmount = ucOrganCostAllocation.OrganCostList.Select(oca => oca.Amount).Sum();
                txtAmount.Text = Convert.ToDecimal(totalAmount).ToString("N2");
            }
        }

        protected void btnAddNewTransportCost_Click(object sender, EventArgs e)
        {
            CostID = 0;

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
                gvTransport.DataBind();
                gvTransportCost.DataBind();
                gvTransportsToSelect.DataBind();
                SelectRowInGridView(gvTransportCost, CostID);
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

                const string message = "Could not save TransportCost! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (gvTransportCost.SelectedDataKey != null)
                {
                    DAL.Cost t = GetCostByID(Convert.ToInt32(gvTransportCost.SelectedDataKey.Value));
                    if (t == null)
                    {
                        throw new NullReferenceException(String.Format("Cost with ID {0} could not be found!", gvTransportCost.SelectedDataKey.Value));
                    }

                    t.IsDeleted = true;
                }
                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgDeleteSuccess, SLIDSMaster.LabelState.Success);

                    // Reset TransportCostID and refresh DataGrid
                    CostID = 0;
                    gvTransportCost.SelectedIndex = -1;
                    gvTransportCost.DataBind();
                    pnlTransportCostDetails.Visible = false;
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

        private decimal totalCost = 0;
        protected void gvTransport_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Align amount cells to the right
                e.Row.Cells[8].HorizontalAlign = HorizontalAlign.Right;

                DAL.Transport transportItem = (DAL.Transport)e.Row.DataItem;
                totalCost += decimal.Parse(GetTotalTransportCosts(transportItem));
            }
            if (e.Row.RowType == DataControlRowType.Footer)
            {
                // Remove of command cell
                e.Row.Cells.RemoveAt(0);

                // Set Total
                Literal lblTotalCosts = (Literal)e.Row.FindControl("lblTotalCosts");
                lblTotalCosts.Text = totalCost.ToString("N2");
                totalCost = 0;
            }
        }

        private decimal totalAmount = 0;
        private decimal totalOrganAllocated = 0;
        protected void gvTransportCost_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Align amount cells to the right
                e.Row.Cells[2].HorizontalAlign = HorizontalAlign.Right;
                e.Row.Cells[3].HorizontalAlign = HorizontalAlign.Right;

                e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink(gvTransportCost,
                                                                                      "Select$" + e.Row.RowIndex);

                DAL.Cost costItem = (DAL.Cost)e.Row.DataItem;
                totalOrganAllocated += decimal.Parse(GetTotalOrganAllocatedCosts(costItem));
                totalAmount += costItem.Amount.HasValue ? costItem.Amount.Value : 0;
            }
            if (e.Row.RowType == DataControlRowType.Footer)
            {
                // Remove of command cell
                e.Row.Cells.RemoveAt(0);

                // Set Total
                Literal lblTotalAmount = (Literal)e.Row.FindControl("lblTotalAmount");
                lblTotalAmount.Text = totalAmount.ToString("N2");
                totalAmount = 0;

                Literal lblTotalOrganAllocated = (Literal)e.Row.FindControl("lblTotalOrganAllocated");
                lblTotalOrganAllocated.Text = totalOrganAllocated.ToString("N2");
                totalOrganAllocated = 0;
            }
        }

        protected void gvTransportsToSelect_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Align amount cells to the right
                e.Row.Cells[8].HorizontalAlign = HorizontalAlign.Right;

                // If Donor is archived prevent user from selecting a different transport row
                if (!DonorIsArchived(Master.DonorID))
                {
                    e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink(gvTransportsToSelect,
                                                                                          "Select$" + e.Row.RowIndex);
                }
            }
        }

        #region Validation

        protected void cvTransportsToSelect_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = ((TransportSelectionIsMandatory && gvTransportsToSelect.SelectedIndex >= 0) ||
                            !TransportSelectionIsMandatory);
        }

        protected void cvCreditor_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = (Convert.ToInt32(ddlCreditor.SelectedValue) > 0 &&
                            String.IsNullOrWhiteSpace(txtKreditorName.Text))
                           ||
                           (Convert.ToInt32(ddlCreditor.SelectedValue) == 0 &&
                            !String.IsNullOrWhiteSpace(txtKreditorName.Text))
                           ||
                           (Convert.ToInt32(ddlCreditor.SelectedValue) == 0 &&
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

            if (c.CostTypeID != null) SetTransportSelectionIsMandatory(Convert.ToInt32(c.CostTypeID));
            PopulateCostDetailView(c);
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();

            OrganCostList = c.OrganCost.ToList();
            ucOrganCostAllocation.BindOrganCostAllocation();
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
            c.TransportID = c.CostType != null && c.CostType.CostGroupID == (int)CostGroup.TransportGlobal
                                ? null
                                : gvTransportsToSelect.SelectedDataKey != null &&
                                  Convert.ToInt32(gvTransportsToSelect.SelectedDataKey.Value) > 0
                                      ? (int?)Convert.ToInt32(gvTransportsToSelect.SelectedDataKey.Value)
                                      : null;
            c.CostTypeID = Convert.ToInt32(ddlTransportCostType.SelectedValue) > 0
                               ? (int?)Convert.ToInt32(ddlTransportCostType.SelectedValue)
                               : null;
            c.CreditorID = Convert.ToInt32(ddlCreditor.SelectedValue) > 0
                               ? (int?)Convert.ToInt32(ddlCreditor.SelectedValue)
                               : null;
            c.Name = !String.IsNullOrWhiteSpace(txtName.Text) ? txtName.Text : String.Empty;
            c.KreditorName = !String.IsNullOrWhiteSpace(txtKreditorName.Text) ? txtKreditorName.Text : null;
            c.InvoiceNo = !String.IsNullOrWhiteSpace(txtInvoiceNo.Text) ? txtInvoiceNo.Text : null;
            c.Amount = !String.IsNullOrWhiteSpace(txtAmount.Text)
                           ? (decimal?)Convert.ToDecimal(txtAmount.Text)
                           : null;
            c.Comment = !String.IsNullOrWhiteSpace(txtComment.Text) ? txtComment.Text : null;

            if (Convert.ToInt32(ddlTransportCostType.SelectedValue) > 0) c.CostType = GetCostTypeByID(Convert.ToInt32(ddlTransportCostType.SelectedValue));
            if (Convert.ToInt32(ddlCreditor.SelectedValue) > 0) c.Creditor = GetCreditorByID(Convert.ToInt32(ddlCreditor.SelectedValue));

            return c;
        }

        private void PopulateCostDetailView(DAL.Cost c)
        {
            if (c == null) throw new Exception("Cost datarow was not provided!");

            ddlTransportCostType.SelectedValue = c.CostTypeID != null
                                                     ? c.CostTypeID.ToString()
                                                     : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            ddlCreditor.SelectedValue = c.CreditorID != null
                                            ? c.CreditorID.ToString()
                                            : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtName.Text = c.Name;
            txtKreditorName.Text = c.KreditorName;
            txtInvoiceNo.Text = c.InvoiceNo;
            txtAmount.Text = c.Amount != null ? Convert.ToDecimal(c.Amount).ToString("N2") : String.Empty;
            txtComment.Text = c.Comment;

            if (TransportSelectionIsMandatory) SelectRowInGridView(gvTransportsToSelect, c.TransportID);
        }

        private void ManageTransportSelection(int costTypeID)
        {
            SetTransportSelectionIsMandatory(costTypeID);
            SetTransportSelectionVisibility();
        }

        private void SetTransportSelectionIsMandatory(int costTypeID)
        {
            DAL.CostGroup cg = GetCostGroupByCostTypeID(costTypeID);

            TransportSelectionIsMandatory = cg != null && cg.ID == (int)CostGroup.Transport || cg == null;
        }

        private void SetTransportSelectionVisibility()
        {
            if (!TransportSelectionIsMandatory) gvTransportsToSelect.SelectedIndex = -1;
            pnlTransportsToSelect.Visible = TransportSelectionIsMandatory;
        }

        private void BindDropDownLists()
        {
            // Cost Type
            ddlTransportCostType.ClearSelection();
            ddlTransportCostType.DataSource =
                Data.CostType.Where(ct => ct.CostGroupID == (int)CostGroup.Transport
                                          || ct.CostGroupID == (int)CostGroup.TransportGlobal).ToList();
            ddlTransportCostType.DataValueField = "ID";
            ddlTransportCostType.DataTextField = "Name";
            ddlTransportCostType.DataBind();
            ddlTransportCostType.Items.Insert(0,
                                              new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                           DropDownDefaultValue.DDL_DEFAULT_VALUE));

            DAL.Cost c = GetCostByID(CostID);

            // Creditor
            int creditorID = c != null && c.CreditorID != null ? (int)c.CreditorID : 0;
            ddlCreditor.ClearSelection();
            ddlCreditor.DataSource = GetCreditors()
                .Where(cr => cr.isActive || cr.ID == creditorID).ToList();
            ddlCreditor.DataValueField = "ID";
            ddlCreditor.DataTextField = "CreditorName";
            ddlCreditor.DataBind();
            ddlCreditor.Items.Insert(0,
                                             new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                          DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void InitialiseCostDetailView()
        {
            gvTransportCost.SelectRow(-1);
            gvTransportsToSelect.DataBind();
            gvTransportsToSelect.SelectRow(-1);
            ddlTransportCostType.SelectedIndex = 0;
            ddlCreditor.SelectedIndex = 0;
            txtName.Text = String.Empty;
            txtKreditorName.Text = String.Empty;
            txtInvoiceNo.Text = String.Empty;
            txtAmount.Text = String.Empty;
            txtComment.Text = String.Empty;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            pnlTransportCostDetails.Visible = true;
            pnlTransportCostDetails.Enabled = !DonorIsArchived(Master.DonorID);

            pnlTransportsToSelect.Visible = TransportSelectionIsMandatory;
            pnlTransportsToSelect.Enabled = !DonorIsArchived(Master.DonorID);

            ucOrganCostAllocation.OrganCostAllocationGridView.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);

            btnSave.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            btnDelete.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && CostID != 0 && !DonorIsArchived(Master.DonorID);

            ddlTransportCostType.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlCreditor.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtName.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtKreditorName.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtInvoiceNo.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtAmount.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtComment.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);

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

            gvTransportCost.DataBind();

            if (gvTransportCost.SelectedIndex >= 0) LoadAndViewDataDetails();
            else pnlTransportCostDetails.Visible = false;
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            CostID = 0;
            gvTransportCost.SelectedIndex = -1;
            gvTransportCost.DataBind();
            pnlTransportCostDetails.Visible = false;
        }
        #endregion
    }
}