using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Administration
{
    public partial class ManageTransportItems : BasePage
    {
        #region Properties
        protected int TransportItemID
        {
            get { return hidTransportItemID.Value == String.Empty ? 0 : Convert.ToInt32(hidTransportItemID.Value); }
            set { hidTransportItemID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        public List<OrganToTransportItemAssociation> OrganToTransportItemAssociationList { get; set; }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Manage Transport Items called");

            PopulateOrganToTransportItemAssociationList();

            if (IsPostBack) return;

            BindItemGroupDropDownList();
        }

        public IQueryable<TransportItem> gvTransportItem_GetData()
        {
            return GetTransportItems()
                .Where(ti => !cbIncludeInactive.Checked && ti.isActive || cbIncludeInactive.Checked);
        }

        protected void gvTransportItem_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvTransportItem.SelectedIndex == -1 || gvTransportItem.SelectedDataKey == null) return;

            TransportItemID = Convert.ToInt32(gvTransportItem.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void cbIncludeInactive_CheckedChanged(object sender, EventArgs e)
        {
            // Rebind GridView of TransportITem (to include or exclude inactive transport items)
            gvTransportItem.DataBind();

            if (TransportItemID > 0)
            {
                SelectRowInGridView(gvTransportItem, TransportItemID);
            }
            else
            {
                gvTransportItem.DataBind();
            }
        }

        protected void btnAddNewTransportItem_Click(object sender, EventArgs e)
        {
            TransportItemID = 0;

            gvTransportItem.SelectRow(-1);

            InitialiseTransportItemDetailView();

            // Clear OrganToTransportItemAssociation list
            if (OrganToTransportItemAssociationList != null) OrganToTransportItemAssociationList.Clear();

            // Initialise OrganToTransportItemAssociation
            if (OrganToTransportItemAssociationList == null) OrganToTransportItemAssociationList = new List<OrganToTransportItemAssociation>();
            BindOrganToTransportItem();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                bool isRowAdded = TransportItemID == 0;
                TransportItem transportItem;

                if (isRowAdded)
                {
                    // create new datarow
                    transportItem = new TransportItem();
                    Data.TransportItem.Add(transportItem);
                }
                else
                {
                    // update existing datarow
                    transportItem = GetTransportItemByID(TransportItemID);
                }

                SaveDataAndRefreshGUI(transportItem);
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

                const string message = "Could not save TransportItem! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected void btnActiveHandling_Click(object sender, EventArgs e)
        {
            try
            {
                TransportItem transportItem = GetTransportItemByID(TransportItemID);
                if (transportItem == null) throw new ArgumentNullException(String.Format("TransportItem with ID {0} could not be found!", TransportItemID));

                transportItem.isActive = !transportItem.isActive;

                cbIncludeInactive.Checked = !transportItem.isActive;

                SaveDataAndRefreshGUI(transportItem);
            }
            catch (DbUpdateConcurrencyException concurrencyEx)
            {
                HandlePageRefreshAfterConcurrencyException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + concurrencyEx.Message);
            }
            catch (NullReferenceException nullReferenceEx)
            {
                // record has been inactivated in the meantime!
                HandlePageRefreshAfterNullReferenceException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyInactiveNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + nullReferenceEx.Message);
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not archive or reactivate TransportItem! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        #region Privates
        private void BindItemGroupDropDownList()
        {
            ddlItemGroup.ClearSelection();
            ddlItemGroup.DataSource = GetItemGroupsByType((int)ItemGroupType.TransportItem).Where(o => o.isActive).ToList();
            ddlItemGroup.DataValueField = "ID";
            ddlItemGroup.DataTextField = "Name";
            ddlItemGroup.DataBind();
            ddlItemGroup.Items.Insert(0,
                                  new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                               DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void LoadAndViewDataDetails()
        {
            TransportItem transportItem = GetTransportItemByID(TransportItemID);
            if (transportItem == null) return;

            LoadAndViewDataDetails(transportItem);
        }

        private void LoadAndViewDataDetails(TransportItem transportItem)
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(transportItem);
            PopulateDetailView(transportItem);
        }

        private void PopulateDetailView(TransportItem transportItem)
        {
            if (transportItem == null) throw new Exception("TransportItem datarow was not provided!");

            PopulateTransportItemDetailControls(transportItem);

            PopulateOrganToTransportItemAssociationControls(transportItem);
        }

        private void PopulateTransportItemDetailControls(TransportItem transportItem)
        {
            if (transportItem == null) throw new Exception("TransportItem datarow was not provided!");

            ddlItemGroup.SelectedValue = transportItem.ItemGroupID != null
                                             ? transportItem.ItemGroupID.ToString()
                                             : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtName.Text = transportItem.Name;
            txtCountableAs.Text = transportItem.CountableAs.ToString();
            txtPosition.Text = transportItem.Position.ToString();

            btnActiveHandling.Text = transportItem.isActive ? "Set inactive" : "Activate";
        }

        private void PopulateOrganToTransportItemAssociationControls(TransportItem transportItem)
        {
            // Clear Organ cost list
            if (OrganToTransportItemAssociationList != null) OrganToTransportItemAssociationList.Clear();

            OrganToTransportItemAssociationList = transportItem.OrganToTransportItemAssociation.ToList();
            BindOrganToTransportItem();
        }

        private void SaveDataAndRefreshGUI(TransportItem transportItem)
        {
            if (transportItem == null) throw new Exception("TransportItem datarow was not provided!");

            AssignValuesToTransportItem(transportItem);

            SaveOrganToTransportItemAssociation();

            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            TransportItemID = transportItem.ID;

            LoadAndViewDataDetails(transportItem);

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvTransportItem, transportItem.ID);
        }

        private void AssignValuesToTransportItem(TransportItem transportItem)
        {
            if (transportItem == null) throw new Exception("TransportItem datarow was not provided!");

            transportItem.ItemGroupID = Convert.ToInt32(ddlItemGroup.SelectedValue);
            transportItem.Name = !String.IsNullOrWhiteSpace(txtName.Text) ? txtName.Text : null;
            transportItem.CountableAs = !String.IsNullOrWhiteSpace(txtCountableAs.Text) ? (int?)Convert.ToInt32(txtCountableAs.Text) : null;
            transportItem.Position = !String.IsNullOrWhiteSpace(txtPosition.Text) ? (int?)Convert.ToInt32(txtPosition.Text) : null;

            if (TransportItemID == 0) transportItem.isActive = true;
        }

        private void InitialiseTransportItemDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(null);

            txtName.Text = String.Empty;
            txtCountableAs.Text = String.Empty;
            txtPosition.Text = String.Empty;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(TransportItem transportItem)
        {
            pnlTransportItemDetails.Visible = true;
            btnActiveHandling.Visible = TransportItemID != 0;
            btnSave.Visible = Master.IsAdmin && ((transportItem != null && transportItem.isActive) || TransportItemID == 0);

            bool enable = Master.IsAdmin && ((transportItem != null && transportItem.isActive) || TransportItemID == 0);
            // Disable or enable controls inside detail panel one by one in order to handle enable-state of btnArchiveHandling (instead of simply enabling or disabling its panel itself)
            EnableOrDisableControls(pnlTransportItemDetails, enable);
            // always allow archive or reactivate
            btnActiveHandling.Enabled = true;
        }

        /// <summary>
        ///     Jumps to Page of DataGridView with given ID in GridView and select its row
        /// </summary>
        /// <param name="gv">GridView in which selection is taking part of</param>
        /// <param name="itemID">Item ID in GridView</param>
        new private void SelectRowInGridView(GridView gv, int itemID)
        {
            if (!BasePage.SelectRowInGridView(gv, itemID))
            {
                TransportItemID = 0;
                InitialiseTransportItemDetailView();
                pnlTransportItemDetails.Visible = false;
            }
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvTransportItem, TransportItemID);
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            TransportItemID = 0;
            gvTransportItem.SelectedIndex = -1;
            gvTransportItem.DataBind();
            pnlTransportItemDetails.Visible = false;
        }
        #endregion

        #region OrganToTransportItemAssociation

        #region Rowhandling
        protected void gvOrganToTransportItemAssociation_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // On Cancel-click, no validation is required
            if (e.CommandName == "FooterCancel")
            {
                if (OrganToTransportItemAssociationList != null)
                {
                    // Delete provisional Datarow which was created in case no data existed in the first place to prevent GridView from hiding header and footer
                    DeleteProvisionalEmptyOrganToTransportItemAssociationOfList();
                }
                CancelRowUpdate();
                return;
            }

            // Check if entry is valid
            Page.Validate("OrganToTransportItemAssociationInputGroup");
            if (!Page.IsValid) return;

            if (e.CommandName == "HeaderAddNew")
            {
                // If no data exists in GridView, it must be "fooled" so that header and footer will be displayed (it's hidden per default otherwise)
                if (gvOrganToTransportItemAssociation.Rows.Count == 0)
                {
                    AddNewProvisionalEmptyOrganToTransportItemAssociationToList();
                }
                BindOrganToTransportItem(true);
            }

            if (e.CommandName == "FooterInsert")
            {
                if (OrganToTransportItemAssociationList != null)
                {
                    // Delete provisional Datarow which was created in case no data existed in the first place to prevent GridView from hiding header and footer
                    DeleteProvisionalEmptyOrganToTransportItemAssociationOfList();
                }

                DropDownList ddlFooterOrgan = gvOrganToTransportItemAssociation.FooterRow.FindControl("ddlFooterOrgan") as DropDownList;

                if (ddlFooterOrgan != null)
                {
                    AddNewOrganToTransportItemAssociationToList(Convert.ToInt32(ddlFooterOrgan.SelectedValue));

                    BindOrganToTransportItem();
                }
            }
        }

        /// <summary>
        ///     Binds OrganDropDownList inside GridView gvOrganToTransportItemAssociation
        /// </summary>
        /// <remarks>
        ///     When adding a new organ to transport item association in the list, the DropDownlist will be filled with Organs
        ///     After each row creation the dropdwonlist in the footer will be refilled.
        ///     Items are filled twice if DataBind() of DropDownList is called. That's why it's expicitly not called here.
        /// </remarks>
        /// <param name="sender">sender</param>
        /// <param name="e">GridViewRowEventArgs</param>
        protected void gvOrganToTransportItemAssociation_RowCreated(object sender, GridViewRowEventArgs e)
        {
            // Bind dropdownlist in footer
            if (e.Row.RowType != DataControlRowType.Footer) return;

            DropDownList ddlFooterOrgan = e.Row.FindControl("ddlFooterOrgan") as DropDownList;
            BindOrganDropDownList(ddlFooterOrgan);
        }

        protected void gvOrganToTransportItemAssociation_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvOrganToTransportItemAssociation.EditIndex = e.NewEditIndex;

            BindOrganToTransportItem();

            HiddenField hidOrganToTransportItemAssociationID = gvOrganToTransportItemAssociation.Rows[gvOrganToTransportItemAssociation.EditIndex].FindControl("hidEditOrganToTransportItemAssociationID") as HiddenField;
            HiddenField hidEditOrganID = gvOrganToTransportItemAssociation.Rows[gvOrganToTransportItemAssociation.EditIndex].FindControl("hidEditOrganID") as HiddenField;
            DropDownList ddlEditOrgan = gvOrganToTransportItemAssociation.Rows[gvOrganToTransportItemAssociation.EditIndex].FindControl("ddlEditOrgan") as DropDownList;

            if (ddlEditOrgan == null || hidOrganToTransportItemAssociationID == null || hidEditOrganID == null) return;

            int? organID = OrganToTransportItemAssociationList[gvOrganToTransportItemAssociation.EditIndex].OrganID;
            int organToTransportItemAssociationID = OrganToTransportItemAssociationList[gvOrganToTransportItemAssociation.EditIndex].ID;

            // Bind DropDownList and set SelectedValue
            BindOrganDropDownList(ddlEditOrgan, organID, true);
            hidOrganToTransportItemAssociationID.Value = organToTransportItemAssociationID.ToString(CultureInfo.InvariantCulture);

            ddlEditOrgan.SelectedValue = organID.ToString();

            // save OrganID in hidden field to reset in case of Cancelling update
            hidEditOrganID.Value = OrganToTransportItemAssociationList[gvOrganToTransportItemAssociation.EditIndex].OrganID.ToString();
        }

        protected void gvOrganToTransportItemAssociation_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            // Set TransplantOrganID back to what it was set when originally clicked on Edit-Button
            HiddenField hidEditOrganID = gvOrganToTransportItemAssociation.Rows[e.RowIndex].FindControl("hidEditOrganID") as HiddenField;
            if (hidEditOrganID != null)
            {
                OrganToTransportItemAssociationList[e.RowIndex].OrganID = Convert.ToInt32(hidEditOrganID.Value);
                OrganToTransportItemAssociationList[e.RowIndex].Organ = GetOrganByID(Convert.ToInt32(hidEditOrganID.Value));
            }

            CancelRowUpdate();
        }

        protected void gvOrganToTransportItemAssociation_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            Page.Validate("OrganToTransportItemAssociationInputGroup");
            if (!Page.IsValid) return;

            DropDownList ddlEditOrgan = gvOrganToTransportItemAssociation.Rows[e.RowIndex].FindControl("ddlEditOrgan") as DropDownList;

            if (ddlEditOrgan != null)
            {
                OrganToTransportItemAssociationList[e.RowIndex].OrganID = Convert.ToInt32(ddlEditOrgan.SelectedValue);
                OrganToTransportItemAssociationList[e.RowIndex].TransportItemID = TransportItemID;
            }

            gvOrganToTransportItemAssociation.EditIndex = -1;
            BindOrganToTransportItem();
        }

        protected void gvOrganToTransportItemAssociation_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            OrganToTransportItemAssociationList.RemoveAt(e.RowIndex);

            gvOrganToTransportItemAssociation.EditIndex = -1;
            BindOrganToTransportItem();
        }

        protected void gvOrganToTransportItemAssociation_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header)
            {
                // Set Right-Align to Button "Add New..." in Header
                e.Row.Cells[1].HorizontalAlign = HorizontalAlign.Right;

                var cellWidth = new Unit("20em");
                e.Row.Cells[0].Width = cellWidth;
            }

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Hide provisional created row when no data exists so that header and footer are not hidden
                if (OrganToTransportItemAssociationList != null)
                {
                    // Delete provisional Datarow which was created in case no data existed in the first place to prevent GridView from hiding header and footer
                    OrganToTransportItemAssociation provisionalOrganTransportItemAssociation = GetProvisionalEmptyOrganToTransportItemAssociation();
                    if (provisionalOrganTransportItemAssociation != null) e.Row.Visible = false;
                }
            }
        }
        #endregion

        #region Privates
        private void BindOrganToTransportItem(bool showFooter = false)
        {
            if (OrganToTransportItemAssociationList == null) OrganToTransportItemAssociationList = new List<OrganToTransportItemAssociation>();

            gvOrganToTransportItemAssociation.ShowFooter = showFooter;
            gvOrganToTransportItemAssociation.DataSource = OrganToTransportItemAssociationList;
            gvOrganToTransportItemAssociation.DataBind();
        }

        private void BindOrganDropDownList(DropDownList ddlOrgan, int? organID = null, bool callDataBind = false)
        {
            if (ddlOrgan == null) return;

            // Select OrganID and Organ.Name (to display) for DropDownList
            var organ = from o in GetOrgans().Where(o => o.isActive || organID != null && o.ID == organID)
                        select new
                        {
                            o.ID,
                            o.Name
                        };

            ddlOrgan.ClearSelection();
            ddlOrgan.DataSource = organ.ToList();
            ddlOrgan.DataValueField = "ID";
            ddlOrgan.DataTextField = "Name";
            ddlOrgan.AppendDataBoundItems = true;
            ddlOrgan.Items.Insert(0,
                                  new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                               DropDownDefaultValue.DDL_DEFAULT_VALUE));
            if (callDataBind) ddlOrgan.DataBind();
        }

        /// <summary>
        ///     Adds new Organ to List
        /// </summary>
        /// <param name="organID">Organ ID</param>
        /// <param name="organToTransportItemAssociationID"></param>
        private void AddNewOrganToTransportItemAssociationToList(int organID, int? organToTransportItemAssociationID = null)
        {
            OrganToTransportItemAssociation organToTransportItemAssociation = new OrganToTransportItemAssociation
            {
                ID = organToTransportItemAssociationID != null ? Convert.ToInt32(organToTransportItemAssociationID) : 0,
                OrganID = organID,
                Organ = GetOrganByID(organID),
                TransportItemID = TransportItemID
            };

            if (OrganToTransportItemAssociationList == null) OrganToTransportItemAssociationList = new List<OrganToTransportItemAssociation>();
            OrganToTransportItemAssociationList.Add(organToTransportItemAssociation);
        }

        private void AddNewProvisionalEmptyOrganToTransportItemAssociationToList()
        {
            if (OrganToTransportItemAssociationList == null) OrganToTransportItemAssociationList = new List<OrganToTransportItemAssociation>();
            OrganToTransportItemAssociation ot = new OrganToTransportItemAssociation { ID = -1 };
            OrganToTransportItemAssociationList.Add(ot);
        }

        private OrganToTransportItemAssociation GetProvisionalEmptyOrganToTransportItemAssociation()
        {
            return OrganToTransportItemAssociationList.SingleOrDefault(oc => oc.ID == -1);
        }

        /// <summary>
        ///     Populate OrganToTransportItemAssociation from GridView
        /// </summary>
        /// <remarks>
        ///     Because OrganToTransportItemAssociation is generic and not serializable through entity framework, list has to be repopulated after every postback.
        /// </remarks>
        private void PopulateOrganToTransportItemAssociationList()
        {
            foreach (GridViewRow row in gvOrganToTransportItemAssociation.Rows)
            {
                // Populate list from GridView in "standard" view
                HiddenField hidOrganID = row.Cells[0].FindControl("hidOrganID") as HiddenField;
                HiddenField hidOrganToTransportItemAssociationID = row.Cells[0].FindControl("hidOrganToTransportItemAssociationID") as HiddenField;

                if (hidOrganID != null && hidOrganToTransportItemAssociationID != null)
                {
                    AddNewOrganToTransportItemAssociationToList(Convert.ToInt32(hidOrganID.Value), Convert.ToInt32(hidOrganToTransportItemAssociationID.Value));
                }

                // Populate list from GridView in "edit" view
                HiddenField hidEditOrganToTransportItemID = row.Cells[0].FindControl("hidEditOrganToTransportItemAssociationID") as HiddenField;
                DropDownList ddlEditOrgan = row.Cells[0].FindControl("ddlEditOrgan") as DropDownList;

                if (hidEditOrganToTransportItemID != null && ddlEditOrgan != null)
                {
                    AddNewOrganToTransportItemAssociationToList(Convert.ToInt32(ddlEditOrgan.SelectedValue), Convert.ToInt32(hidEditOrganToTransportItemID.Value));
                }
            }
        }

        private void DeleteProvisionalEmptyOrganToTransportItemAssociationOfList()
        {
            if (OrganToTransportItemAssociationList == null) return;

            OrganToTransportItemAssociation provisionalOrganToTransportItemAssociation = GetProvisionalEmptyOrganToTransportItemAssociation();
            if (provisionalOrganToTransportItemAssociation != null) OrganToTransportItemAssociationList.Remove(provisionalOrganToTransportItemAssociation);
        }

        private void CancelRowUpdate()
        {
            gvOrganToTransportItemAssociation.EditIndex = -1;
            BindOrganToTransportItem();
        }

        private void SaveOrganToTransportItemAssociation()
        {
            List<int> organToTransportItemAssociationIDsInDB = Data.OrganToTransportItemAssociation.Where(ot => ot.TransportItemID == TransportItemID).Select(ot => ot.ID).ToList();

            // if OrganToTransportItemAssociationList is empty, remove possible existing Datarows in DB
            if (OrganToTransportItemAssociationList == null)
            {
                foreach (int organToTransportItemAssociationIDinDB in organToTransportItemAssociationIDsInDB)
                {
                    Data.OrganToTransportItemAssociation.Remove(GetOrganToTransportItemAssociationByID(organToTransportItemAssociationIDinDB));
                }
                return;
            }

            // Loop throu all OrganToTransportItemAssociations but don't take in consideration empty provisional row (which has ID -1)
            foreach (OrganToTransportItemAssociation organToTransportItemAssociation in OrganToTransportItemAssociationList.Where(ocl => ocl.ID >= 0))
            {
                if (organToTransportItemAssociation.ID == 0)
                {
                    Data.OrganToTransportItemAssociation.Add(organToTransportItemAssociation);
                }
                else
                {
                    OrganToTransportItemAssociation ot = GetOrganToTransportItemAssociationByID(organToTransportItemAssociation.ID);
                    ot.OrganID = organToTransportItemAssociation.OrganID;
                    ot.TransportItemID = TransportItemID;
                }
            }

            // Remove Datarows in DB if they no longer exist in Updated List
            List<int> organToTransportItemAssociationIDsInList = OrganToTransportItemAssociationList.Select(ot => ot.ID).ToList();

            foreach (int organToTransportItemAssociationIDInDB in organToTransportItemAssociationIDsInDB)
            {
                bool iDExists = false;
                foreach (int organToTransportItemAssociationIDinList in organToTransportItemAssociationIDsInList)
                {
                    if (organToTransportItemAssociationIDinList == organToTransportItemAssociationIDInDB) iDExists = true;
                }

                if (!iDExists) Data.OrganToTransportItemAssociation.Remove(GetOrganToTransportItemAssociationByID(organToTransportItemAssociationIDInDB));
            }
        }
        #endregion

        #endregion
    }
}