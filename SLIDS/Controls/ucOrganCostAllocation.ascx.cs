using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Controls
{
    public partial class ucOrganCostAllocation : UserControl
    {
        #region Properties
        protected bool CostDistributionIsDependingOnNumberOfOrgans = false;
        protected bool CostDistributionIsNotAllocatedToOrgans = false;
        protected bool NumberOfAvailableOrgansFulfillRequirementOfCostDistribution = false;

        public ucOrganCostAllocation()
        {
            CostID = 0;
        }

        public GridView OrganCostAllocationGridView { get { return gvOrganCostAllocation; } }

        protected BasePage BasePage
        {
            get { return new BasePage(); }
        }

        protected SLIDSMaster Master
        {
            get
            {
                // Reference Page that is including this usercontrol
                Page page = Page;

                // Reference MasterPage of Page that is including this usercontrol
                return (SLIDSMaster)page.Master;
            }
        }

        protected int DonorID
        {
            get { return Master == null ? 0 : Master.DonorID; }
        }

        protected int CostID { get; set; }

        protected int CostTypeID
        {
            get { return hidCostTypeID.Value == String.Empty ? 0 : Convert.ToInt32(hidCostTypeID.Value); }
            set { hidCostTypeID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected int? TransportID
        {
            get { return hidTransportID.Value == String.Empty ? (int?)null : Convert.ToInt32(hidTransportID.Value); }
            set { hidTransportID.Value = value == null ? String.Empty : value.ToString(); }
        }

        protected Decimal? Amount
        {
            get { return hidAmount.Value == String.Empty ? (decimal?)null : Convert.ToDecimal(hidAmount.Value); }
            set { hidAmount.Value = value == null ? String.Empty : value.ToString(); }
        }

        public List<OrganCost> OrganCostList { get; set; }

        public bool CalcTotal
        {
            get { return hidCalcTotal.Value != String.Empty && Convert.ToInt32(hidCalcTotal.Value) > 0; }
            set { hidCalcTotal.Value = value ? "1" : "0"; }
        }

        public Decimal? TotalConst
        {
            get { return hidTotalConst.Value == String.Empty ? 0 : Convert.ToDecimal(hidTotalConst.Value); }
            set { hidTotalConst.Value = value.ToString(); }
        }
        #endregion

        public void Initialize(HiddenField hidCostID)
        {
            // Recieve CostId from Page that is including this user control and set value in Property to use it inside this usercontrol
            CostID = Convert.ToInt32(hidCostID.Value);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Disable controls if user is archived
                if (DonorID == 0 || BasePage.DonorIsArchived(DonorID))
                {
                    gvOrganCostAllocation.Enabled = false;
                }
            }

            PopulateOrganCostList();
        }

        public void BindOrganCostAllocation(bool showFooter = false, bool resetEdit = false)
        {
            if (resetEdit)
            {
                gvOrganCostAllocation.EditIndex = -1;
            }
            gvOrganCostAllocation.ShowFooter = showFooter;
            gvOrganCostAllocation.DataSource = OrganCostList;
            gvOrganCostAllocation.DataBind();
        }

        /// <summary>
        ///     Prefill list of OrganCost if default values are provided in OrganCostDistribution
        /// </summary>
        /// <param name="costTypeID">Cost Type ID</param>
        /// <param name="transportID">Transport ID</param>
        /// <param name="amount">Amount</param>
        public void InitializeOrganCostListWithDefaultOrganCosts(int costTypeID, int? transportID = null, Decimal? amount = null)
        {
            // Set Properties
            CostTypeID = costTypeID;
            TransportID = transportID;
            Amount = amount;

            // Initialize OrganCostList if necessary
            if (OrganCostList == null) OrganCostList = new List<OrganCost>();

            CostType ct = BasePage.GetCostTypeByID(costTypeID);
            if (ct == null) return;

            // Get all available organs of donor
            List<TransplantOrgan> toList = BasePage.GetTransplantOrgansByDonorID(DonorID);

            // Allocate costs of constants (organ costs or km) and add Organ to OrganCostList or OrganCostListToRemove
            AllocateOrganCostsByConsts(ct, toList, transportID);

            // Allocate costs by weight using rest amount (of amount) which is not allocated yet
            AllocateOrganCostsByWeight(ct, toList, transportID, amount);

            var org = OrganCostList.Where(l => l.TransplantOrgan.TransplantStatus.Name == "NTX");
            if (org.Count() > 0)
            {
                foreach(var organ in OrganCostList)
                {
                    if(organ.TransplantOrgan.TransplantStatus.Name == "NTX")
                    {
                        organ.Comment = "NTX 50% von " + organ.Amount + "CHF";
                        organ.Amount = organ.Amount / 2;
                        TotalConst = organ.Amount;
                        CalcTotal = true;
                        
                    }
                }
            }

            // Set total amount of constant amounts in case total amount is not set yet and organs have been added to list
            BindOrganCostAllocation();
        }

        public void RemoveAutomatedAddedEntries()
        {
            List<OrganCost> organCostsAddedAutomatically = OrganCostList.Where(oc => oc.AddedByAutomation).ToList();

            foreach (OrganCost oc in organCostsAddedAutomatically)
            {
                OrganCostList.Remove(oc);
            }
        }

        public void AssignOrganCostsToCost()
        {
            List<int> organCostIDsInDB = BasePage.Data.OrganCost.Where(oc => oc.CostID == CostID).Select(oc => oc.ID).ToList();

            // if OrganCostList is empty, remove possible existing Datarows in DB
            if (OrganCostList == null)
            {
                foreach (int organCostIDinDB in organCostIDsInDB)
                {
                    BasePage.Data.OrganCost.Remove(BasePage.GetOrganCostByID(organCostIDinDB));
                }
                return;
            }

            // Loop throu all organCosts but don't take in consideration empty provisional row (which has ID -1)
            foreach (OrganCost organCost in OrganCostList.Where(ocl => ocl.ID >= 0))
            {
                if (organCost.ID == 0)
                {
                    BasePage.Data.OrganCost.Add(organCost);
                }
                else
                {
                    OrganCost oc = BasePage.GetOrganCostByID(organCost.ID);
                    oc.TransplantOrganID = organCost.TransplantOrganID;
                    oc.TransplantOrgan = organCost.TransplantOrgan;
                    oc.Amount = organCost.Amount;
                    oc.Comment = organCost.Comment;
                    oc.CostID = CostID;
                    oc.Cost = organCost.Cost;
                }
            }

            // Remove Datarows in DB if they no longer exist in Updated List
            List<int> organCostIDsInList = OrganCostList.Select(oc => oc.ID).ToList();

            foreach (int organCostIDinDB in organCostIDsInDB)
            {
                bool costOrganIDExists = false;
                foreach (int organCostIDinList in organCostIDsInList)
                {
                    if (organCostIDinList == organCostIDinDB) costOrganIDExists = true;
                }

                if (!costOrganIDExists) BasePage.Data.OrganCost.Remove(BasePage.GetOrganCostByID(organCostIDinDB));
            }
        }

        /// <summary>
        /// Use for dropdownlist validate
        /// </summary>
        protected void cvDropDownList_ServerValidate(object source, ServerValidateEventArgs args)
        {
            // Validate if something is selected in Dropdownlist
            args.IsValid = Convert.ToInt32(args.Value) > 0;
        }

        #region OrganCostList Rowhandling
        /// <summary>
        ///     Binds TransplantOrganDropDownList inside GridView gvOrganCostAllocation
        /// </summary>
        /// <remarks>
        ///     When adding a new organ cost allocation in the list, the DropDownlist will be filled with TransplantOrgans
        ///     After each row creation the dropdwonlist in the footer will be refilled.
        ///     Items are filled twice if DataBind() of DropDownList is called. That's why it's expicitly not called here.
        /// </remarks>
        /// <param name="sender">sender</param>
        /// <param name="e">GridViewRowEventArgs</param>
        protected void gvOrganCostAllocation_RowCreated(object sender, GridViewRowEventArgs e)
        {
            // Bind dropdownlist in footer
            if (e.Row.RowType != DataControlRowType.Footer) return;

            DropDownList ddlFooterTransplantOrgan = e.Row.FindControl("ddlFooterTransplantOrgan") as DropDownList;
            BindTransplantOrganDropDownList(ddlFooterTransplantOrgan);

            if (CalcTotal) CalculateTotalAmountInParentPage();
        }

        public void Save()
        {
            // Adding new row
            if (gvOrganCostAllocation.FooterRow != null && gvOrganCostAllocation.FooterRow.Visible)
            {
                gvOrganCostAllocation_RowCommand(null, new GridViewCommandEventArgs(null, new CommandEventArgs("FooterInsert", null)));
            }

            // Updating existing row
            if (gvOrganCostAllocation.EditIndex != -1)
            {
                gvOrganCostAllocation_RowEditing(null, new GridViewEditEventArgs(gvOrganCostAllocation.EditIndex));
            }

            BindOrganCostAllocation();
        }

        protected void gvOrganCostAllocation_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // On Cancel-click, no validation is required
            if (e.CommandName == "FooterCancel")
            {
                if (OrganCostList != null)
                {
                    // Delete provisional Datarow which was created in case no data existed in the first place to prevent GridView from hiding header and footer
                    DeleteProvisionalEmptyOrganCostAllocationOfList();
                }
                CancelRowUpdate();
                return;
            }

            // Check if entry is valid
            Page.Validate("OrganCostInputGroup");
            if (!Page.IsValid) return;

            if (e.CommandName == "HeaderAddNew")
            {
                // If no data exists in GridView, it must be "fooled" so that header and footer will be displayed (it's hidden per default otherwise)
                if (gvOrganCostAllocation.Rows.Count == 0)
                {
                    AddNewProvisionalEmptyOrganCostAllocationToList();
                }
                BindOrganCostAllocation(true);
            }

            if (e.CommandName == "FooterInsert")
            {
                if (OrganCostList != null)
                {
                    // Delete provisional Datarow which was created in case no data existed in the first place to prevent GridView from hiding header and footer
                    DeleteProvisionalEmptyOrganCostAllocationOfList();
                }

                DropDownList ddlFooterTransplantOrgan = gvOrganCostAllocation.FooterRow.FindControl("ddlFooterTransplantOrgan") as DropDownList;
                TextBox txtFooterAmount = gvOrganCostAllocation.FooterRow.FindControl("txtFooterAmount") as TextBox;
                TextBox txtFooterComment = gvOrganCostAllocation.FooterRow.FindControl("txtFooterComment") as TextBox;

                if (ddlFooterTransplantOrgan != null && txtFooterAmount != null && txtFooterComment != null)
                {
                    AddNewOrganCostAllocationToList(Convert.ToInt32(ddlFooterTransplantOrgan.SelectedValue),
                                                    Convert.ToDecimal(txtFooterAmount.Text), txtFooterComment.Text);

                    BindOrganCostAllocation();
                }
            }
        }

        protected void gvOrganCostAllocation_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvOrganCostAllocation.EditIndex = e.NewEditIndex;

            BindOrganCostAllocation();

            HiddenField hidEditOrganCostID = gvOrganCostAllocation.Rows[gvOrganCostAllocation.EditIndex].FindControl("hidEditOrganCostID") as HiddenField;
            HiddenField hidEditAddedByAutomation = gvOrganCostAllocation.Rows[gvOrganCostAllocation.EditIndex].FindControl("hidEditAddedByAutomation") as HiddenField;
            HiddenField hidEditTransplantOrganID = gvOrganCostAllocation.Rows[gvOrganCostAllocation.EditIndex].FindControl("hidEditTransplantOrganID") as HiddenField;
            DropDownList ddlEditTransplantOrgan = gvOrganCostAllocation.Rows[gvOrganCostAllocation.EditIndex].FindControl("ddlEditTransplantOrgan") as DropDownList;
            TextBox txtEditAmount = gvOrganCostAllocation.Rows[gvOrganCostAllocation.EditIndex].FindControl("txtEditAmount") as TextBox;
            TextBox txtEditComment = gvOrganCostAllocation.Rows[gvOrganCostAllocation.EditIndex].FindControl("txtEditComment") as TextBox;

            if (ddlEditTransplantOrgan == null
                || txtEditAmount == null
                || txtEditComment == null
                || hidEditOrganCostID == null
                || hidEditAddedByAutomation == null
                || hidEditTransplantOrganID == null) return;

            // Bind DropDownList and set SelectedValue
            BindTransplantOrganDropDownList(ddlEditTransplantOrgan, true);
            hidEditOrganCostID.Value = OrganCostList[gvOrganCostAllocation.EditIndex].ID.ToString(CultureInfo.InvariantCulture);
            hidEditAddedByAutomation.Value = OrganCostList[gvOrganCostAllocation.EditIndex].AddedByAutomation
                                                 ? "1"
                                                 : "0";
            hidEditTransplantOrganID.Value = OrganCostList[gvOrganCostAllocation.EditIndex].TransplantOrganID.ToString(); // save TransplantOrganID in hidden field to reset in case of Cancelling update
            ddlEditTransplantOrgan.SelectedValue = OrganCostList[gvOrganCostAllocation.EditIndex].TransplantOrganID.ToString();
            txtEditAmount.Text = OrganCostList[gvOrganCostAllocation.EditIndex].Amount != null
                                     ? Convert.ToDecimal(OrganCostList[gvOrganCostAllocation.EditIndex].Amount).ToString("N2")
                                     : String.Empty;
            txtEditComment.Text = OrganCostList[gvOrganCostAllocation.EditIndex].Comment;
        }

        protected void gvOrganCostAllocation_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            // Set TransplantOrganID back to what it was set when originally clicked on Edit-Button
            HiddenField hidEditTransplantOrganID = gvOrganCostAllocation.Rows[e.RowIndex].FindControl("hidEditTransplantOrganID") as HiddenField;
            if (hidEditTransplantOrganID != null)
            {
                if (hidEditTransplantOrganID.Value != String.Empty)
                {
                    OrganCostList[e.RowIndex].TransplantOrganID = Convert.ToInt32(hidEditTransplantOrganID.Value);
                    OrganCostList[e.RowIndex].TransplantOrgan = BasePage.GetTransplantOrganByID(Convert.ToInt32(hidEditTransplantOrganID.Value));
                }
            }

            CancelRowUpdate();
        }

        protected void gvOrganCostAllocation_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            Page.Validate("OrganCostInputGroup");
            if (!Page.IsValid) return;

            DropDownList ddlEditTransplantOrgan = gvOrganCostAllocation.Rows[e.RowIndex].FindControl("ddlEditTransplantOrgan") as DropDownList;
            TextBox txtEditAmount = gvOrganCostAllocation.Rows[e.RowIndex].FindControl("txtEditAmount") as TextBox;
            TextBox txtEditComment = gvOrganCostAllocation.Rows[e.RowIndex].FindControl("txtEditComment") as TextBox;

            if (ddlEditTransplantOrgan != null && txtEditAmount != null && txtEditComment != null)
            {
                OrganCostList[e.RowIndex].TransplantOrganID = Convert.ToInt32(ddlEditTransplantOrgan.SelectedValue);
                OrganCostList[e.RowIndex].Amount = Convert.ToDecimal(txtEditAmount.Text);
                OrganCostList[e.RowIndex].Comment = txtEditComment.Text;
            }

            gvOrganCostAllocation.EditIndex = -1;
            BindOrganCostAllocation();

            if (CalcTotal) CalculateTotalAmountInParentPage();
        }

        protected void gvOrganCostAllocation_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            OrganCostList.RemoveAt(e.RowIndex);

            // Keep total amount and re-distribute total amount to remaining organs
            if (!CalcTotal)
            {
                // Use available transplant organs in OrganCostList as reference organ cost list
                // to recalculate cost allocation
                List<TransplantOrgan> toList = GetTransplantOrgansFromOrganCostList();

                // Remove all entries added by automation
                RemoveAutomatedAddedEntries();

                CostType ct = BasePage.GetCostTypeByID(CostTypeID);
                if (ct != null)
                {
                    AllocateOrganCostsByConsts(ct, toList, TransportID);
                    AllocateOrganCostsByWeight(ct, toList, TransportID, Amount);
                }
            }

            gvOrganCostAllocation.EditIndex = -1;
            BindOrganCostAllocation();

            if (CalcTotal) CalculateTotalAmountInParentPage();
        }

        protected void gvOrganCostAllocation_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header)
            {
                // Set Right-Align to Button "Add New..." in Header
                e.Row.Cells[3].HorizontalAlign = HorizontalAlign.Right;

                var cellWidth = new Unit("20em");
                e.Row.Cells[0].Width = cellWidth;
                e.Row.Cells[1].Width = cellWidth;
                e.Row.Cells[2].Width = cellWidth;
            }

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Align amount to the right
                e.Row.Cells[1].HorizontalAlign = HorizontalAlign.Right;

                // Hide provisional created row when no data exists so that header and footer are not hidden
                if (OrganCostList != null)
                {
                    // Delete provisional Datarow which was created in case no data existed in the first place to prevent GridView from hiding header and footer
                    OrganCost provisionalOrganCost = GetProvisionalEmptyOrganCostAllocation();
                    if (provisionalOrganCost != null) e.Row.Visible = false;
                }
            }
        }
        #endregion

        #region Privates
        /// <summary>
        ///     Adds new OrganCost to List
        /// </summary>
        /// <param name="transplantOrganID">Organ ID</param>
        /// <param name="amount">Amount</param>
        /// <param name="comment">Comment</param>
        /// <param name="organCostID">OrganCostID</param>
        /// <param name="addedByAutomation">addedByAutomation</param>
        /// <param name="isDistributedByWeight">is cost allocation done by weight? (this information is used for rounding purposes)</param>
        private void AddNewOrganCostAllocationToList(int transplantOrganID, decimal? amount, string comment = null,
                                                     int? organCostID = null, bool addedByAutomation = false,
                                                     bool isDistributedByWeight = false)
        {
            OrganCost oc = new OrganCost
                {
                    ID = organCostID != null ? Convert.ToInt32(organCostID) : 0,
                    CostID = CostID,
                    Cost = BasePage.GetCostByID(CostID),
                    TransplantOrganID = transplantOrganID,
                    TransplantOrgan = BasePage.GetTransplantOrganByID(transplantOrganID),
                    Amount = amount ?? 0,
                    Comment = !String.IsNullOrWhiteSpace(comment) ? comment : null,
                    AddedByAutomation = addedByAutomation,
                    IsDistributedByWeight = isDistributedByWeight,
                };

            if (OrganCostList == null) OrganCostList = new List<OrganCost>();
            OrganCostList.Add(oc);
        }

        private void AddNewProvisionalEmptyOrganCostAllocationToList()
        {
            if (OrganCostList == null) OrganCostList = new List<OrganCost>();
            OrganCost oc = new OrganCost { ID = -1 };
            OrganCostList.Add(oc);
        }

        private OrganCost GetProvisionalEmptyOrganCostAllocation()
        {
            return OrganCostList.SingleOrDefault(oc => oc.ID == -1);
        }

        /// <summary>
        ///     Returns a list of TransplantOrgan from OrganCostList
        /// </summary>
        /// <returns>List of TransplantOrgan taken from OrganCostList</returns>
        private List<TransplantOrgan> GetTransplantOrgansFromOrganCostList()
        {
            return OrganCostList
                .Where(ocl => ocl.AddedByAutomation)
                .Select(oc => BasePage.GetTransplantOrganByID(Convert.ToInt32(oc.TransplantOrganID))).ToList();
        }

        private void DeleteProvisionalEmptyOrganCostAllocationOfList()
        {
            if (OrganCostList == null) return;

            OrganCost provisionalOrganCost = GetProvisionalEmptyOrganCostAllocation();
            if (provisionalOrganCost != null) OrganCostList.Remove(provisionalOrganCost);
        }

        private void CancelRowUpdate()
        {
            gvOrganCostAllocation.EditIndex = -1;
            BindOrganCostAllocation();
        }

        /// <summary>
        ///     Populate OrganCostList from GridView
        /// </summary>
        /// <remarks>
        ///     Because OrganCostList is generic and not serializable through entity framework, list has to be repopulated after every postback.
        /// </remarks>
        private void PopulateOrganCostList()
        {
            foreach (GridViewRow row in gvOrganCostAllocation.Rows)
            {
                // Populate list from GridView in "standard" view
                HiddenField hidOrganCostID = row.Cells[0].FindControl("hidOrganCostID") as HiddenField;
                HiddenField hidOrganID = row.Cells[0].FindControl("hidOrganID") as HiddenField;
                HiddenField hidAddedByAutomation = row.Cells[0].FindControl("hidAddedByAutomation") as HiddenField;
                bool addedByAutomation = hidAddedByAutomation != null && Convert.ToInt32(hidAddedByAutomation.Value) > 0;
                Label lblAmount = row.Cells[1].FindControl("lblAmount") as Label;
                Decimal? amount = lblAmount != null && !String.IsNullOrWhiteSpace(lblAmount.Text)
                                      ? (decimal?)Convert.ToDecimal(lblAmount.Text)
                                      : null;
                Label lblComment = row.Cells[2].FindControl("lblComment") as Label;
                if (hidOrganCostID != null && hidOrganID != null && lblAmount != null && lblComment != null && hidAddedByAutomation != null)
                {
                    AddNewOrganCostAllocationToList(Convert.ToInt32(hidOrganID.Value), amount, lblComment.Text,
                                                    Convert.ToInt32(hidOrganCostID.Value), addedByAutomation);
                }

                // Populate list from GridView in "edit" view
                HiddenField hidEditOrganCostID = row.Cells[0].FindControl("hidEditOrganCostID") as HiddenField;
                DropDownList ddlEditTransplantOrgan = row.Cells[0].FindControl("ddlEditTransplantOrgan") as DropDownList;
                HiddenField hidEditAddedByAutomation =
                    row.Cells[0].FindControl("hidEditAddedByAutomation") as HiddenField;
                addedByAutomation = false;
                if (hidEditAddedByAutomation != null && hidEditAddedByAutomation.Value != string.Empty)
                {
                    addedByAutomation = Convert.ToInt32(hidEditAddedByAutomation.Value) > 0;
                }
                TextBox txtEditAmount = row.Cells[1].FindControl("txtEditAmount") as TextBox;
                TextBox txtEditComment = row.Cells[2].FindControl("txtEditComment") as TextBox;
                if (hidEditOrganCostID != null && ddlEditTransplantOrgan != null && txtEditAmount != null &&
                    txtEditComment != null && hidEditAddedByAutomation != null)
                {
                    if (ddlEditTransplantOrgan.SelectedValue != string.Empty && hidEditOrganCostID.Value != String.Empty && txtEditAmount.Text != string.Empty)
                    {
                        // Amount needs to be decimal, so here we make sure it's format will fit or else we fill null
                        decimal tmpvalue;
                        decimal? result = decimal.TryParse(txtEditAmount.Text, out tmpvalue)
                                              ? tmpvalue
                                              : (decimal?)null;

                        AddNewOrganCostAllocationToList(Convert.ToInt32(ddlEditTransplantOrgan.SelectedValue), result,
                                                        txtEditComment.Text, Convert.ToInt32(hidEditOrganCostID.Value),
                                                        addedByAutomation);
                    }
                }
            }
        }

        private void BindTransplantOrganDropDownList(DropDownList ddlTransplantOrgan, bool callDataBind = false)
        {
            if (ddlTransplantOrgan == null) return;

            // Select TransplantOrganID and Organ.Name (to display) for DropDownList
            var transplantOrgan = from to in BasePage.GetTransplantOrgansByDonorID(DonorID)
                                  select new
                                      {
                                          to.ID,
                                          to.Organ.Name
                                      };

            ddlTransplantOrgan.ClearSelection();
            ddlTransplantOrgan.DataSource = transplantOrgan.ToList();
            ddlTransplantOrgan.DataValueField = "ID";
            ddlTransplantOrgan.DataTextField = "Name";
            ddlTransplantOrgan.AppendDataBoundItems = true;
            ddlTransplantOrgan.Items.Insert(0,
                                            new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                         DropDownDefaultValue.DDL_DEFAULT_VALUE));
            if (callDataBind) ddlTransplantOrgan.DataBind();
        }

        private void AllocateOrganCostsByConsts(CostType ct, List<TransplantOrgan> toList, int? transportID)
        {
            // Loop through all CostDistributions for given CostType
            foreach (CostDistribution cd in ct.CostDistribution)
            {
                List<TransplantOrgan> relevantTransplantOrganList = GetRelevantTransplantOrgans(toList, cd,
                                                                                                Convert.ToInt32(
                                                                                                    transportID),
                                                                                                ct.CostGroupID);

                // Loop through all available and relevant organs of donor and check if any OrganCostDistributions are available. 
                // If so, add organ to OrganList and calculate or set given amount in OrganCostList and display everything accordingly
                foreach (TransplantOrgan to in relevantTransplantOrganList)
                {
                    // Get all available OrganCostDistributions of given Organ and CostDistribution
                    OrganCostDistribution ocd = BasePage.GetOrganCostDistributionByOrganIDAndCostDistributionID(to.OrganID, cd.ID);

                    if (ocd != null && ocd.Const != null)
                    {
                        // Add new OrganCostAllocation by Const
                        AddNewOrganCostAllocationByConst(to, ocd);

                        // Set property which will be used to decide wether or not Total Amount in GUI will be updated with Total Amount of OrganCostList-Amount-Total
                        CalcTotal = cd.CalcTotal;
                        if (cd.TotalConst != null) TotalConst = cd.TotalConst;
                    }

                    if (ocd == null || ocd.ConstPerKm == null || transportID == null) continue;

                    // Add new OrganCostAllocation by ConstPerKm
                    AddNewOrganCostAllocationByConstPerKm(Convert.ToInt32(transportID), cd.VehicleID, to, ocd);

                    // Set property which will be used to decide wether or not Total Amount in GUI will be updated with Total Amount of OrganCostList-Amount-Total
            

                        CalcTotal = cd.CalcTotal;
              
                    if (cd.TotalConst != null) TotalConst = cd.TotalConst;
                }
            }
        }

        private void AllocateOrganCostsByWeight(CostType ct, List<TransplantOrgan> toList, int? transportID, Decimal? amount)
        {
            // Allocate costs by weight after const-amounts are deducted from total amount and use this amount to calculate costs by weight
            Decimal? allocatedSumInOrganCostList =
                OrganCostList.Select(ocl => ocl.Amount).Sum();

            Decimal restAmountToAllocate = Convert.ToDecimal(amount) - Convert.ToDecimal(allocatedSumInOrganCostList);
            if (restAmountToAllocate < 0) restAmountToAllocate = 0;

            // Loop through all CostDistributions for given CostType
            foreach (CostDistribution cd in ct.CostDistribution)
            {
                List<TransplantOrgan> relevantTransplantOrganList = GetRelevantTransplantOrgans(toList, cd,
                                                                                                Convert.ToInt32(transportID),
                                                                                                ct.CostGroupID);

                // If CostDistribution has set min- and max-organ requirements check if total organs match the criteria. Else leave loop
                if (!NumberOfTransplantOrgansMatchRequirementsOfCostDistribution(cd, relevantTransplantOrganList.Count))
                    continue;

                // Set TotalConst if cost distribution is depending on a certain number of available organs and the number machtes the requirement
                // or when cost distribution is not depending on a certain number of available organs but TotalConst is set
                if ((CostDistributionIsDependingOnNumberOfOrgans && NumberOfAvailableOrgansFulfillRequirementOfCostDistribution)
                    || !CostDistributionIsDependingOnNumberOfOrgans)
                {
                    if (cd.TotalConst != null)
                    {
                        // Set Property

                   
                        TotalConst = cd.TotalConst;

                        // Reference Page that is including this usercontrol
                        Page page = Page;

                        // Set txtAmount of parent page
                        Decimal? manuallyAddedOrcanCosts = OrganCostList.Where(ocl => !ocl.AddedByAutomation).Select(ocl => ocl.Amount).Sum();
                        Decimal? totalOrganCostsInOrganCostList = manuallyAddedOrcanCosts + cd.TotalConst;
                        TextBox txtAmount = SearchControl(page, "txtAmount") as TextBox;
                        if (txtAmount != null) txtAmount.Text = Convert.ToDecimal(totalOrganCostsInOrganCostList).ToString("N2");
                    }
                }

                // If CostDistribution has a set Amount, add it to restAmountToAllocate
                if (cd.TotalConst > 0) restAmountToAllocate += Convert.ToDecimal(cd.TotalConst);

                // Loop through all available organs of donor and check if any OrganCostDistributions are available,
                // taking in consideration if only organs in status TX are required depending on CostDistribution setting. 
                // If so, add organ to OrganList and calculate or set given amount in OrganCostList and display everything accordingly
                foreach (TransplantOrgan to in relevantTransplantOrganList)
                {
                    // Get all available OrganCostDistributions of given Organ and CostDistribution
                    OrganCostDistribution ocd =
                        BasePage.GetOrganCostDistributionByOrganIDAndCostDistributionID(to.OrganID, cd.ID);

                    if ((ct.CostGroupID == Convert.ToInt32(BasePage.CostGroup.Transport) && ocd != null &&
                         ocd.Weight != null && transportID != null && amount != null)
                        ||
                        (ct.CostGroupID != Convert.ToInt32(BasePage.CostGroup.Transport) && ocd != null &&
                         ocd.Weight != null))
                    {
                        // Add new OrganCostAllocation by Weight
                        AddNewOrganCostAllocationToList(to.ID,
                                                        CalculateCostPerWeight(relevantTransplantOrganList,
                                                                               restAmountToAllocate,
                                                                               Convert.ToInt32(ocd.Weight), cd.ID),
                                                        addedByAutomation: true, isDistributedByWeight: true);
                    }
                }

                // Balance any difference that might have occured because of rounding
                BalanceRoundingDifference(restAmountToAllocate);
            }

            // Set error message if CostDistribution is depending on number of organs but number of organs are not matching any criterias of available CostDistributions
            if (CostDistributionIsDependingOnNumberOfOrgans &&
                !NumberOfAvailableOrgansFulfillRequirementOfCostDistribution)
                Master.SetInfoLabel(StatusMessages.MsgNumberOfTransplantOrgansDontMatchRequirementsOfCostDistribution);
        }

        private List<TransplantOrgan> GetRelevantTransplantOrgans(ICollection<TransplantOrgan> unfilteredTransplantOrganList,
                                                                  CostDistribution cd,
                                                                  int transportID,
                                                                  int costGroupID)
        {
            int statusTX = Convert.ToInt32(BasePage.TransplantStatus.TX);
            int statusNTX = Convert.ToInt32(BasePage.TransplantStatus.NTX);
            bool referOnlyOnTransplantedOrgans = cd.ReferOnlyOnTransplantedOrgans;

            List<TransplantOrgan> relevantTransplantOrganList = new List<TransplantOrgan>();

            if (costGroupID == Convert.ToInt32(BasePage.CostGroup.Transport))
            {
                DAL.Transport t = BasePage.GetTransportByID(Convert.ToInt32(transportID));
                if (t == null) return relevantTransplantOrganList;

                // Create a List of TRANSPORTED transplantOrgans where TransplantStatusID needs to be considered depending on setting of CostDistribution (or not, if it's not set).
                // With this collection the total number of weights will be extracted to calculate the pro-rata amount for the given TransplantOrgan to
                relevantTransplantOrganList = t.TransportedOrgan
                                               .Where(to => t.VehicleID == cd.VehicleID)
                                               .Where(to => referOnlyOnTransplantedOrgans && to.TransplantOrgan.TransplantStatusID == statusTX || !referOnlyOnTransplantedOrgans)
                                               .Select(to => to.TransplantOrgan)
                                               .Where(unfilteredTransplantOrganList.Contains).ToList();

                // Add associated TransplantOrgans of transported items in given transport to relevantOrganList when organ is not already in the list
                foreach (TransportItem transportItem in t.TransportItem)
                {
                    foreach (OrganToTransportItemAssociation organToTransportItemAssociation in transportItem.OrganToTransportItemAssociation.Where(ot => ot.OrganID != null))
                    {
                        TransplantOrgan associatedOrgan = organToTransportItemAssociation
                            .Organ
                            .TransplantOrgan
                            .Where(to => t.VehicleID == cd.VehicleID)
                            .Where(to => referOnlyOnTransplantedOrgans && to.TransplantStatusID == statusTX || !referOnlyOnTransplantedOrgans)
                            .Where(unfilteredTransplantOrganList.Contains)
                            .FirstOrDefault(to => !relevantTransplantOrganList.Contains(to));

                        if (associatedOrgan != null && relevantTransplantOrganList.Count(rto => rto.OrganID == associatedOrgan.OrganID) == 0) relevantTransplantOrganList.Add(associatedOrgan);
                    }
                }

              
            }

            // Create a list of GENERAL transplantOrgans where TransplantStatusID needs to be considered depending on setting of CostDistribution (or not, if it's not set).
            // With this collection the total number of weights will be extracted to calculate the pro-rata amount for the given TransplantOrgan to
            
            if(cd.CostType.Name.Contains("Explant-team external") || cd.CostType.Name.Contains("Explant-team internal"))
            {
                relevantTransplantOrganList = unfilteredTransplantOrganList.ToList();
            }
            else
            {
                relevantTransplantOrganList =
                     unfilteredTransplantOrganList.Where(
                         tol =>
                         referOnlyOnTransplantedOrgans && tol.TransplantStatusID == statusTX
                          || !referOnlyOnTransplantedOrgans).ToList();
            }

            return relevantTransplantOrganList;
        }

        private void AddNewOrganCostAllocationByConst(TransplantOrgan to, OrganCostDistribution ocd)
        {
            AddNewOrganCostAllocationToList(to.ID, ocd.Const, addedByAutomation: true);
        }

        private void AddNewOrganCostAllocationByConstPerKm(int transportID,
                                                           int? vehicleID,
                                                           TransplantOrgan to,
                                                           OrganCostDistribution ocd)
        {
            // Add new OrganCostAllocation by ConstPerKm
            DAL.Transport t = BasePage.GetTransportByID(Convert.ToInt32(transportID));
            if (t == null) return;

            if (t.VehicleID != vehicleID) return;

            int distance = t.Distance == null ? 0 : Convert.ToInt32(t.Distance);

            AddNewOrganCostAllocationToList(to.ID,
                                            CalculateCostPerKm(distance,
                                                               Convert.ToDecimal(ocd.ConstPerKm)),
                                            addedByAutomation: true);
        }

        /// <summary>
        ///     Calculates Cost for TransplantOrgan by Km
        /// </summary>
        /// <param name="distance">Distance in Km</param>
        /// <param name="constPerKm">Allocated cost per Km</param>
        /// <returns>Cost for the distance</returns>
        private Decimal CalculateCostPerKm(int distance, Decimal constPerKm)
        {
            return distance * constPerKm;
        }

        /// <summary>
        ///     Calculates Cost for TransplantOrgan by Weight
        /// </summary>
        /// <param name="transplantOrgans">Collection of TransplantOrgans to get the total number of Weight from all available TransplantOrgans</param>
        /// <param name="amount">Total amount which will be distributed on TransplantOrgans</param>
        /// <param name="weight">Weight of given TransplantOrgan</param>
        /// <param name="costTypeID">CostTypeID</param>
        /// <returns>Cost in relation of total number of weight and given TransplantOrgan weight</returns>
        private Decimal CalculateCostPerWeight(IEnumerable<TransplantOrgan> transplantOrgans, Decimal amount, int weight, int costTypeID)
        {
            if (amount == 0) return 0;

            int totalWeight = GetTotalOrganCostDistributionWeightOfTransplantOrgans(transplantOrgans, costTypeID);

            if (totalWeight == 0) return 0;

            Decimal costByWeight = Convert.ToDecimal(amount) / totalWeight * Convert.ToInt32(weight);

            return Math.Round(costByWeight);
        }

        /// <summary>
        ///     Gets the total weight number in OrganCostDistribution of given TransplantOrgans
        /// </summary>
        /// <param name="transplantOrgans">Collection of type TransplantOrgan</param>
        /// <param name="costTypeID">CostTypeID</param>
        /// <returns>Total number of weight</returns>
        private int GetTotalOrganCostDistributionWeightOfTransplantOrgans(IEnumerable<TransplantOrgan> transplantOrgans, int costTypeID)
        {
            int totalWeight = 0;
            foreach (TransplantOrgan to in transplantOrgans)
            {
                OrganCostDistribution ocd = BasePage.GetOrganCostDistributionByOrganIDAndCostDistributionID(to.OrganID, costTypeID);
                if (ocd != null && ocd.Weight != null) totalWeight += Convert.ToInt32(ocd.Weight);
            }

            return totalWeight;
        }

        /// <summary>
        ///     Sets the recalculated total amount of parent page
        /// </summary>
        private void CalculateTotalAmountInParentPage()
        {
            // If OrganCostList doesn't exists there's nothing to calculate
            if (OrganCostList == null) return;

            // Reference Page that is including this usercontrol
            Page page = Page;

            // Update txtAmount of parent page
            TextBox txtAmount = SearchControl(page, "txtAmount") as TextBox;
            if (txtAmount == null) return;

            Decimal? totalAmount = OrganCostList.Select(oca => oca.Amount).Sum();
            txtAmount.Text = Convert.ToDecimal(totalAmount).ToString("N2");

            HiddenField hidCurrentAmount = SearchControl(page, "hidAmount") as HiddenField;
            if (hidCurrentAmount != null) hidCurrentAmount.Value = txtAmount.Text;
        }

        /// <summary>
        ///     Compare total amount to distribute with the total amount of the rounded distributed amounts. If there's a difference, balance the difference with one OrganCost
        /// </summary>
        /// <param name="totalAmount"></param>
        private void BalanceRoundingDifference(Decimal totalAmount)
        {
            // Extract total amount of OrganCosts distributed by weight (every OrganCost amount is already rounded)
            List<OrganCost> OrganCostListByWeight =
                OrganCostList.Where(oca => oca.AddedByAutomation && oca.IsDistributedByWeight).ToList();
            Decimal? totalAmountOfWeightDistribution = OrganCostListByWeight.Select(oca => oca.Amount).Sum();

            Decimal difference = totalAmount - Convert.ToDecimal(totalAmountOfWeightDistribution);

            if (difference == 0) return;

            // Compensate difference onto first element
            OrganCost oc = OrganCostList.LastOrDefault(oca => oca.AddedByAutomation && oca.IsDistributedByWeight);

            if (oc != null && oc.Amount != null) oc.Amount += difference;
        }

        /// <summary>
        ///     Search control recursively in container using it's control id
        /// </summary>
        /// <param name="container">Parent Control</param>
        /// <param name="id">Control ID</param>
        /// <returns></returns>
        private static Control SearchControl(Control container, string id)
        {
            Control control = container.FindControl(id);
            if (control == null)
            {
                foreach (Control c in container.Controls)
                {
                    if (!c.HasControls()) continue;

                    control = SearchControl(c, id);
                    if (control != null) break;
                }
            }
            return control;
        }

        /// <summary>
        ///     If CostDistribution is depending on number of available organs check if number of transplant organs match requirement
        /// </summary>
        /// <param name="cd">CostDistribution</param>
        /// <param name="numberOfTransplantOrgans">number of transplant organs to match</param>
        /// <returns>True, if number of transplant organs match requirements of cost distribution. False, otherwise</returns>
        private bool NumberOfTransplantOrgansMatchRequirementsOfCostDistribution(CostDistribution cd, int numberOfTransplantOrgans)
        {
            if (cd.MinOrganCount != null)
            {
                CostDistributionIsDependingOnNumberOfOrgans = true;
                // Get number of TransplantOrgans of Donor
                //int numberOfTransplantOrgans = CountTransplantOrgans(DonorID, cd.ReferOnlyOnTransplantedOrgans);

                // Check if number of available TransplantOrgans are fulfilled in CostDistribution settings.
                if (((cd.MaxOrganCount != null && numberOfTransplantOrgans <= cd.MaxOrganCount) ||
                     cd.MaxOrganCount == null) && numberOfTransplantOrgans >= cd.MinOrganCount)
                {
                    NumberOfAvailableOrgansFulfillRequirementOfCostDistribution = true;
                    if (numberOfTransplantOrgans == 0 && cd.MinOrganCount == 0 && cd.MaxOrganCount == 0)
                        CostDistributionIsNotAllocatedToOrgans = true;

                    return true;
                }

                return false;
            }

            return true;
        }
        #endregion
    }
}