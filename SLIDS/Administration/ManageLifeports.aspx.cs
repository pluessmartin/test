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
    public partial class ManageLifeports : BasePage
    {
        #region Properties
        protected int LifeportID
        {
            get { return hidLifeportID.Value == String.Empty ? 0 : Convert.ToInt32(hidLifeportID.Value); }
            set { hidLifeportID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Manage Lifeports called");
        }

        public IQueryable<Lifeport> gvLifeport_GetData()
        {
            return GetAllLifeports()
                .Where(o => !cbIncludeInactive.Checked && o.isActive || cbIncludeInactive.Checked);
        }

        protected void gvLifeport_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvLifeport.SelectedIndex == -1 || gvLifeport.SelectedDataKey == null) return;

            LifeportID = Convert.ToInt32(gvLifeport.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void cbIncludeInactive_CheckedChanged(object sender, EventArgs e)
        {
            // Rebind GridView of Lifeports (to include or exclude inactive Lifeports)
            if (LifeportID > 0)
            {
                SelectRowInGridView(gvLifeport, LifeportID);
            }
            else
            {
                gvLifeport.DataBind();
            }
        }

        protected void btnAddNewLifeport_Click(object sender, EventArgs e)
        {
            LifeportID = 0;

            gvLifeport.SelectRow(-1);

            InitialiseLifeportDetailView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                bool isRowAdded = LifeportID == 0;
                Lifeport lifeport;

                if (isRowAdded)
                {
                    // create new datarow
                    lifeport = new Lifeport();
                    Data.Lifeport.Add(lifeport);
                }
                else
                {
                    // update existing datarow
                    lifeport = GetLifeportByID(LifeportID);
                }

                SaveDataAndRefreshGUI(lifeport);
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

                const string message = "Could not save Lifeport! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected void btnActiveHandling_Click(object sender, EventArgs e)
        {
            try
            {
                Lifeport lifeport = GetLifeportByID(LifeportID);
                if (lifeport == null) throw new ArgumentNullException(String.Format("Lifeport with ID {0} could not be found!", LifeportID));

                lifeport.isActive = !lifeport.isActive;

                cbIncludeInactive.Checked = !lifeport.isActive;

                SaveDataAndRefreshGUI(lifeport);
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

                const string message = "Could not archive or reactivate Lifeport! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        #region Privates
        private void LoadAndViewDataDetails()
        {
            Lifeport lifeport = GetLifeportByID(LifeportID);
            if (lifeport == null) return;

            LoadAndViewDataDetails(lifeport);
        }

        private void LoadAndViewDataDetails(Lifeport lifeport)
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(lifeport);
            PopulateLifeportDetailView(lifeport);
        }

        private void PopulateLifeportDetailView(Lifeport lifeport)
        {
            if (lifeport == null) throw new Exception("Lifeport datarow was not provided!");

            txtName.Text = lifeport.Number;
            txtPosition.Text = lifeport.Position.ToString();

            btnActiveHandling.Text = lifeport.isActive ? "Set inactive" : "Activate";
        }

        private void SaveDataAndRefreshGUI(Lifeport lifeport)
        {
            if (lifeport == null) throw new Exception("Lifeport datarow was not provided!");

            AssignValuesToLifeport(lifeport);

            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            LifeportID = lifeport.ID;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvLifeport, lifeport.ID);
        }

        private void AssignValuesToLifeport(Lifeport lifeport)
        {
            if (lifeport == null) throw new Exception("Lifeport datarow was not provided!");

            lifeport.Number = !String.IsNullOrWhiteSpace(txtName.Text) ? txtName.Text : null;
            lifeport.Position = !String.IsNullOrWhiteSpace(txtPosition.Text) ? (int?)Convert.ToInt32(txtPosition.Text) : null;

            if (LifeportID == 0) lifeport.isActive = true;
        }

        private void InitialiseLifeportDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(null);

            txtName.Text = String.Empty;
            txtPosition.Text = String.Empty;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(Lifeport lifeport)
        {
            pnlLifeportDetails.Visible = true;
            btnActiveHandling.Visible = LifeportID != 0;
            btnSave.Visible = Master.IsAdmin && ((lifeport != null && lifeport.isActive) || LifeportID == 0);

            bool enable = Master.IsAdmin && ((lifeport != null && lifeport.isActive) || LifeportID == 0);
            // Disable or enable controls inside detail panel one by one in order to handle enable-state of btnArchiveHandling (instead of simply enabling or disabling its panel itself)
            EnableOrDisableControls(pnlLifeportDetails, enable);
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
                LifeportID = 0;
                InitialiseLifeportDetailView();
                pnlLifeportDetails.Visible = false;
            }
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvLifeport, LifeportID);
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            LifeportID = 0;
            gvLifeport.SelectedIndex = -1;
            gvLifeport.DataBind();
            pnlLifeportDetails.Visible = false;
        }
        #endregion
    }
}