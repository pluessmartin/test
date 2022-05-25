using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Data.Entity.Infrastructure;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Administration
{
    public partial class ManageVehicles : BasePage
    {
        #region Properties
        protected int VehicleID
        {
            get { return hidVehicleID.Value == String.Empty ? 0 : Convert.ToInt32(hidVehicleID.Value); }
            set { hidVehicleID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Manage Vehicles called");
        }

        public IQueryable<Vehicle> gvVehicle_GetData()
        {
            return GetVehicles()
                .Where(o => !cbIncludeInactive.Checked && o.isActive || cbIncludeInactive.Checked);
        }

        protected void gvVehicle_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvVehicle.SelectedIndex == -1 || gvVehicle.SelectedDataKey == null) return;

            VehicleID = Convert.ToInt32(gvVehicle.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void cbIncludeInactive_CheckedChanged(object sender, EventArgs e)
        {
            // Rebind GridView of Vehicles (to include or exclude inactive Vehicles)
            if (VehicleID > 0)
            {
                SelectRowInGridView(gvVehicle, VehicleID);
            }
            else
            {
                gvVehicle.DataBind();
            }
        }

        protected void btnAddNewVehicle_Click(object sender, EventArgs e)
        {
            VehicleID = 0;

            gvVehicle.SelectRow(-1);

            InitialiseVehicleDetailView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                bool isRowAdded = VehicleID == 0;
                Vehicle vehicle;

                if (isRowAdded)
                {
                    // create new datarow
                    vehicle = new Vehicle();
                    Data.Vehicle.Add(vehicle);
                }
                else
                {
                    // update existing datarow
                    vehicle = GetVehicleByID(VehicleID);
                }

                SaveDataAndRefreshGUI(vehicle);
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

                const string message = "Could not save Vehicle! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected void btnActiveHandling_Click(object sender, EventArgs e)
        {
            try
            {
                Vehicle vehicle = GetVehicleByID(VehicleID);
                if (vehicle == null) throw new ArgumentNullException(String.Format("Vehicle with ID {0} could not be found!", VehicleID));

                vehicle.isActive = !vehicle.isActive;

                cbIncludeInactive.Checked = !vehicle.isActive;

                SaveDataAndRefreshGUI(vehicle);
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

                const string message = "Could not archive or reactivate Vehicle! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        #region Privates
        private void LoadAndViewDataDetails()
        {
            Vehicle vehicle = GetVehicleByID(VehicleID);
            if (vehicle == null) return;

            LoadAndViewDataDetails(vehicle);
        }

        private void LoadAndViewDataDetails(Vehicle vehicle)
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(vehicle);
            PopulateVehicleDetailView(vehicle);
        }

        private void PopulateVehicleDetailView(Vehicle vehicle)
        {
            if (vehicle == null) throw new Exception("Vehicle datarow was not provided!");

            txtName.Text = vehicle.Name;
            txtPosition.Text = vehicle.Position.ToString();

            btnActiveHandling.Text = vehicle.isActive ? "Set inactive" : "Activate";
        }

        private void SaveDataAndRefreshGUI(Vehicle vehicle)
        {
            if (vehicle == null) throw new Exception("Vehicle datarow was not provided!");

            AssignValuesToVehicle(vehicle);

            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            VehicleID = vehicle.ID;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvVehicle, vehicle.ID);
        }

        private void AssignValuesToVehicle(Vehicle vehicle)
        {
            if (vehicle == null) throw new Exception("Vehicle datarow was not provided!");

            vehicle.Name = !String.IsNullOrWhiteSpace(txtName.Text) ? txtName.Text : null;
            vehicle.Position = !String.IsNullOrWhiteSpace(txtPosition.Text) ? (int?)Convert.ToInt32(txtPosition.Text) : null;

            if (VehicleID == 0) vehicle.isActive = true;
        }

        private void InitialiseVehicleDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(null);

            txtName.Text = String.Empty;
            txtPosition.Text = String.Empty;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(Vehicle vehicle)
        {
            pnlVehicleDetails.Visible = true;
            btnActiveHandling.Visible = VehicleID != 0;
            btnSave.Visible = Master.IsAdmin && ((vehicle != null && vehicle.isActive) || VehicleID == 0);

            bool enable = Master.IsAdmin && ((vehicle != null && vehicle.isActive) || VehicleID == 0);
            // Disable or enable controls inside detail panel one by one in order to handle enable-state of btnArchiveHandling (instead of simply enabling or disabling its panel itself)
            EnableOrDisableControls(pnlVehicleDetails, enable);
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
                VehicleID = 0;
                InitialiseVehicleDetailView();
                pnlVehicleDetails.Visible = false;
            }
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvVehicle, VehicleID);
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            VehicleID = 0;
            gvVehicle.SelectedIndex = -1;
            gvVehicle.DataBind();
            pnlVehicleDetails.Visible = false;
        }
        #endregion
    }
}