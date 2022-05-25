using Pentag.SLIDS.Common;
using Pentag.SLIDS.Constants;
using Pentag.SLIDS.Controls;
using Pentag.SLIDS.DAL;
using System;
using System.Data.Entity.Infrastructure;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Web.ModelBinding;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Administration
{
    public partial class ManageHospitals : BasePage
    {
        #region Properties
        protected int HospitalID
        {
            get { return hidHospitalID.Value == String.Empty ? 0 : Convert.ToInt32(hidHospitalID.Value); }
            set { hidHospitalID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected ucAddresses AddressControl
        {
            get { return ucAddressControl; }
        }

        protected ucAddresses AccountingAddressesControl
        {
            get { return ucAcountingAddressControl; }
        }
        #endregion

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            AccountingAddressesControl.Initialize(true, true);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Manage Hosptals called");

            if (IsPostBack) return;

            BindLanguageDropDownList();

            AccountingAddressesControl.AddressDetailsPanel.GroupingText = "Accounting Address";
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            if (!IsPostBack) return;

            if (AddressControl.IsFO) cbIsFo.Checked = true;
        }

        /// <summary>
        ///     Returns complete Address in a string
        /// </summary>
        /// <param name="hospital">Hospital</param>
        /// <returns>Complete Address in a string</returns>
        protected string GetAddress(Hospital hospital)
        {
            StringBuilder address = new StringBuilder();

            if (hospital.Address1.Address1 != null && !String.IsNullOrWhiteSpace(hospital.Address1.Address1))
            {
                if (address.Length > 0) address.Append(", ");
                address.Append(hospital.Address1.Address1);
            }

            if (hospital.Address1.Address2 != null && !String.IsNullOrWhiteSpace(hospital.Address1.Address2))
            {
                if (address.Length > 0) address.Append(", ");
                address.Append(hospital.Address1.Address2);
            }

            if (hospital.Address1.Zip != null && !String.IsNullOrWhiteSpace(hospital.Address1.Zip))
            {
                if (address.Length > 0) address.Append(", ");
                address.Append(hospital.Address1.Zip);
            }

            if (hospital.Address1.City != null && !String.IsNullOrWhiteSpace(hospital.Address1.City))
            {
                if (address.Length > 0 && hospital.Address1.Zip == null) address.Append(", ");
                if (address.Length > 0 && hospital.Address1.Zip != null) address.Append(" ");
                address.Append(hospital.Address1.City);
            }

            return address.ToString();
        }

        public IQueryable<Hospital> gvHospital_GetData([Control] string filterText)
        {
            var query = GetHospitals()
                .Where(c => !cbIncludeInactive.Checked && c.isActive || cbIncludeInactive.Checked);

            if (!string.IsNullOrEmpty(filterText))
            {
                // Convert to enumerable first to be able to use "GetAddress" and "ContainsCaseInsensitive" function
                query = query.AsEnumerable().Where(c =>
                    c.Name.ContainsCaseInsensitive(filterText) || 
                    c.Code.ContainsCaseInsensitive(filterText) ||   
                    c.Display.ContainsCaseInsensitive(filterText) ||
                    GetAddress(c).ContainsCaseInsensitive(filterText)).AsQueryable();
            }

            return query.OrderBy(c => c.Name);
        }

        protected void gvHospital_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvHospital.SelectedIndex == -1 || gvHospital.SelectedDataKey == null) return;

            HospitalID = Convert.ToInt32(gvHospital.SelectedDataKey.Value);

            LoadAndViewDataDetails();

            AddressControl.ExistingAddressesPanel.Visible = false;
            AccountingAddressesControl.ExistingAddressesPanel.Visible = false;
        }

        protected void cbIncludeInactive_CheckedChanged(object sender, EventArgs e)
        {
            // Rebind GridView of Hospitals (to include or exclude inactive Hospitals)
            if (HospitalID > 0)
            {
                SelectRowInGridView(gvHospital, HospitalID);
            }
            else
            {
                gvHospital.DataBind();
            }
        }

        protected void btnAddNewHospital_Click(object sender, EventArgs e)
        {
            HospitalID = 0;
            AddressControl.AddressID = 0;
            AccountingAddressesControl.AddressID = 0;

            gvHospital.SelectRow(-1);

            InitialiseDetailView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                bool isRowAdded = HospitalID == 0;
                Hospital hospital;

                if (isRowAdded)
                {
                    // create new datarow
                    hospital = new Hospital();
                    Data.Hospital.Add(hospital);
                }
                else
                {
                    // update existing datarow
                    hospital = GetHospitalByID(HospitalID);
                }

                SaveDataAndRefreshGUI(hospital);
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

                const string message = "Could not save Hospital! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        /// <summary>
        ///     Sets Hospital active or inactive
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">EventArgs</param>
        protected void btnActiveHandling_Click(object sender, EventArgs e)
        {
            try
            {
                Hospital hospital = GetHospitalByID(HospitalID);
                if (hospital == null) throw new ArgumentNullException(String.Format("Hospital with ID {0} could not be found!", HospitalID));

                hospital.isActive = !hospital.isActive;

                cbIncludeInactive.Checked = !hospital.isActive;

                SaveDataAndRefreshGUI(hospital);
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

                const string message = "Could not archive or reactivate Hospital! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        #region Validation
        protected void cvCode_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = (!String.IsNullOrWhiteSpace(txtCode.Text) || cbIsFo.Checked);
        }
        protected void cvName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            Hospital hs = GetHospitals().FirstOrDefault(c => c.Name == txtName.Text && c.ID != HospitalID);
            if (hs != null)
            {
                args.IsValid = false;
            }else
            {
                args.IsValid = (!String.IsNullOrWhiteSpace(txtName.Text));
            }
        }

        protected void cvDisplay_ServerValidate(object source, ServerValidateEventArgs args)
        {
            Hospital hs = GetHospitals().FirstOrDefault(c => c.Display == txtDisplay.Text && c.ID != HospitalID);
            if (hs != null)
            {
                args.IsValid = false;
            }
            else
            {
                args.IsValid = (!String.IsNullOrWhiteSpace(txtDisplay.Text));
            }
        }
        #endregion

        #region Privates
        private void BindLanguageDropDownList()
        {
            ddlLanguage.ClearSelection();
            ddlLanguage.DataSource = GetLanguages().Where(o => o.isActive).ToList();
            ddlLanguage.DataValueField = "ID";
            ddlLanguage.DataTextField = "LanguageName";
            ddlLanguage.DataBind();
            ddlLanguage.Items.Insert(0,
                                  new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                               DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void LoadAndViewDataDetails()
        {
            Hospital hospital = GetHospitalByID(HospitalID);
            if (hospital == null) return;

            LoadAndViewDataDetails(hospital);
        }

        private void LoadAndViewDataDetails(Hospital hospital)
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(hospital);
            PopulateDetailView(hospital);
        }

        private void PopulateDetailView(Hospital hospital)
        {
            PopulateHospitalDetailView(hospital);

            Address address = GetAddressByID(Convert.ToInt32(hospital.AddressID));
            if (address != null)
            {
                AddressControl.PopulateAddressDetailView(address);

                AddressControl.AddressID = address.ID;
            }

            Address accountingAddress = GetAddressByID(Convert.ToInt32(hospital.AccountingAddressID));
            if (accountingAddress != null)
            {
                AccountingAddressesControl.PopulateAddressDetailView(accountingAddress);

                AccountingAddressesControl.AddressID = accountingAddress.ID;
            }
        }

        private void PopulateHospitalDetailView(Hospital hospital)
        {
            if (hospital == null) throw new Exception("Hospital datarow was not provided!");

            txtName.Text = hospital.Name;
            txtCode.Text = hospital.Code;
            txtDisplay.Text = hospital.Display;
            ddlLanguage.SelectedValue = hospital.CorrespondanceLanguageID != null
                                                    ? hospital.CorrespondanceLanguageID.ToString()
                                                    : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            cbIsReferral.Checked = hospital.IsReferral;
            cbIsProcurement.Checked = hospital.IsProcurement;
            cbIsTransplantation.Checked = hospital.IsTransplantation;
            cbIsFo.Checked = hospital.IsFo;

            btnActiveHandling.Text = hospital.isActive ? "Set inactive" : "Activate";
        }

        private void SaveDataAndRefreshGUI(Hospital hospital)
        {
            if (hospital == null) throw new Exception("Hospital datarow was not provided!");

            AddressControl.AssignValuesToAddress();
            AccountingAddressesControl.AssignValuesToAddress();

            AssignValuesToHospital(hospital);

            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            HospitalID = hospital.ID;

            AddressControl.ExistingAddressesPanel.Visible = false;
            AccountingAddressesControl.ExistingAddressesPanel.Visible = false;

            LoadAndViewDataDetails(hospital);

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvHospital, hospital.ID);
        }

        private void AssignValuesToHospital(Hospital hospital)
        {
            if (hospital == null) throw new Exception("Hospital datarow was not provided!");

            hospital.Name = !String.IsNullOrWhiteSpace(txtName.Text) ? txtName.Text : null;
            hospital.Code = !String.IsNullOrWhiteSpace(txtCode.Text) ? txtCode.Text : null;
            hospital.Display = !String.IsNullOrWhiteSpace(txtDisplay.Text) ? txtDisplay.Text : null;
            hospital.CorrespondanceLanguageID = Convert.ToInt32(ddlLanguage.SelectedValue);
            hospital.AddressID = AddressControl.AddressID;
            hospital.AccountingAddressID = AccountingAddressesControl.AddressID;
            hospital.IsReferral = cbIsReferral.Checked;
            hospital.IsProcurement = cbIsProcurement.Checked;
            hospital.IsTransplantation = cbIsTransplantation.Checked;
            hospital.IsFo = cbIsFo.Checked;

            if (HospitalID == 0) hospital.isActive = true;

            if (AccountingAddressesControl.AddressID > 0) hospital.Address = GetAddressByID(AccountingAddressesControl.AddressID);
            if (AddressControl.AddressID > 0) hospital.Address1 = GetAddressByID(AddressControl.AddressID);
        }

        private void InitialiseDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(null);

            InitialiseHospitalDetailControls();

            AddressControl.InitialiseAddressDetailControls();
            AccountingAddressesControl.InitialiseAddressDetailControls();
        }

        private void InitialiseHospitalDetailControls()
        {
            txtName.Text = String.Empty;
            txtCode.Text = String.Empty;
            txtDisplay.Text = String.Empty;
            ddlLanguage.SelectedIndex = -1;
            cbIsReferral.Checked = false;
            cbIsProcurement.Checked = false;
            cbIsTransplantation.Checked = false;
            cbIsFo.Checked = false;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition(Hospital hospital)
        {
            pnlHospitalDetails.Visible = true;
            AddressControl.AddressDetailsPanel.Visible = true;
            AccountingAddressesControl.AddressDetailsPanel.Visible = true;
            btnActiveHandling.Visible = HospitalID != 0;
            btnSave.Visible = Master.IsAdmin && ((hospital != null && hospital.isActive) || HospitalID == 0);

            bool enable = Master.IsAdmin && ((hospital != null && hospital.isActive) || HospitalID == 0);
            // Disable or enable controls inside detail panel one by one in order to handle enable-state of btnArchiveHandling (instead of simply enabling or disabling its panel itself)
            EnableOrDisableControls(pnlHospitalDetails, enable);
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
                HospitalID = 0;
                AddressControl.AddressID = 0;
                AccountingAddressesControl.AddressID = 0;
                InitialiseDetailView();
                pnlHospitalDetails.Visible = false;
            }
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            LoadAndViewDataDetails();

            // Navigate to selected row in Gridview
            SelectRowInGridView(gvHospital, HospitalID);
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            HospitalID = 0;
            gvHospital.SelectedIndex = -1;
            gvHospital.DataBind();
            pnlHospitalDetails.Visible = false;
        }
        #endregion

    }
}