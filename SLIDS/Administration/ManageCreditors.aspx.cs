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
    public partial class ManageCreditors : BasePage
    {
        #region Properties
        protected int CreditorID
        {
            get { return hidCreditorID.Value == String.Empty ? 0 : Convert.ToInt32(hidCreditorID.Value); }
            set { hidCreditorID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Manage Creditors called");
        }

        public IQueryable<Creditor> gvCreditor_GetData()
        {
            return GetCreditors()
                .Where(c => !cbIncludeInactive.Checked && c.isActive || cbIncludeInactive.Checked)
                .OrderBy(c => c.CreditorName);
        }

        protected void gvCreditor_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvCreditor.SelectedIndex == -1 || gvCreditor.SelectedDataKey == null) return;

            CreditorID = Convert.ToInt32(gvCreditor.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void cbIncludeInactive_CheckedChanged(object sender, EventArgs e)
        {
            // Rebind GridView of Creditor (to include or exclude inactive creditors)
            if (CreditorID > 0)
            {
                SelectRowInGridView(gvCreditor, CreditorID);
            }
            else
            {
                gvCreditor.DataBind();
            }
        }

        protected void btnAddNewCreditor_Click(object sender, EventArgs e)
        {
            CreditorID = 0;

            gvCreditor.SelectRow(-1);

            InitialiseCreditorDetailView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                bool isRowAdded = CreditorID == 0;
                Creditor creditor;

                if (isRowAdded)
                {
                    // create new datarow
                    creditor = new Creditor();
                    Data.Creditor.Add(creditor);
                }
                else
                {
                    // update existing datarow
                    creditor = GetCreditorByID(CreditorID);
                }

                SaveDataAndRefreshGUI(creditor);
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
        ///     Sets Creditors active or inactive
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">EventArgs</param>
        protected void btnActiveHandling_Click(object sender, EventArgs e)
        {
            try
            {
                Creditor creditor = GetCreditorByID(CreditorID);
                if (creditor == null) throw new ArgumentNullException(String.Format("Creditor with ID {0} could not be found!", CreditorID));

                creditor.isActive = !creditor.isActive;

                cbIncludeInactive.Checked = !creditor.isActive;

                SaveDataAndRefreshGUI(creditor);
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

                const string message = "Could not archive or reactivate Creditor! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        #region Privates
        private void LoadAndViewDataDetails()
        {
            Creditor creditor = GetCreditorByID(CreditorID);
            if (creditor == null) return;

            LoadAndViewDataDetails(creditor);
        }

        private void LoadAndViewDataDetails(Creditor creditor)
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(creditor);
            PopulateCreditorDetailView(creditor);
        }

        private void PopulateCreditorDetailView(Creditor creditor)
        {
            if (creditor == null) throw new Exception("Creditor datarow was not provided!");

            txtCreditorName.Text = creditor.CreditorName;

            btnActiveHandling.Text = creditor.isActive ? "Set inactive" : "Activate";
        }

        private void SaveDataAndRefreshGUI(Creditor creditor)
        {
            if (creditor == null) throw new Exception("Creditor datarow was not provided!");

            AssignValuesToCreditor(creditor);

            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            CreditorID = creditor.ID;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvCreditor, creditor.ID);
        }

        private void AssignValuesToCreditor(Creditor creditor)
        {
            if (creditor == null) throw new Exception("Creditor datarow was not provided!");

            creditor.CreditorName = !String.IsNullOrWhiteSpace(txtCreditorName.Text) ? txtCreditorName.Text : null;

            if (CreditorID == 0) creditor.isActive = true;
        }

        private void InitialiseCreditorDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(null);

            txtCreditorName.Text = String.Empty;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(Creditor creditor)
        {
            pnlCreditorDetails.Visible = true;
            btnActiveHandling.Visible = CreditorID != 0;
            btnSave.Visible = Master.IsAdmin && ((creditor != null && creditor.isActive) || CreditorID == 0);

            bool enable = Master.IsAdmin && ((creditor != null && creditor.isActive) || CreditorID == 0);
            // Disable or enable controls inside detail panel one by one in order to handle enable-state of btnArchiveHandling (instead of simply enabling or disabling its panel itself)
            EnableOrDisableControls(pnlCreditorDetails, enable);
            // always allow archive or reactivate
            btnActiveHandling.Enabled = true;
        }

        /// <summary>
        ///     Jumps to Page of DataGridView with given ID in GridView and select its row
        /// </summary>
        /// <param name="gv">GridView in which selection is taking part of</param>
        /// <param name="itemID">Item ID in GridView</param>
        private void SelectRowInGridView(GridView gv, int itemID)
        {
            if (!BasePage.SelectRowInGridView(gv, itemID))
            {
                CreditorID = 0;
                InitialiseCreditorDetailView();
                pnlCreditorDetails.Visible = false;
            }
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvCreditor, CreditorID);
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            CreditorID = 0;
            gvCreditor.SelectedIndex = -1;
            gvCreditor.DataBind();
            pnlCreditorDetails.Visible = false;
        }
        #endregion
    }
}