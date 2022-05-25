using Pentag.SLIDS.Common;
using Pentag.SLIDS.Constants;
using Pentag.SLIDS.Controls;
using Pentag.SLIDS.DAL;
using System;
using System.Data.Entity.Infrastructure;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Web.ModelBinding;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Administration
{
    public partial class ManageCoordinators : BasePage
    {
        #region Properties
        protected int CoordinatorID
        {
            get { return hidCoordinatorID.Value == String.Empty ? 0 : Convert.ToInt32(hidCoordinatorID.Value); }
            set { hidCoordinatorID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected ucAddresses AddressControl
        {
            get { return ucAddressControl; }
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Manage Coordinator called");

            if (!IsPostBack)
            {
                // Bind dropdownlists and check-box repeaters
                BindDropDownLists();
            }
        }

        public IQueryable<Coordinator> gvCoordinator_GetData([Control] string filterText)
        {

            var query = GetCoordinators()
                .Where(c => !cbIncludeInactive.Checked && c.isActive || cbIncludeInactive.Checked);

            if (!string.IsNullOrEmpty(filterText))
            {
                // Convert to enumerable first to be able to use "ContainsCaseInsensitive" function
                query = query.AsEnumerable().Where(c => 
                    c.LastName.ContainsCaseInsensitive(filterText) ||
                    c.FirstName.ContainsCaseInsensitive(filterText) ||
                    c.Code.ContainsCaseInsensitive(filterText) ||
                    (c.Hospital != null && c.Hospital.Display.ContainsCaseInsensitive(filterText)))
                    .AsQueryable();
            }

            return query.OrderBy(c => c.LastName);
        }

        protected void gvCoordinator_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvCoordinator.SelectedIndex == -1 || gvCoordinator.SelectedDataKey == null) return;

            CoordinatorID = Convert.ToInt32(gvCoordinator.SelectedDataKey.Value);

            LoadAndViewDataDetails();

            AddressControl.ExistingAddressesPanel.Visible = false;
        }

        protected void cbIncludeInactive_CheckedChanged(object sender, EventArgs e)
        {
            // Rebind GridView of Coordinators (to include or exclude inactive coordinators)
            if (CoordinatorID > 0)
            {
                SelectCoordinatorRowInGridView(gvCoordinator, CoordinatorID);
            }
            else
            {
                gvCoordinator.DataBind();
            }
        }

        protected void btnAddNewCoordinator_Click(object sender, EventArgs e)
        {
            CoordinatorID = 0;
            AddressControl.AddressID = 0;

            gvCoordinator.SelectRow(-1);

            InitialiseDetailView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                bool isRowAdded = CoordinatorID == 0;
                Coordinator coordinator;

                if (isRowAdded)
                {
                    // create new datarow
                    coordinator = new Coordinator();
                    Data.Coordinator.Add(coordinator);

                    // Create user if it doesn't exists
                    if (cbIsNC.Checked || cbIsTC.Checked)
                    {

                    }
                }
                else
                {
                    // update existing datarow
                    coordinator = GetCoordinatorByID(CoordinatorID);
                }

                SaveDataAndRefreshGUI(coordinator);
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

                const string message = "Could not save Coordinator! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        /// <summary>
        ///     Sets Coordinator active or inactive
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">EventArgs</param>
        protected void btnActiveHandling_Click(object sender, EventArgs e)
        {
            try
            {
                Coordinator coordinator = GetCoordinatorByID(CoordinatorID);
                if (coordinator == null)
                    throw new ArgumentNullException(String.Format("Coordinator with ID {0} could not be found!",
                                                                  CoordinatorID));

                coordinator.isActive = !coordinator.isActive;

                cbIncludeInactive.Checked = !coordinator.isActive;

                SaveDataAndRefreshGUI(coordinator);
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

                const string message = "Could not archive or reactivate Coordinator! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        #region Privates
        private void LoadAndViewDataDetails()
        {
            Coordinator coordinator = GetCoordinatorByID(CoordinatorID);
            if (coordinator == null) return;

            LoadAndViewDataDetails(coordinator);
        }

        private void LoadAndViewDataDetails(Coordinator coordinator)
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(coordinator);
            PopulateDetailView(coordinator);
        }

        private void BindDropDownLists()
        {
            // Hospital
            ddlHospital.ClearSelection();
            ddlHospital.DataSource = GetHospitals().ToList();
            ddlHospital.DataValueField = "ID";
            ddlHospital.DataTextField = "Display";
            ddlHospital.DataBind();
            ddlHospital.Items.Insert(0,
                                     new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                  DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void PopulateDetailView(Coordinator coordinator)
        {
            PopulateCoordinatorDetailView(coordinator);

            if (coordinator.AddressID == null) return;

            Address address = GetAddressByID(Convert.ToInt32(coordinator.AddressID));
            if (address == null) return;

            AddressControl.PopulateAddressDetailView(address);
            AddressControl.AddressID = address.ID;
        }

        private void PopulateCoordinatorDetailView(Coordinator coordinator)
        {
            if (coordinator == null) throw new Exception("Coordinator datarow was not provided!");

            txtLastName.Text = coordinator.LastName;
            txtFirstName.Text = coordinator.FirstName;
            ddlHospital.SelectedValue = coordinator.HospitalID != null
                                            ? coordinator.HospitalID.ToString()
                                            : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtCode.Text = coordinator.Code;
            cbIsNC.Checked = coordinator.IsNC;
            cbIsTC.Checked = coordinator.IsTC;

            btnActiveHandling.Text = coordinator.isActive ? "Set inactive" : "Activate";
        }

        private void SaveDataAndRefreshGUI(Coordinator coordinator)
        {
            if (coordinator == null) throw new Exception("Coordinator datarow was not provided!");

            AddressControl.AssignValuesToAddress();

            AssignValuesToCoordinator(coordinator);

            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            CoordinatorID = coordinator.ID;

            AddressControl.ExistingAddressesPanel.Visible = false;

            LoadAndViewDataDetails(coordinator);

            // Navigate to selected row in Gridview
            SelectCoordinatorRowInGridView(gvCoordinator, coordinator.ID);
        }

        private void AssignValuesToCoordinator(Coordinator coordinator)
        {
            if (coordinator == null) throw new Exception("Coordinator datarow was not provided!");

            coordinator.LastName = !String.IsNullOrWhiteSpace(txtLastName.Text) ? txtLastName.Text : null;
            coordinator.FirstName = !String.IsNullOrWhiteSpace(txtFirstName.Text) ? txtFirstName.Text : null;
            coordinator.HospitalID = Convert.ToInt32(ddlHospital.SelectedValue) != -1
                               ? (int?)Convert.ToInt32(ddlHospital.SelectedValue)
                               : null;
            coordinator.Code = !String.IsNullOrWhiteSpace(txtCode.Text) ? txtCode.Text : null;
            coordinator.AddressID = AddressControl.AddressID;
            coordinator.IsNC = cbIsNC.Checked;
            coordinator.IsTC = cbIsTC.Checked;
            if (CoordinatorID == 0) coordinator.isActive = true;
            if (Convert.ToInt32(ddlHospital.SelectedValue) > 0) coordinator.Hospital = GetHospitalByID(Convert.ToInt32(ddlHospital.SelectedValue));
        }

        private void InitialiseDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(null);

            InitialiseCoordinatorDetailControls();

            AddressControl.InitialiseAddressDetailControls();
        }

        private void InitialiseCoordinatorDetailControls()
        {
            ddlHospital.SelectedIndex = 0;
            txtLastName.Text = String.Empty;
            txtFirstName.Text = String.Empty;
            txtCode.Text = String.Empty;
            cbIsNC.Checked = false;
            cbIsTC.Checked = false;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(Coordinator coordinator)
        {
            pnlCoordinatorDetails.Visible = true;
            AddressControl.AddressDetailsPanel.Visible = true;
            btnActiveHandling.Visible = CoordinatorID != 0;
            btnSave.Visible = Master.IsAdmin && ((coordinator != null && coordinator.isActive) || CoordinatorID == 0);

            bool enable = Master.IsAdmin && ((coordinator != null && coordinator.isActive) || CoordinatorID == 0);
            // Disable or enable controls inside detail panel one by one in order to handle enable-state of btnArchiveHandling (instead of simply enabling or disabling its panel itself)
            EnableOrDisableControls(pnlCoordinatorDetails, enable);
            // always allow archive or reactivate
            btnActiveHandling.Enabled = true;
        }

        /// <summary>
        ///     Jumps to Page of DataGridView with given ID in GridView and select its row
        /// </summary>
        /// <param name="gv">GridView in which selection is taking part of</param>
        /// <param name="itemID">Item ID in GridView</param>
        private void SelectCoordinatorRowInGridView(GridView gv, int itemID)
        {
            // Initialise Gridview
            if (!SelectRowInGridView(gv, itemID))
            {
                // if item was not found (no exit of this method via return in loop), set Gridview unselected and hide detail view
                CoordinatorID = 0;
                AddressControl.AddressID = 0;
                InitialiseDetailView();
                pnlCoordinatorDetails.Visible = false;
            }
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectCoordinatorRowInGridView(gvCoordinator, CoordinatorID);
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            CoordinatorID = 0;
            gvCoordinator.SelectedIndex = -1;
            gvCoordinator.DataBind();
            pnlCoordinatorDetails.Visible = false;
        }
        #endregion
    }
}