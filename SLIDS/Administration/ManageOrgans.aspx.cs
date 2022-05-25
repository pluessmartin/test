using Pentag.SLIDS.Constants;
using System;
using System.Data.Entity.Infrastructure;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Administration
{
    public partial class ManageOrgans : BasePage
    {
        #region Properties
        protected int OrganID
        {
            get { return hidOrganID.Value == String.Empty ? 0 : Convert.ToInt32(hidOrganID.Value); }
            set { hidOrganID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Manage organs called");

            if (IsPostBack) return;

            BindItemGroupDropDownList();
        }

        public IQueryable<DAL.Organ> gvOrgan_GetData()
        {
            return GetOrgans()
                .Where(o => !cbIncludeInactive.Checked && o.isActive || cbIncludeInactive.Checked);
        }

        protected void gvOrgan_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvOrgan.SelectedIndex == -1 || gvOrgan.SelectedDataKey == null) return;

            OrganID = Convert.ToInt32(gvOrgan.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void cbIncludeInactive_CheckedChanged(object sender, EventArgs e)
        {
            // Rebind GridView of Organs (to include or exclude inactive organs)
            if (OrganID > 0)
            {
                SelectRowInGridView(gvOrgan, OrganID);
            }
            else
            {
                gvOrgan.DataBind();
            }
        }

        protected void btnAddNewOrgan_Click(object sender, EventArgs e)
        {
            OrganID = 0;

            gvOrgan.SelectRow(-1);

            InitialiseOrganDetailView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                bool isRowAdded = OrganID == 0;
                DAL.Organ organ;

                if (isRowAdded)
                {
                    // create new datarow
                    organ = new DAL.Organ();
                    Data.Organ.Add(organ);
                }
                else
                {
                    // update existing datarow
                    organ = GetOrganByID(OrganID);
                }

                SaveDataAndRefreshGUI(organ);
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

                const string message = "Could not save Organ! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected void btnActiveHandling_Click(object sender, EventArgs e)
        {
            try
            {
                DAL.Organ organ = GetOrganByID(OrganID);
                if (organ == null)
                    throw new ArgumentNullException(String.Format("Organ with ID {0} could not be found!", OrganID));

                organ.isActive = !organ.isActive;

                cbIncludeInactive.Checked = !organ.isActive;

                SaveDataAndRefreshGUI(organ);
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

                const string message = "Could not archive or reactivate Organ! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        #region Privates
        private void BindItemGroupDropDownList()
        {
            ddlItemGroup.ClearSelection();
            ddlItemGroup.DataSource = GetItemGroupsByType((int)ItemGroupType.Organ).Where(o => o.isActive).ToList();
            ddlItemGroup.DataValueField = "ID";
            ddlItemGroup.DataTextField = "Name";
            ddlItemGroup.DataBind();
            ddlItemGroup.Items.Insert(0,
                                  new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                               DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void LoadAndViewDataDetails()
        {
            DAL.Organ organ = GetOrganByID(OrganID);
            if (organ == null) return;

            LoadAndViewDataDetails(organ);
        }

        private void LoadAndViewDataDetails(DAL.Organ organ)
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(organ);
            PopulateOrganDetailView(organ);
        }

        private void PopulateOrganDetailView(DAL.Organ organ)
        {
            if (organ == null) throw new Exception("Organ datarow was not provided!");

            ddlItemGroup.SelectedValue = organ.ItemGroupID != null
                                             ? organ.ItemGroupID.ToString()
                                             : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtName.Text = organ.Name;
            txtCountableAs.Text = organ.CountableAs.ToString();
            txtPosition.Text = organ.Position.ToString();

            btnActiveHandling.Text = organ.isActive ? "Set inactive" : "Activate";
        }

        private void SaveDataAndRefreshGUI(DAL.Organ organ)
        {
            if (organ == null) throw new Exception("Organ datarow was not provided!");

            AssignValuesToOrgan(organ);

            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            OrganID = organ.ID;

            LoadAndViewDataDetails(organ);

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvOrgan, organ.ID);
        }

        private void AssignValuesToOrgan(DAL.Organ organ)
        {
            if (organ == null) throw new Exception("Organ datarow was not provided!");

            organ.ItemGroupID = Convert.ToInt32(ddlItemGroup.SelectedValue);
            organ.Name = !String.IsNullOrWhiteSpace(txtName.Text) ? txtName.Text : null;
            organ.CountableAs = !String.IsNullOrWhiteSpace(txtCountableAs.Text) ? (int?)Convert.ToInt32(txtCountableAs.Text) : null;
            organ.Position = !String.IsNullOrWhiteSpace(txtPosition.Text) ? (int?)Convert.ToInt32(txtPosition.Text) : null;

            if (OrganID == 0) organ.isActive = true;
        }

        private void InitialiseOrganDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(null);

            txtName.Text = String.Empty;
            txtCountableAs.Text = string.Empty;
            txtPosition.Text = String.Empty;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(DAL.Organ organ)
        {
            pnlOrganDetails.Visible = true;
            btnActiveHandling.Visible = OrganID != 0;
            btnSave.Visible = Master.IsAdmin && ((organ != null && organ.isActive) || OrganID == 0);

            bool enable = Master.IsAdmin && ((organ != null && organ.isActive) || OrganID == 0);
            // Disable or enable controls inside detail panel one by one in order to handle enable-state of btnArchiveHandling (instead of simply enabling or disabling its panel itself)
            EnableOrDisableControls(pnlOrganDetails, enable);
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
                OrganID = 0;
                InitialiseOrganDetailView();
                pnlOrganDetails.Visible = false;
            }
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvOrgan, OrganID);
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            OrganID = 0;
            gvOrgan.SelectedIndex = -1;
            gvOrgan.DataBind();
            pnlOrganDetails.Visible = false;
        }
        #endregion
    }
}