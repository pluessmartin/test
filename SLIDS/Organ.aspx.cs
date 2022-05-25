using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Data.Entity.Infrastructure;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public partial class Organ : BasePage
    {
        #region Properties
        protected bool FODataHasBeenModified = false;

        protected int TransplantOrganID
        {
            get { return hidTransplantOrganID.Value == String.Empty ? 0 : Convert.ToInt32(hidTransplantOrganID.Value); }
            set { hidTransplantOrganID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        protected bool IsFO
        {
            get { return Convert.ToBoolean(hidIsFO.Value); }
            set { hidIsFO.Value = value.ToString(); }
        }

        protected bool HasError = false;
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Donor Organ called");

            if (IsPostBack) return;

            string donorID = HttpUtility.UrlDecode(Request.QueryString["donorID"]);
            if (donorID != null) Master.DonorID = Convert.ToInt32(donorID);

            string transplantOrganID = HttpUtility.UrlDecode(Request.QueryString["transplantOrganID"]);
            if (transplantOrganID != null) TransplantOrganID = Convert.ToInt32(transplantOrganID);

            // check if donor was selected, if not do nothing
            if (Master.DonorID <= 0) return;

            // set visibilty of "Add new..."-button initially depending on user rights
            btnAddNewOrgan.Visible = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            btnIncidentCreate.Visible = !Master.IsOnlyAAA;

            BindDropDownLists();

            if (TransplantOrganID == 0) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            if (TransplantOrganID > 0 && !IsPostBack)
            {
                SelectRowInGridView(gvTransplantOrgan, TransplantOrganID);
            }
        }

        public IQueryable<TransplantOrgan> gvTransplantOrgan_GetData()
        {
            return GetTransplantOrgans()
                .Where(to => to.DonorID == Master.DonorID);
        }

        protected void btnAddNewOrgan_Click(object sender, EventArgs e)
        {
            TransplantOrganID = 0;
            IsFO = false;

            cbForeignTransplantCenter.Checked = IsFO;

            BindDropDownLists();

            gvTransplantOrgan.SelectRow(-1);

            InitialiseDetailView();
        }

        protected void btnAddNewFOTransplantCenter_Click(object sender, EventArgs e)
        {
            pnlFOTransplantCenter.Enabled = true;

            ddlTransplantCenter.SelectedIndex = 0;

            PopulateForeignTransplantCenterDetailView(Convert.ToInt32(ddlTransplantCenter.SelectedValue));
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                int coordinatorID = 0;

                if (IsFO)
                {
                    coordinatorID = AssignValuesAndSaveForeignTransplantCenter(Convert.ToInt32(ddlTransplantCenter.SelectedValue));
                    if (HasError) return;
                }

                TransplantOrgan to = AssignValuesToTransplantOrgan(coordinatorID);

                if (Data.SaveChanges() > 0 || FODataHasBeenModified)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }

                TransplantOrganID = to.ID;

                // Refresh DataGridView
                gvTransplantOrgan.DataBind();
                SelectRowInGridView(gvTransplantOrgan, TransplantOrganID);
            }
            catch (DbUpdateConcurrencyException concurrencyEx)
            {
                HandlePageRefreshAfterConcurrencyException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + concurrencyEx.Message);
                HasError = true;
            }
            catch (NullReferenceException nullReferenceEx)
            {
                // record has been deleted in the meantime!
                HandlePageRefreshAfterNullReferenceException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + nullReferenceEx.Message);
                HasError = true;
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not save Organ! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                HasError = true;
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (gvTransplantOrgan.SelectedDataKey != null)
                {
                    TransplantOrgan to = GetTransplantOrganByID(Convert.ToInt32(gvTransplantOrgan.SelectedDataKey.Value));
                    if (to == null)
                    {
                        throw new NullReferenceException(String.Format("TransplantOrgan with ID {0} could not be found!", gvTransplantOrgan.SelectedDataKey.Value));
                    }

                    to.IsDeleted = true;
                }
                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgDeleteSuccess, SLIDSMaster.LabelState.Success);

                    // Reset TransplantOrganID and refresh DataGrid
                    TransplantOrganID = 0;
                    gvTransplantOrgan.SelectedIndex = -1;
                    gvTransplantOrgan.DataBind();
                    pnlTransplantOrganDetails.Visible = false;
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
                HasError = true;
            }
            catch (NullReferenceException nullReferenceEx)
            {
                // record has been deleted in the meantime!
                HandlePageRefreshAfterNullReferenceException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyDeleteNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + nullReferenceEx.Message);
                HasError = true;
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not delete TransplantOrgan! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                HasError = true;
            }
        }

        protected void gvTransplantOrgan_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvTransplantOrgan.SelectedIndex == -1 || gvTransplantOrgan.SelectedDataKey == null) return;

            TransplantOrganID = Convert.ToInt32(gvTransplantOrgan.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void ddlTransplantCenter_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!IsFO) return;

            // Set FO TransplantCenter details
            PopulateForeignTransplantCenterDetailView(Convert.ToInt32(ddlTransplantCenter.SelectedValue));
            pnlFOTransplantCenter.Enabled = Convert.ToInt32(ddlTransplantCenter.SelectedValue) > 0;
        }

        protected void cbForeignTransplantCenter_CheckedChanged(object sender, EventArgs e)
        {
            IsFO = cbForeignTransplantCenter.Checked;

            BindTransplantCenterDropDownList();
            BindProcurementTeamDropDownList();
            if (IsFO) ddlProcurementTeam.SelectedValue = "-1";

            ddlTC.Enabled = !IsFO && (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant);

            btnAddNewFOTransplantCenter.Visible = IsFO;
            pnlFOTransplantCenter.Visible = IsFO;

            if (IsFO)
            {
                // Set FO TransplantCenter Hospital details
                PopulateForeignTransplantCenterDetailView(Convert.ToInt32(ddlTransplantCenter.SelectedValue));
                pnlFOTransplantCenter.Enabled = Convert.ToInt32(ddlTransplantCenter.SelectedValue) > 0;
            }
        }

        #region Privates
        private void LoadAndViewDataDetails()
        {
            TransplantOrgan to = GetTransplantOrganByID(TransplantOrganID);
            if (to == null) return;

            IsFO = HospitalIsFO(Convert.ToInt32(to.TransplantCenterID));
            cbForeignTransplantCenter.Checked = IsFO;

            BindDropDownLists();

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
            PopulateOrganDetailView(to);
            setVisibilityOfPerfusionMachine();
        }

        private TransplantOrgan AssignValuesToTransplantOrgan(int coordinatorID)
        {
            bool isRowAdded = TransplantOrganID == 0;
            TransplantOrgan to;

            if (isRowAdded)
            {
                // create new datarow
                to = new TransplantOrgan();
                Data.TransplantOrgan.Add(to);
            }
            else
            {
                // update existing datarow
                to = GetTransplantOrganByID(TransplantOrganID);
            }

            to.DonorID = Master.DonorID;
            to.OrganID = Convert.ToInt32(ddlOrgan.SelectedValue);
            to.TransplantCenterID = Convert.ToInt32(ddlTransplantCenter.SelectedValue) > 0
                                        ? (int?)Convert.ToInt32(ddlTransplantCenter.SelectedValue)
                                        : null;
            // For ProcurementTeamID check unequal 0 instead of greater 0 because ID can be -1 when FO-Team is selected
            to.ProcurementTeamID = Convert.ToInt32(ddlProcurementTeam.SelectedValue) != 0
                                       ? (int?)Convert.ToInt32(ddlProcurementTeam.SelectedValue)
                                       : null;

            if (IsFO)
            {
                to.TCID = coordinatorID > 0 ? (int?)coordinatorID : null;
            }
            else
            {
                to.TCID = Convert.ToInt32(ddlTC.SelectedValue) > 0
                              ? (int?)Convert.ToInt32(ddlTC.SelectedValue)
                              : null;
            }

            to.TransplantStatusID = Convert.ToInt32(ddlStatus.SelectedValue) > 0
                                        ? (int?)Convert.ToInt32(ddlStatus.SelectedValue)
                                        : null;

       


            to.GraftBoxNo = !String.IsNullOrWhiteSpace(txtGraftBoxNo.Text)
                                ? (int?)Convert.ToInt32(txtGraftBoxNo.Text)
                                : null;
            to.ProcurementSurgeon = !String.IsNullOrWhiteSpace(txtProcurementSurgeon.Text)
                                        ? txtProcurementSurgeon.Text
                                        : null;
            to.ReceivedNecroReportWithin5Days = ddlReceivedNecroReportWithin5Days.SelectedValue ==
                                                DropDownDefaultValue.DDL_DEFAULT_TEXT
                                                    ? null
                                                    : (bool?)
                                                      Convert.ToBoolean(
                                                          Convert.ToInt32(
                                                              ddlReceivedNecroReportWithin5Days.SelectedValue));

            to.PrefusionMachine =  trPerfusionMachine.Visible && chkPerfusionmachine.Checked;

            if (chkPerfusionmachine.Checked)
            {
                to.PrefusionMachineNumber = Convert.ToInt32(ddlLifeport.SelectedValue) > 0
                                       ? (ddlLifeport.SelectedItem.Text)
                                       : null;
            }
            else
            {
                to.PrefusionMachineNumber = "";
            }
            to.Remark = txtRemark.Text;

           return to;
        }

        private void PopulateOrganDetailView(TransplantOrgan to)
        {
            if (to == null) throw new Exception("OrganTransport datarow was not provided!");

            ddlOrgan.SelectedValue = to.OrganID.ToString(CultureInfo.InvariantCulture);
            ddlTransplantCenter.SelectedValue = to.TransplantCenterID != null
                                                    ? to.TransplantCenterID.ToString()
                                                    : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            ddlProcurementTeam.SelectedValue = to.ProcurementTeamID != null
                                                   ? to.ProcurementTeamID.ToString()
                                                   : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            if (!IsFO)
                ddlTC.SelectedValue = to.TCID != null ? to.TCID.ToString() : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            ddlStatus.SelectedValue = to.TransplantStatusID != null
                                          ? to.TransplantStatusID.ToString()
                                          : DropDownDefaultValue.DDL_DEFAULT_VALUE;

           

            if(to.PrefusionMachine == false)
            {
                ddlLifeport.Enabled = false;
                to.PrefusionMachineNumber = "";
            }
            else
            {
                ddlLifeport.Enabled = true;
            }

            if (!string.IsNullOrEmpty(to.PrefusionMachineNumber))
            {
                var machineNumber = Data.Lifeport.FirstOrDefault(n => n.Number == to.PrefusionMachineNumber);
                if (machineNumber != null)
                {
                    var item = ddlLifeport.Items.FindByText(machineNumber.Number);
                    if (item != null)
                    {

                        ddlLifeport.SelectedValue = item.Value;
                    }else
                    {
                        ddlLifeport.SelectedValue = DropDownDefaultValue.DDL_DEFAULT_VALUE;
                    }
                }
                else
                {
                    ddlLifeport.SelectedValue = DropDownDefaultValue.DDL_DEFAULT_VALUE;
                }
            }

            txtGraftBoxNo.Text = to.GraftBoxNo.ToString();
            txtProcurementSurgeon.Text = to.ProcurementSurgeon;
            switch (to.ReceivedNecroReportWithin5Days)
            {
                case null:
                    ddlReceivedNecroReportWithin5Days.SelectedValue = null;
                    break;
                case true:
                    ddlReceivedNecroReportWithin5Days.SelectedValue = "1";
                    break;
                case false:
                    ddlReceivedNecroReportWithin5Days.SelectedValue = "0";
                    break;
            }

            if (IsFO)
            {
                PopulateForeignTransplantCenterDetailView(Convert.ToInt32(to.TransplantCenterID));
            }
            chkPerfusionmachine.Checked = to.PrefusionMachine.HasValue ? (bool)to.PrefusionMachine : false;
            txtRemark.Text = to.Remark;
        }

        private void PopulateForeignTransplantCenterDetailView(int transplantCenterID)
        {
            if (transplantCenterID <= 0)
            {
                InitialiseFOTransplantCenterDetails();
                return;
            }

            TransplantOrgan to = GetTransplantOrganByID(TransplantOrganID);

            Hospital h = GetHospitalByID(transplantCenterID);
            if (h == null)
                throw new ArgumentNullException(String.Format("Hospital with ID {0} could not be found!",
                                                              transplantCenterID));
            IsFO = h.IsFo;

            ddlTransplantCenter.SelectedValue = h.ID.ToString(CultureInfo.InvariantCulture);

            Address a = GetAddressByID(Convert.ToInt32(h.AddressID));
            if (a != null)
            {
                txtFOTransplantCenterName.Text = h.Name;
                txtFOTransplantCenterDisplay.Text = h.Display;
                txtFOTransplantCenterAddress1.Text = a.Address1;
                txtFOTransplantCenterAddress2.Text = a.Address2;
                txtFOTransplantCenterAddress3.Text = a.Address3;
                txtFOTransplantCenterAddress4.Text = a.Address4;
                txtFOTransplantCenterZip.Text = a.Zip;
                txtFOTransplantCenterCity.Text = a.City;
                txtFOTransplantCenterCountryISO.Text = a.CountryISO;
                txtFOTransplantCenterPhone.Text = a.Phone;
                txtFOTransplantCenterFax.Text = a.Fax;
                txtFOTransplantCenterEmail.Text = a.Email;
            }

            if (to != null && to.TCID != null)
            {
                Coordinator c = GetCoordinatorByID(Convert.ToInt32(to.TCID));

                if (c != null)
                {
                    // Only fill Coordinator data if assigned hospital is a foreign hospital
                    if (c.HospitalID != null && HospitalIsFO(Convert.ToInt32(c.HospitalID)))
                    {
                        txtFOTCLastname.Text = c.LastName;
                        txtFOTCFirstname.Text = c.FirstName;
                    }
                    else
                    {
                        txtFOTCLastname.Text = String.Empty;
                        txtFOTCFirstname.Text = String.Empty;
                    }
                }
            }
            else
            {
                txtFOTCLastname.Text = String.Empty;
                txtFOTCFirstname.Text = String.Empty;
            }
        }

        /// <summary>
        ///     Saves Data of foreign Procurement Hospital which can be edited when Donor is foreign (Donor No starts with "FO")
        /// </summary>
        /// <param name="hospitalID">Hospital ID</param>
        private int AssignValuesAndSaveForeignTransplantCenter(int hospitalID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            int coordinatorID = 0;

            try
            {
                bool isRowAdded = hospitalID == 0;

                TransplantOrgan to = GetTransplantOrganByID(TransplantOrganID);

                // Save Foreign TC is required when first or lastname was entered
                bool saveFOTCIsRequired = (!String.IsNullOrWhiteSpace(txtFOTCFirstname.Text) ||
                                           !String.IsNullOrWhiteSpace(txtFOTCLastname.Text));

                // If no Foreign TC was entered, make sure to clear TCID in TransplantOrgan (could be filled from an earlier insert or update)
                if (to != null && to.TCID != null && String.IsNullOrWhiteSpace(txtFOTCFirstname.Text) &&
                    String.IsNullOrWhiteSpace(txtFOTCLastname.Text)) to.TCID = null;

                Hospital h;
                Address a;
                Coordinator c = null;

                if (isRowAdded)
                {
                    // create new datarow
                    h = new Hospital();
                    Data.Hospital.Add(h);

                    a = new Address();
                    Data.Address.Add(a);
                }
                else
                {
                    // update existing datarow
                    h = GetHospitalByID(hospitalID);
                    if (h == null) throw new ArgumentNullException(String.Format("Hospital with ID {0} could not be found!", hospitalID));

                    a = GetAddressByID(h.AddressID);
                    if (a == null) throw new ArgumentNullException(String.Format("Address with ID {0} could not be found!", h.AddressID));
                }

                a.Address1 = !String.IsNullOrWhiteSpace(txtFOTransplantCenterAddress1.Text)
                                 ? txtFOTransplantCenterAddress1.Text
                                 : null;
                a.Address2 = !String.IsNullOrWhiteSpace(txtFOTransplantCenterAddress2.Text)
                                 ? txtFOTransplantCenterAddress2.Text
                                 : null;
                a.Address3 = !String.IsNullOrWhiteSpace(txtFOTransplantCenterAddress3.Text)
                                 ? txtFOTransplantCenterAddress3.Text
                                 : null;
                a.Address4 = !String.IsNullOrWhiteSpace(txtFOTransplantCenterAddress4.Text)
                                 ? txtFOTransplantCenterAddress4.Text
                                 : null;
                a.Zip = !String.IsNullOrWhiteSpace(txtFOTransplantCenterZip.Text) ? txtFOTransplantCenterZip.Text : null;
                a.City = !String.IsNullOrWhiteSpace(txtFOTransplantCenterCity.Text)
                             ? txtFOTransplantCenterCity.Text
                             : null;
                a.CountryISO = !String.IsNullOrWhiteSpace(txtFOTransplantCenterCountryISO.Text.Trim())
                                   ? txtFOTransplantCenterCountryISO.Text
                                   : null;
                a.Phone = !String.IsNullOrWhiteSpace(txtFOTransplantCenterPhone.Text)
                              ? txtFOTransplantCenterPhone.Text
                              : null;
                a.Fax = !String.IsNullOrWhiteSpace(txtFOTransplantCenterFax.Text) ? txtFOTransplantCenterFax.Text : null;
                a.Email = !String.IsNullOrWhiteSpace(txtFOTransplantCenterEmail.Text)
                              ? txtFOTransplantCenterEmail.Text
                              : null;

                h.Name = !String.IsNullOrWhiteSpace(txtFOTransplantCenterName.Text)
                             ? txtFOTransplantCenterName.Text
                             : null;
                h.Display = !String.IsNullOrWhiteSpace(txtFOTransplantCenterDisplay.Text)
                                ? txtFOTransplantCenterDisplay.Text
                                : h.Name;
                h.AddressID = a.ID;
                h.IsFo = true;
                h.IsTransplantation = true;
                h.IsReferral = false;
                h.IsProcurement = false;
                h.isActive = true;

                if (saveFOTCIsRequired)
                {
                    if (to == null || to.TCID == null)
                    {
                        c = new Coordinator();
                        Data.Coordinator.Add(c);
                    }
                    else
                    {
                        c = GetCoordinatorByID(Convert.ToInt32(to.TCID));
                        if (c == null)
                            throw new Exception(String.Format("Coordinator with ID {0} could not be found!", to.TCID));

                        // If Coordinator was not an FO (which is possible if TransplantOrgan was being updated), create new Coordinator instead of updating "wrong" TC of Swiss Hospital
                        if ((c.HospitalID != null && !HospitalIsFO(Convert.ToInt32(c.HospitalID)))
                            ||
                            ((c.HospitalID != null && HospitalIsFO(Convert.ToInt32(c.HospitalID))) &&
                             (c.FirstName != txtFOTCFirstname.Text.Trim() || c.LastName != txtFOTCLastname.Text.Trim())))
                        {
                            c = new Coordinator();
                            Data.Coordinator.Add(c);
                        }
                    }

                    c.LastName = !String.IsNullOrWhiteSpace(txtFOTCLastname.Text) ? txtFOTCLastname.Text : null;
                    c.FirstName = !String.IsNullOrWhiteSpace(txtFOTCFirstname.Text) ? txtFOTCFirstname.Text : null;
                    c.HospitalID = h.ID;
                }

                if (Data.SaveChanges() > 0) FODataHasBeenModified = true;

                if (c != null) coordinatorID = c.ID;

                BindTransplantCenterDropDownList();
                ddlTransplantCenter.SelectedValue = h.ID.ToString(CultureInfo.InvariantCulture);
            }
            catch (DbUpdateConcurrencyException concurrencyEx)
            {
                HandlePageRefreshAfterConcurrencyException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + concurrencyEx.Message);
                HasError = true;
            }
            catch (NullReferenceException nullReferenceEx)
            {
                // record has been deleted in the meantime!
                HandlePageRefreshAfterNullReferenceException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + nullReferenceEx.Message);
                HasError = true;
            }
            catch (DbEntityValidationException e)
            {
                logger.Error(MethodBase.GetCurrentMethod().Name +
                             " Save Address and new FO Procurement Hospital failed!");

                foreach (var eve in e.EntityValidationErrors)
                {
                    logger.Error(
                        String.Format("Entity of type \"{0}\" in state \"{1}\" has the following validation errors:",
                                      eve.Entry.Entity.GetType().Name, eve.Entry.State));

                    foreach (var ve in eve.ValidationErrors)
                    {
                        logger.Error(String.Format("- Property: \"{0}\", Error: \"{1}\"", ve.PropertyName,
                                                   ve.ErrorMessage));
                    }
                }

                const string message = "Save Address and new FO Procurement Hospital failed! ";
                WriteErrorLog(e, MethodBase.GetCurrentMethod().Name + " " + message);
                HasError = true;
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return coordinatorID;
        }

        private void BindDropDownLists()
        {
            TransplantOrgan to = GetTransplantOrganByID(TransplantOrganID);

            // Lifeport
            ddlLifeport.ClearSelection();
            ddlLifeport.DataSource = Data.Lifeport.Where(oc => oc.isActive).ToList();
            ddlLifeport.DataValueField = "ID";
            ddlLifeport.DataTextField = "Number";
            ddlLifeport.DataBind();
            ddlLifeport.Items.Insert(0,
                                            new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                         DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Organ
            int organID = to != null ? to.OrganID : 0;
            ddlOrgan.ClearSelection();
            ddlOrgan.DataSource = GetOrgans().Where(o => o.isActive || o.ID == organID).ToList();
            ddlOrgan.DataValueField = "ID";
            ddlOrgan.DataTextField = "Name";
            ddlOrgan.DataBind();
            ddlOrgan.Items.Insert(0,
                                  new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                               DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Transplant Center
            BindTransplantCenterDropDownList();

            // Procurement Team
            BindProcurementTeamDropDownList();

            // Status
            int? transplantStatusID = to != null && to.TransplantStatusID != null ? to.TransplantStatusID : 0;
            ddlStatus.ClearSelection();
            ddlStatus.DataSource =
                Data.TransplantStatus.Where(ts => ts.isActive || ts.ID == transplantStatusID).ToList();
            ddlStatus.DataValueField = "ID";
            ddlStatus.DataTextField = "Name";
            ddlStatus.DataBind();
            ddlStatus.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Necro-Report
            ddlReceivedNecroReportWithin5Days.ClearSelection();
            if (ddlReceivedNecroReportWithin5Days.Items.Count == 0)
            {
                ddlReceivedNecroReportWithin5Days.AppendDataBoundItems = true;
                ddlReceivedNecroReportWithin5Days.Items.Insert(0,
                                                               new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT, null));
                ddlReceivedNecroReportWithin5Days.Items.Insert(1, new ListItem("Yes", "1"));
                ddlReceivedNecroReportWithin5Days.Items.Insert(2, new ListItem("No", "0"));
                ddlReceivedNecroReportWithin5Days.DataBind();
            }
        }

        private void BindTransplantCenterDropDownList()
        {
            TransplantOrgan to = GetTransplantOrganByID(TransplantOrganID);

            // Transplant Center
            int? transplantCenterID = to != null && to.TransplantCenterID != null ? to.TransplantCenterID : 0;
            ddlTransplantCenter.ClearSelection();
            ddlTransplantCenter.DataSource = GetHospitals()
                .Where(h => h.IsTransplantation || h.ID == transplantCenterID)
                .Where(h => h.IsFo == IsFO)
                .Where(h => h.isActive || h.ID == transplantCenterID).Distinct()
                .OrderByDescending(h => h.IsTransplantation)
                .ThenBy(h => h.Display).ToList();
            ddlTransplantCenter.DataValueField = "ID";
            ddlTransplantCenter.DataTextField = "Display";
            ddlTransplantCenter.DataBind();
            ddlTransplantCenter.Items.Insert(0,
                                             new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                          DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Transplantation Coordinator
            int? tcID = to != null && to.TCID != null ? to.TCID : 0;
            ddlTC.ClearSelection();
            ddlTC.DataSource = GetCoordinators()
                .Where(c => (c.IsTC && !cbForeignTransplantCenter.Checked) || c.ID == tcID)
                .Where(c => c.isActive || c.ID == tcID).ToList();
            ddlTC.DataValueField = "ID";
            ddlTC.DataTextField = "Code";
            ddlTC.DataBind();
            if (!IsFO)
                ddlTC.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        /// <summary>
        ///     Binds Procurement-Team DropDownList
        /// </summary>
        /// <remarks>
        ///     If Procurement Hospital or Transplantation Hospital is foreign (FO) then DropDownList will have additional entry "FO-Team" which is selectable. All other selectable Hospitals are CH-Hospitals.
        ///     FO-Team is not a proper hospital and as such has the id -1 in table Hospital
        /// </remarks>
        private void BindProcurementTeamDropDownList()
        {
            Donor d = GetDonorByID(Master.DonorID);

            // Procurement Team
            bool includeFOTeam = d.ProcurementHospitalID != null
                                     ? HospitalIsFO(Convert.ToInt32(d.ProcurementHospitalID)) || IsFO
                                     : IsFO;
            int procurementHospitalID = d.Hospital1 != null ? d.Hospital1.ID : 0;
            ddlProcurementTeam.ClearSelection();
            ddlProcurementTeam.DataSource = GetHospitals(includeFOTeam)
                .Where(h => h.IsProcurement || (includeFOTeam && h.ID < 0) || h.ID == procurementHospitalID)
                .Where(h => h.isActive || h.ID == procurementHospitalID)
                .Where(h => !h.IsFo)
                .OrderBy(h => includeFOTeam && h.ID == -1 ? 0 : 1)
                // this makes sure that FO-Team is at the top of the list if FO-Team is selectable
                .ThenByDescending(h => h.IsTransplantation)
                .ThenBy(h => h.Display).ToList();
            ddlProcurementTeam.DataValueField = "ID";
            ddlProcurementTeam.DataTextField = "Display";
            ddlProcurementTeam.DataBind();
            ddlProcurementTeam.Items.Insert(0,
                                            new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                         DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void InitialiseDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();

            ddlOrgan.SelectedIndex = 0;
            ddlTransplantCenter.SelectedIndex = 0;
            ddlProcurementTeam.SelectedIndex = 0;
            ddlTC.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            ddlLifeport.SelectedIndex = 0;
            txtGraftBoxNo.Text = String.Empty;
            txtProcurementSurgeon.Text = String.Empty;
            chkPerfusionmachine.Checked = false;
            ddlReceivedNecroReportWithin5Days.SelectedIndex = 0;
            txtRemark.Text = String.Empty;

            pnlFOTransplantCenter.Visible = false;
            btnAddNewFOTransplantCenter.Visible = false;
            btnDelete.Visible = false;
            cbForeignTransplantCenter.Checked = false;
            trPerfusionMachine.Visible = false;

            InitialiseFOTransplantCenterDetails();
        }

        private void InitialiseFOTransplantCenterDetails()
        {
            txtFOTransplantCenterName.Text = String.Empty;
            txtFOTransplantCenterDisplay.Text = String.Empty;
            txtFOTransplantCenterAddress1.Text = String.Empty;
            txtFOTransplantCenterAddress2.Text = String.Empty;
            txtFOTransplantCenterAddress3.Text = String.Empty;
            txtFOTransplantCenterAddress4.Text = String.Empty;
            txtFOTransplantCenterZip.Text = String.Empty;
            txtFOTransplantCenterCity.Text = String.Empty;
            txtFOTransplantCenterCountryISO.Text = String.Empty;
            txtFOTransplantCenterPhone.Text = String.Empty;
            txtFOTransplantCenterFax.Text = String.Empty;
            txtFOTransplantCenterEmail.Text = String.Empty;
            txtFOTCLastname.Text = String.Empty;
            txtFOTCFirstname.Text = String.Empty;
        }


        protected void cbPerfusionmachine_CheckedChanged(object sender, EventArgs e)
        {
            CheckBox checkBox = sender as CheckBox;

            if (checkBox == null) return;

            if (checkBox.Checked)
            {
                ddlLifeport.Enabled = true;
            }else
            {
                ddlLifeport.Enabled = false;
            }
        }

        /// <summary>
        /// Set visibility of controls depending on given data conditions
        /// </summary>
        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            // Enabling for all roles
            pnlTransplantOrganDetails.Visible = true;
            pnlTransplantOrganDetails.Enabled = !DonorIsArchived(Master.DonorID);
            btnSave.Visible = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtGraftBoxNo.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            chkPerfusionmachine.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlLifeport.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            pnlFOTransplantCenter.Visible = IsFO;

            // Enable role depending controls
            txtProcurementSurgeon.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsTC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlOrgan.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlProcurementTeam.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlStatus.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlLifeport.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlTC.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !IsFO && !DonorIsArchived(Master.DonorID);
            ddlTransplantCenter.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlReceivedNecroReportWithin5Days.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            cbForeignTransplantCenter.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            btnAddNewFOTransplantCenter.Visible = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && IsFO && !DonorIsArchived(Master.DonorID);
            btnDelete.Visible = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && TransplantOrganID != 0 && !DonorIsArchived(Master.DonorID);

            // only set FO-related controls when FO panel is visible
            if (!pnlFOTransplantCenter.Visible) return;

            pnlFOTransplantCenter.Enabled = (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            gvTransplantOrgan.DataBind();

            if (gvTransplantOrgan.SelectedIndex >= 0) LoadAndViewDataDetails();
            else pnlTransplantOrganDetails.Visible = false;
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            TransplantOrganID = 0;
            gvTransplantOrgan.SelectedIndex = -1;
            gvTransplantOrgan.DataBind();
            pnlTransplantOrganDetails.Visible = false;
        }
        #endregion

        /// <summary>
        /// Link to creating new incident with prefilled informations
        /// </summary>
        protected void btnIncidentCreate_Click(object sender, EventArgs e)
        {
            string additional = String.Empty;
            if (Master.DonorID != 0)
            {
                additional = "?donorID=" + Master.DonorID.ToString();
            }

            if (TransplantOrganID != 0)
            {
                if (additional == String.Empty)
                {
                    additional = "?";
                }
                else
                {
                    additional += "&";
                }
                additional += "transplantOrganID=" + TransplantOrganID.ToString();
            }

            Response.Redirect("IncidentCreate.aspx" + additional);
        }

        protected void ddlOrgan_SelectedIndexChanged(object sender, EventArgs e)
        {
            setVisibilityOfPerfusionMachine();
        }

        internal void setVisibilityOfPerfusionMachine()
        {
            lblGraftBoxNo.Visible = false;
            txtGraftBoxNo.Visible = false;
            trPerfusionMachine.Visible = false;
            lblPerfusionmachineNumber.Visible = false;
            ddlLifeport.Visible = false;

            if (ddlOrgan.SelectedItem.Text.ToLower().Contains("kidney"))
            {
                trPerfusionMachine.Visible = true;
                lblPerfusionmachine.Text = "Perfusion machine";

                lblPerfusionmachineNumber.Visible = true;
                ddlLifeport.Visible = true;
                lblGraftBoxNo.Visible = true;
                txtGraftBoxNo.Visible = true;
            }
            else if (ddlOrgan.SelectedItem.Text.ToLower().Contains("lung"))
            {
                trPerfusionMachine.Visible = true;
                lblPerfusionmachine.Text = "Perfusion machine Ex Vivo";
            }
            else if (ddlOrgan.SelectedItem.Text.ToLower().Contains("liver"))
            {
                trPerfusionMachine.Visible = true;
                lblPerfusionmachine.Text = "Perfusion machine Hope";
            }
        }
    }
}