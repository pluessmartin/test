using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Data.Entity.Infrastructure;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Web;
using System.Web.ModelBinding;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public partial class Search : BasePage
    {
        #region Properties
        protected bool FODataHasBeenModified = false;

        protected int DonorPageIndex
        {
            get { return hidPageIndex.Value == String.Empty ? 0 : Convert.ToInt32(hidPageIndex.Value); }
            set { hidPageIndex.Value = value.ToString(CultureInfo.InvariantCulture); }
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
            // When it's only incident user --> create incident
            if (Master.IsIncidentUser && !Master.IsAAA && !Master.IsAdmin && !Master.IsTC && !Master.IsNC && !Master.IsSwisstransplant && !Master.IsIncidentAdmin)
            {
                Response.Redirect("IncidentCreate.aspx");
            }
            logger.Debug("Search called");

            if (IsPostBack) return;

            string donorID = HttpUtility.UrlDecode(Request.QueryString["donorID"]);
            if (donorID != null) Master.DonorID = Convert.ToInt32(donorID);

            SetPossibleDateValueRangesForDateControls();

            // set visibilty of "Add new..."-button initially depending on user rights
            btnAddNewDonor.Visible = Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant;
            btnIncidentCreate.Visible = !Master.IsOnlyAAA;

            if (Master.DonorID <= 0) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();

            // If Donor is archived set filter accordingly to include archives to make Donor appear in the list.
            if (DonorIsArchived(Master.DonorID))
            {
                cbxInclArchive.Checked = true;
            }

            SelectRowInGridView(Master.DonorID);
        }

        /// <summary>
        ///     Selection/Fill Method for gvDonor
        /// </summary>
        /// <param name="donorNumber">asp.new 4.5 ModellBinding magically from txtDonorNumberSearch</param>
        /// <param name="regFrom">asp.new 4.5 ModellBinding magically from txtRegisterDateFrom</param>
        /// <param name="regTo">asp.new 4.5 ModellBinding magically from txtRegisterDateTo</param>
        /// <param name="procFrom">asp.new 4.5 ModellBinding magically from txtProcurementDateFrom</param>
        /// <param name="procTo">asp.new 4.5 ModellBinding magically from txtProcurementDateTo</param>
        /// <param name="invoiceNo">asp.new 4.5 ModellBinding magically from txtInvoiceNumberSearch</param>
        /// <param name="includeArchives">asp.new 4.5 ModellBinding magically from cbxInclArchive</param>
        /// <returns></returns>
        public IQueryable<Donor> gvDonor_GetData([Control("txtDonorNumberSearch")] string donorNumber,
                                                 [Control("txtRegisterDateFrom")] DateTime? regFrom,
                                                 [Control("txtRegisterDateTo")] DateTime? regTo,
                                                 [Control("txtProcurementDateFrom")] DateTime? procFrom,
                                                 [Control("txtProcurementDateTo")] DateTime? procTo,
                                                 [Control("txtInvoiceNumberSearch")] string invoiceNo,
                                                 [Control("cbxInclArchive")] bool includeArchives)
        {
            IQueryable <Donor> retVal = GetDonors()
                .Where(d => String.IsNullOrEmpty(donorNumber) || d.DonorNumber.Contains(donorNumber))
                .Where(d => regFrom == null || d.RegisterDate >= regFrom)
                .Where(d => regTo == null || d.RegisterDate <= regTo)         
                .Where(d => procFrom == null || d.ProcurementDate >= procFrom)
                .Where(d => procTo == null || d.ProcurementDate <= procTo)
                .Where(d => includeArchives || !includeArchives && d.IsArchived == false)
                .Where(d => String.IsNullOrEmpty(invoiceNo) || d.Cost.Any(c => c.InvoiceNo.Contains(invoiceNo)))
                .OrderByDescending(d => d.ID);
            return retVal;
        }

        protected void gvDonor_SelectedIndexChanged(object sender, EventArgs e)
        {
            // If a row was selected, set DonorID Property and populate detail view
            if (gvDonor.SelectedIndex != -1)
            {
                Master.DonorID = Convert.ToInt32(gvDonor.SelectedPersistedDataKey.Value);

                DonorPageIndex = gvDonor.PageIndex;

                LoadAndViewDataDetails();
            }
            else
            {
                Master.DonorID = 0;
                DonorPageIndex = 0;
            }
        }

        protected void ddlNC_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Set NC details
            PopulateNCDetailView(Convert.ToInt32(ddlNC.SelectedValue));
        }

        protected void ddlProcurementHospital_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!IsFO) return;

            // Set FO Procurement Hospital details
            PopulateForeignHospitalDetailView(Convert.ToInt32(ddlProcurementHospital.SelectedValue));
            pnlFOProcurementHospital.Enabled = Convert.ToInt32(ddlProcurementHospital.SelectedValue) > 0;
        }

        protected void Search_FilterChanged(object sender, EventArgs e)
        {
            Page.Validate("SearchGroup");
            if (!Page.IsValid) return;

            gvDonor.PageIndex = 0;
        }

        protected void txtDonorNumber_TextChanged(object sender, EventArgs e)
        {
            bool oldISFo = IsFO;
            IsFO = txtDonorNumber.Text.Trim().Length > 1 && txtDonorNumber.Text.Trim().Substring(0, 2).ToLower() == "fo";

            //only change view and reload dropdownlists when IsFO changed
            if (oldISFo == IsFO) return;

            SetVisibilityAndAccessOfFORelatedControlsDependingOnGivenDataCondition();
            InitialiseFOProcurementDetails();
            BindFORelatedDropDownLists();
        }

        protected void cbxInclArchive_CheckedChanged(object sender, EventArgs e)
        {
            SelectRowInGridView(Master.DonorID);
        }

        protected void btnAddNewDonor_Click(object sender, EventArgs e)
        {
            // Initialise values
            Master.DonorID = 0;
            IsFO = false;

            BindDonorOverview();

            // set last pagecount as pageIndex which will be used when save button is clicked
            if (gvDonor.PageCount > 1) DonorPageIndex = gvDonor.PageCount - 1;

            // unselect possible selected row
            gvDonor.SelectRow(-1);
            gvDonor.PageIndex = 0;

            InitialiseDetailView();
        }

        protected void btnAddNewFOProcHospital_Click(object sender, EventArgs e)
        {
            ddlProcurementHospital.SelectedIndex = 0;

            PopulateForeignHospitalDetailView(Convert.ToInt32(ddlProcurementHospital.SelectedValue));

            pnlFOProcurementHospital.Enabled = true;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);
                    return;
                }

                int coordinatorID = IsFO ? SaveForeignProcurementHospital(Convert.ToInt32(ddlProcurementHospital.SelectedValue)) : 0;
                if (HasError) return;

                bool isRowAdded = Master.DonorID == 0;

                Donor d = AssignValuesToDonor(coordinatorID, isRowAdded);

                if (Data.SaveChanges() > 0 || FODataHasBeenModified)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }

  

                Master.DonorID = d.ID;

                // Refresh DataGridView
                gvDonor.DataBind();

                // Refresh Overview Grid
                BindDonorOverview();

                // Jump to last index after adding a row
                if (isRowAdded)
                {
                    SelectRowInGridView(d.ID);
                }
                else
                {
                    // Jump to the specified page
                    gvDonor.PageIndex = DonorPageIndex;
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

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + nullReferenceEx.Message);
                HasError = true;
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not save Delay! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                HasError = true;
            }
        }

        protected void btnArchiveHandling_Click(object sender, EventArgs e)
        {
            try
            {
                Donor d = GetDonorByID(Master.DonorID);
                if (d == null) throw new NullReferenceException(String.Format("Donor with ID {0} could not be found!", Master.DonorID));

                // Validate if all necessary Fields are available and only then archive!
                if (!d.IsArchived && !FieldsToArchiveAreValid()) return;

                int coordinatorID = IsFO ? SaveForeignProcurementHospital(Convert.ToInt32(ddlProcurementHospital.SelectedValue)) : 0;
                if (HasError) return;

                AssignValuesToDonor(coordinatorID, false);

                d.IsArchived = !d.IsArchived;

                if (Data.SaveChanges() > 0 || FODataHasBeenModified)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }

                btnArchiveHandling.Text = d.IsArchived ? "Reactivate" : "Archive";

                SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
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

                const string message = "Could not save Delay! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                HasError = true;
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (gvDonor.SelectedDataKey != null)
                {
                    Donor d = GetDonorByID(Convert.ToInt32(gvDonor.SelectedDataKey.Value));
                    if (d == null) throw new NullReferenceException(String.Format("Donor with ID {0} could not be found!", gvDonor.SelectedDataKey.Value));

                    d.IsDeleted = true;
                }
                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgDeleteSuccess, SLIDSMaster.LabelState.Success);

                    // Reset DonorID and refresh DataGrid
                    Master.DonorID = 0;
                    gvDonor.SelectedIndex = -1;
                    gvDonor.DataBind();
                    pnlDonor.Visible = false;
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

                const string message = "Could not delete Donor! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                HasError = true;
            }
        }

        #region Privates
        private void LoadAndViewDataDetails()
        {
            Donor d = GetDonorByID(Master.DonorID);
            if (d == null) return;

            IsFO = HospitalIsFO(Convert.ToInt32(d.ProcurementHospitalID));

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
            PopulateDonorDetailView(d);

            BindDonorOverview();
        }

        private Donor AssignValuesToDonor(int coordinatorID, bool isRowAdded)
        {
            Donor d;

            if (isRowAdded)
            {
                // create new datarow
                d = new Donor();
                Data.Donor.Add(d);
            }
            else
            {
                // update existing datarow
                d = GetDonorByID(Master.DonorID);
                if (d == null) throw new ArgumentNullException(String.Format("Donor with ID {0} could not be found!", Master.DonorID));
            }

            d.DonorNumber = txtDonorNumber.Text;
            d.DetectionHospitalID = IsFO
                                        ? null
                                        : Convert.ToInt32(ddlDetectionHospital.SelectedValue) > 0
                                              ? (int?)Convert.ToInt32(ddlDetectionHospital.SelectedValue)
                                              : null;
            d.ReferralHospitalID = IsFO
                                       ? null
                                       : Convert.ToInt32(ddlReferralHospital.SelectedValue) > 0
                                             ? (int?)Convert.ToInt32(ddlReferralHospital.SelectedValue)
                                             : null;
            d.ProcurementHospitalID = Convert.ToInt32(ddlProcurementHospital.SelectedValue) > 0
                                          ? (int?)Convert.ToInt32(ddlProcurementHospital.SelectedValue)
                                          : null;

            d.ID_DonationPathway = Convert.ToInt32(ddlDonationPathway.SelectedValue) > 0
                                         ? (int?)Convert.ToInt32(ddlDonationPathway.SelectedValue)
                                         : null;

            d.RegisterDate = !String.IsNullOrWhiteSpace(txtRegisterDate.Text)
                                 ? (DateTime?)Convert.ToDateTime(txtRegisterDate.Text)
                                 : null;
            d.ProcurementDate = !String.IsNullOrWhiteSpace(txtProcurementDate.Text)
                                    ? (DateTime?)Convert.ToDateTime(txtProcurementDate.Text)
                                    : null;

            d.IncisionMade = chkIncisionMade.Checked;
            d.Nut = chNut.Checked;

            d.NCID = Convert.ToInt32(ddlNC.SelectedValue);
            d.Comment = String.IsNullOrWhiteSpace(txtComment.Text) ? null : txtComment.Text;
            if (IsFO)
            {
                d.OrganizationID = Convert.ToInt32(ddlOrganisation.SelectedValue) > 0
                                       ? (int?)Convert.ToInt32(ddlOrganisation.SelectedValue)
                                       : null;
                d.TCID = coordinatorID > 0 ? (int?)coordinatorID : null;
            }
            else
            {
                d.OrganizationID = null;
                d.TCID = Convert.ToInt32(ddlTC.SelectedValue) > 0
                             ? (int?)Convert.ToInt32(ddlTC.SelectedValue)
                             : null;
            }

            if (!IsFO && Convert.ToInt32(ddlDetectionHospital.SelectedValue) > 0) d.Hospital = GetHospitalByID(Convert.ToInt32(ddlDetectionHospital.SelectedValue));
            if (!IsFO && Convert.ToInt32(ddlReferralHospital.SelectedValue) > 0) d.Hospital2 = GetHospitalByID(Convert.ToInt32(ddlReferralHospital.SelectedValue));
            if (Convert.ToInt32(ddlProcurementHospital.SelectedValue) > 0) d.Hospital1 = GetHospitalByID(Convert.ToInt32(ddlProcurementHospital.SelectedValue));

            return d;
        }

        private void PopulateDonorDetailView(Donor d)
        {
            if (d == null) throw new Exception("Donor datarow was not provided!");

            // Set Text of Archive-Button depending on archive-state of donor
            btnArchiveHandling.Text = d.IsArchived ? "Reactivate" : "Archive";

            // Bind dropdownlists
            BindDropDownLists(d);

            // Populate controls
            if (IsFO && d.OrganizationID != null) ddlOrganisation.SelectedValue = d.OrganizationID.ToString();
            if (d.DetectionHospitalID != null) ddlDetectionHospital.SelectedValue = d.DetectionHospitalID.ToString();
            if (d.ReferralHospitalID != null) ddlReferralHospital.SelectedValue = d.ReferralHospitalID.ToString();
            if (!IsFO && d.ProcurementHospitalID != null) ddlProcurementHospital.SelectedValue = d.ProcurementHospitalID.ToString();

            if (d.ID_DonationPathway != null) ddlDonationPathway.SelectedValue = d.ID_DonationPathway.ToString();

            ddlNC.SelectedValue = d.NCID.ToString();
            if (!IsFO && d.TCID != null) ddlTC.SelectedValue = d.TCID.ToString();
            txtRegisterDate.Text = String.Format("{0:dd.MM.yyyy}", d.RegisterDate);
            txtProcurementDate.Text = String.Format("{0:dd.MM.yyyy}", d.ProcurementDate);
            chkIncisionMade.Checked = d.IncisionMade;
            chNut.Checked = d.Nut;

            txtDonorNumber.Text = d.DonorNumber;
            txtComment.Text = d.Comment;

            if (d.NCID != null)
            {
                PopulateNCDetailView(Convert.ToInt32(d.NCID));
            }

            if (IsFO)
            {
                PopulateForeignHospitalDetailView(Convert.ToInt32(d.ProcurementHospitalID));
            }
        }

        private void PopulateNCDetailView(int nationalCoordID)
        {
            if (nationalCoordID == 0) return;

            Coordinator c = GetCoordinatorByID(nationalCoordID);
            if (c == null)
                throw new ArgumentNullException(String.Format("Coordinator with ID {0} could not be found!",
                                                              nationalCoordID));

            Address a = GetAddressByID(Convert.ToInt32(c.AddressID));
            if (a != null)
            {
                pnlNC.Visible = true;
                txtNCPhoneNo.Text = a.Phone;
               // txtNCFax.Text = a.Fax;
                txtNCEmail.Text = a.Email;
            }
        }

        private void PopulateForeignHospitalDetailView(int hospitalID)
        {
            if (hospitalID <= 0)
            {
                InitialiseFOProcurementDetails();
                return;
            }

            Donor d = GetDonorByID(Master.DonorID);

            Hospital h = GetHospitalByID(hospitalID);
            if (h == null) throw new ArgumentNullException(String.Format("Hospital with ID {0} could not be found!", hospitalID));
            IsFO = h.IsFo;

            ddlProcurementHospital.SelectedValue = h.ID.ToString(CultureInfo.InvariantCulture);

            Address a = GetAddressByID(Convert.ToInt32(h.AddressID));
            if (a != null)
            {
                txtFOProcHospitalName.Text = h.Name;
                txtFOProcHospitalDisplay.Text = h.Display;
                txtFOProcHospitalAddress1.Text = a.Address1;
                txtFOProcHospitalAddress2.Text = a.Address2;
                txtFOProcHospitalAddress3.Text = a.Address3;
                txtFOProcHospitalAddress4.Text = a.Address4;
                txtFOProcHospitalZip.Text = a.Zip;
                txtFOProcHospitalCity.Text = a.City;
                txtFOProcHospitalCountryISO.Text = a.CountryISO;
                txtFOProcHospitalPhone.Text = a.Phone;
                txtFOProcHospitalFax.Text = a.Fax;
                txtFOProcHospitalEmail.Text = a.Email;
            }

            if (d != null && d.TCID != null)
            {
                Coordinator c = GetCoordinatorByID(Convert.ToInt32(d.TCID));
                if (c != null)
                {
                    txtFOTCLastname.Text = c.LastName;
                    txtFOTCFirstname.Text = c.FirstName;
                }
            }
            else
            {
                txtFOTCLastname.Text = String.Empty;
                txtFOTCFirstname.Text = String.Empty;
            }
        }

        private void BindDropDownLists(Donor d)
        {
            // Hosiptals
            BindFORelatedDropDownLists();

            int? ncID = d != null && d.NCID != null ? d.NCID : 0;
            // National Coordinator
            ddlNC.ClearSelection();
            ddlNC.DataSource = GetCoordinators()
                .Where(c => c.IsNC || c.ID == ncID)
                .Where(c => c.isActive || c.ID == ncID)
                .ToList();
            ddlNC.DataValueField = "ID";
            ddlNC.DataTextField = "Code";
            ddlNC.DataBind();
            if (ddlNC.Enabled)
                ddlNC.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));

            //Bind Organisation
            int? organisationID = d != null && d.OrganizationID != null ? d.OrganizationID : 0;
            ddlOrganisation.ClearSelection();
            ddlOrganisation.DataSource = Data.Organization
                                             .Where(o => o.isActive || o.ID == organisationID)
                                             .ToList();
            ddlOrganisation.DataValueField = "ID";
            ddlOrganisation.DataTextField = "Name";
            ddlOrganisation.DataBind();
            if (ddlOrganisation.Enabled)
                ddlOrganisation.Items.Insert(0,
                                             new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                          DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void BindFORelatedDropDownLists()
        {
            Donor d = GetDonorByID(Master.DonorID);

            // Detection Hospital
            int detectionHospitalID = d != null && d.Hospital != null ? d.Hospital.ID : 0;
            ddlDetectionHospital.ClearSelection();
            ddlDetectionHospital.DataSource = GetHospitals()
                .Where(h => h.IsReferral || h.ID == detectionHospitalID)
                .Where(h => h.IsFo == IsFO)
                .Where(h => h.isActive || h.ID == detectionHospitalID)
                .OrderByDescending(h => h.IsTransplantation)
                .ThenBy(h => h.Display)
                .ToList();
            ddlDetectionHospital.DataValueField = "ID";
            ddlDetectionHospital.DataTextField = "Display";
            ddlDetectionHospital.DataBind();
            if (!IsFO)
                ddlDetectionHospital.Items.Insert(0,
                                                 new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                              DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Referral Hospital
            int referralHospitalID = d != null && d.Hospital2 != null ? d.Hospital2.ID : 0;
            ddlReferralHospital.ClearSelection();
            ddlReferralHospital.DataSource = GetHospitals()
                .Where(h => h.IsReferral || h.ID == referralHospitalID)
                .Where(h => h.IsFo == IsFO)
                .Where(h => h.isActive || h.ID == referralHospitalID)
                .OrderByDescending(h => h.IsTransplantation)
                .ThenBy(h => h.Display)
                .ToList();
            ddlReferralHospital.DataValueField = "ID";
            ddlReferralHospital.DataTextField = "Display";
            ddlReferralHospital.DataBind();
            if (!IsFO)
                ddlReferralHospital.Items.Insert(0,
                                                 new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                              DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Procurement Hosiptal
            int procurementHospitalID = d != null && d.Hospital1 != null ? d.Hospital1.ID : 0;
            ddlProcurementHospital.ClearSelection();
            ddlProcurementHospital.DataSource = GetHospitals()
                .Where(h => h.IsProcurement || h.ID == procurementHospitalID)
                .Where(h => h.IsFo == IsFO)
                .Where(h => h.isActive || h.ID == procurementHospitalID)
                .OrderByDescending(h => h.IsTransplantation)
                .ThenBy(h => h.Display)
                .ToList();
            ddlProcurementHospital.DataValueField = "ID";
            ddlProcurementHospital.DataTextField = "Display";
            ddlProcurementHospital.DataBind();
            if (ddlProcurementHospital.Enabled)
                ddlProcurementHospital.Items.Insert(0,
                                                    new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                                 DropDownDefaultValue.DDL_DEFAULT_VALUE));


            //int donationPathwayID = d != null && d.DonationPathway != null ? d.DonationPathway.ID : 0;
            ddlDonationPathway.ClearSelection();
            ddlDonationPathway.DataSource = GetDonationPathway()
                .Where(h => h.isActive)
                .OrderBy(h => h.Position)
                .ToList();
            ddlDonationPathway.DataValueField = "ID";
            ddlDonationPathway.DataTextField = "Name";
            ddlDonationPathway.DataBind();
            if (ddlDonationPathway.Enabled)
                ddlDonationPathway.Items.Insert(0,
                                                    new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                                 DropDownDefaultValue.DDL_DEFAULT_VALUE));


            // Transplantation Coordinator
            int? tcID = d != null && d.TCID != null ? d.TCID : 0;
            ddlTC.ClearSelection();
            ddlTC.DataSource = GetCoordinators()
                .Where(c => (c.IsTC && !IsFO) || c.ID == tcID)
                .Where(c => c.isActive || c.ID == tcID)
                .ToList();
            ddlTC.DataValueField = "ID";
            ddlTC.DataTextField = "Code";
            ddlTC.DataBind();
            if (!IsFO)
                ddlTC.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void BindDonorOverview()
        {
            GridView gvSelectedDonor = (GridView)Master.FindControl("gvSelectedDonor");
            if (gvSelectedDonor != null)
            {
                gvSelectedDonor.DataBind();
            }
            GridView gvSelectedDonorIncident = (GridView)Master.FindControl("gvSelectedDonorIncident");
            if (gvSelectedDonorIncident != null)
            {
                gvSelectedDonorIncident.DataBind();
            }
        }

        /// <summary>
        ///     Saves Data of foreign Procurement Hospital which can be edited when Donor is foreign (Donor No starts with "FO")
        /// </summary>
        /// <param name="hospitalID">Hospital ID</param>
        private int SaveForeignProcurementHospital(int hospitalID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            int coordinatorID = 0;

            try
            {
                Donor d = GetDonorByID(Master.DonorID);

                bool isRowAdded = hospitalID == 0;
                bool saveFOTCIsRequired = (d != null && d.TCID != null) ||
                                          (!String.IsNullOrWhiteSpace(txtFOTCFirstname.Text) ||
                                           !String.IsNullOrWhiteSpace(txtFOTCLastname.Text));
                if (d != null && d.TCID != null) coordinatorID = Convert.ToInt32(d.TCID);
                Hospital h;
                Address a;


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
                    if (h == null)
                        throw new ArgumentNullException(String.Format("Hospital with ID {0} could not be found!",
                                                                      hospitalID));

                    a = GetAddressByID(h.AddressID);
                    if (a == null)
                        throw new ArgumentNullException(String.Format("Address with ID {0} could not be found!",
                                                                      h.AddressID));
                }

                a.Address1 = !String.IsNullOrWhiteSpace(txtFOProcHospitalAddress1.Text)
                                 ? txtFOProcHospitalAddress1.Text
                                 : null;
                a.Address2 = !String.IsNullOrWhiteSpace(txtFOProcHospitalAddress2.Text)
                                 ? txtFOProcHospitalAddress2.Text
                                 : null;
                a.Address3 = !String.IsNullOrWhiteSpace(txtFOProcHospitalAddress3.Text)
                                 ? txtFOProcHospitalAddress3.Text
                                 : null;
                a.Address4 = !String.IsNullOrWhiteSpace(txtFOProcHospitalAddress4.Text)
                                 ? txtFOProcHospitalAddress4.Text
                                 : null;
                a.Zip = !String.IsNullOrWhiteSpace(txtFOProcHospitalZip.Text) ? txtFOProcHospitalZip.Text : null;
                a.City = !String.IsNullOrWhiteSpace(txtFOProcHospitalCity.Text) ? txtFOProcHospitalCity.Text : null;
                a.CountryISO = !String.IsNullOrWhiteSpace(txtFOProcHospitalCountryISO.Text.Trim())
                                   ? txtFOProcHospitalCountryISO.Text
                                   : null;
                a.Phone = !String.IsNullOrWhiteSpace(txtFOProcHospitalPhone.Text) ? txtFOProcHospitalPhone.Text : null;
                a.Fax = !String.IsNullOrWhiteSpace(txtFOProcHospitalFax.Text) ? txtFOProcHospitalFax.Text : null;
                a.Email = !String.IsNullOrWhiteSpace(txtFOProcHospitalEmail.Text) ? txtFOProcHospitalEmail.Text : null;

                h.Name = !String.IsNullOrWhiteSpace(txtFOProcHospitalName.Text) ? txtFOProcHospitalName.Text : null;
                h.Display = !String.IsNullOrWhiteSpace(txtFOProcHospitalDisplay.Text)
                                ? txtFOProcHospitalDisplay.Text
                                : h.Name;
                h.AddressID = a.ID;
                h.IsReferral = false;
                h.IsProcurement = true;
                h.IsFo = true;
                h.isActive = true;

                if (Data.SaveChanges() > 0) FODataHasBeenModified = true;

                hospitalID = h.ID;

                if (saveFOTCIsRequired)
                {
                    Coordinator c;

                    if (coordinatorID == 0)
                    {
                        c = new Coordinator();
                        Data.Coordinator.Add(c);
                    }
                    else
                    {
                        c = GetCoordinatorByID(coordinatorID);
                    }

                    c.LastName = !String.IsNullOrWhiteSpace(txtFOTCLastname.Text) ? txtFOTCLastname.Text : null;
                    c.FirstName = !String.IsNullOrWhiteSpace(txtFOTCFirstname.Text) ? txtFOTCFirstname.Text : null;
                    c.HospitalID = hospitalID;

                    if (Data.SaveChanges() > 0) FODataHasBeenModified = true;

                    if (c != null) coordinatorID = c.ID;
                }

                BindFORelatedDropDownLists();
                ddlProcurementHospital.SelectedValue = hospitalID.ToString(CultureInfo.InvariantCulture);
            }
            catch (DbUpdateConcurrencyException concurrencyEx)
            {
                HandlePageRefreshAfterConcurrencyException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating Address and new FO Procurement Hospital configuration due to a concurrency error: " + concurrencyEx.Message);
                HasError = true;
            }
            catch (NullReferenceException nullReferenceEx)
            {
                // record has been deleted in the meantime!
                HandlePageRefreshAfterNullReferenceException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating Address and new FO Procurement Hospital configuration due to a concurrency error: " + nullReferenceEx.Message);
                HasError = true;
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not save Delay! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                HasError = true;
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return coordinatorID;
        }

        private bool FieldsToArchiveAreValid()
        {
            StringBuilder errorMsg = new StringBuilder();
            String nonValidFields = String.Empty;
            String[] arrNonValidFields;

            // Validate Donor fields
            Donor d = GetDonorByID(Master.DonorID);
            if (d == null)
                throw new ArgumentNullException(String.Format("Donor with ID {0} could not be found!", Master.DonorID));

            if (d.DonorNumber == null) nonValidFields += "Donor Number,";
            if (!IsFO && d.ReferralHospitalID == null) nonValidFields += "Referral Hospital,";
            if (d.ProcurementHospitalID == null) nonValidFields += "Procurement Hospital,";
            if (d.RegisterDate == null) nonValidFields += "RegisterDate,";
            /*if (d.ProcurementDate == null) nonValidFields += "ProcurementDate,";*/
            if (d.NCID == null) nonValidFields += "National Coordinator,";
            if (d.NCID != null && d.Coordinator.Address.Phone == null)
                nonValidFields += "Phone number of National Coordinator,";
            if (d.ProcurementHospitalID != null
                && d.Hospital1.IsFo
                && d.Hospital1.Name == null) nonValidFields += "Name of FO-Procurement Hospital,";
            if (d.ProcurementHospitalID != null
                && d.Hospital1.IsFo
                && d.Hospital1.Display == null) nonValidFields += "Short Name of FO-Procurement Hospital,";
            if (d.ProcurementHospitalID != null
                && d.Hospital1.IsFo
                && d.Hospital1.Address1.Address1 == null) nonValidFields += "Address of FO-Procurement Hospital,";
            if (d.ProcurementHospitalID != null
                && d.Hospital1.IsFo
                && d.Hospital1.Address1.City == null) nonValidFields += "City of FO-Procurement Hospital,";
            if (d.ProcurementHospitalID != null
                && d.Hospital1.IsFo
                && d.Hospital1.Address1.CountryISO == null)
                nonValidFields += "Country-ISO Code of FO-Procurement Hospital,";

            // Prepare message for non valid donor related fields
            if (nonValidFields.Length > 0)
            {
                errorMsg.AppendLine("<br>Donor related fields:");
                arrNonValidFields = nonValidFields.Split(new[] { ',' });
                foreach (string s in arrNonValidFields)
                {
                    errorMsg.Append("<br>");
                    errorMsg.Append(s);
                }

                // Reinitialise nonValidFields
                nonValidFields = String.Empty;
            }

            // Validate Transport
            foreach (DAL.Transport t in GetTransportsByDonorID(Master.DonorID).ToList())
            {
                if (t.DepartureHospitalID == null &&
                    (t.OtherDeparture == null || String.IsNullOrWhiteSpace(t.OtherDeparture)))
                    nonValidFields += String.Format("Departure location of Transport '{0}',", GetTransportedElements(t));
                if (t.Departure == null)
                    nonValidFields += String.Format("Departure date and time of Transport '{0}',",
                                                    GetTransportedElements(t));
                if (t.DestinationHospitalID == null &&
                    (t.OtherDestination == null || String.IsNullOrWhiteSpace(t.OtherDestination)))
                    nonValidFields += String.Format("Destination location of Transport '{0}',",
                                                    GetTransportedElements(t));
                if (t.Departure == null)
                    nonValidFields += String.Format("Destination date and time of Transport '{0}',",
                                                    GetTransportedElements(t));
            }

            // Prepare message for non valid transport related fields
            if (nonValidFields.Length > 0)
            {
                errorMsg.AppendLine("<br>Transport related fields:");
                arrNonValidFields = nonValidFields.Split(new[] { ',' });
                foreach (string s in arrNonValidFields)
                {
                    errorMsg.Append("<br>");
                    errorMsg.Append(s);
                }
            }

            // If there are non valid fields, pre-append general error message and return false
            if (errorMsg.Length > 0)
            {
                errorMsg.Insert(0,
                                "The donor could not be archived. The following fields are mandatory to enable a donor to be archived:<br>");
                Master.SetInfoLabel(errorMsg.ToString(), SLIDSMaster.LabelState.Error);
                return false;
            }

            // All fields are valid
            return true;
        }

        /// <summary>
        /// Set visibility of controls depending on given data conditions
        /// </summary>
        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            // Set visibility
            pnlDonor.Visible = true;
            btnSave.Visible = (Master.DonorID == 0 || !DonorIsArchived(Master.DonorID)) && (Master.IsNC || Master.IsAdmin || Master.IsTC || Master.IsAAA || Master.IsSwisstransplant);
            btnDelete.Visible = Master.DonorID != 0 && !DonorIsArchived(Master.DonorID) && (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant);
            btnArchiveHandling.Visible = Master.DonorID != 0 && (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant);

            bool enable = (Master.DonorID == 0 || !DonorIsArchived(Master.DonorID)) && (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant);
            // Disable or enable controls inside pnlDonor one by one in order to handle enable-state of btnArchiveHandling (instead of simply enabling or disabling pnlDonor itself)
            EnableOrDisableControls(pnlDonor, enable);
            // enable Textbox "Comment" for all users (unless donor is archived)
            txtComment.Enabled = (Master.DonorID == 0 || !DonorIsArchived(Master.DonorID));
            // always allow archive or reactivate
            btnArchiveHandling.Enabled = true;
            // enable Save button when visible
            btnSave.Enabled = btnSave.Visible;
            // NC-Panel is always disabled
            pnlNC.Enabled = false;
            // Set visibility and access of FO-related controls depending on given data conditions
            SetVisibilityAndAccessOfFORelatedControlsDependingOnGivenDataCondition();

            // only set FO-related controls when FO panel is visible
            if (!pnlFOProcurementHospital.Visible) return;

            pnlFOProcurementHospital.Enabled = Master.DonorID != 0 && !DonorIsArchived(Master.DonorID);
        }

        /// <summary>
        /// Set Visiblity and Access of Controls depending if Donor is FO or not
        /// </summary>
        private void SetVisibilityAndAccessOfFORelatedControlsDependingOnGivenDataCondition()
        {
            // Set visibility of FO panel and Organisation when procurement hospital is FO
            pnlFOProcurementHospital.Visible = IsFO;
            lblOrganisation.Visible = IsFO;
            ddlOrganisation.Visible = IsFO;

            bool donorIsArchived = Master.DonorID != 0 && DonorIsArchived(Master.DonorID);

            // Enable Detection and Referral hospital when procurement hospital is not FO and donor is not archived (and user is either NC or Admin) or else disable
            ddlDetectionHospital.Enabled = !IsFO
                                          && !donorIsArchived
                                          && (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant);

            ddlReferralHospital.Enabled = ddlDetectionHospital.Enabled;

            // Enable DropdownList Transplant Coordinator when procurement hospital is not FO and donor is not archived (and user is either NC, Admin or TC) or else disable
            ddlTC.Enabled = !IsFO
                            && !donorIsArchived
                            && (Master.IsNC || Master.IsAdmin || Master.IsTC) || Master.IsSwisstransplant;

            // Set button "add new FO hospital" visible when procurement hospital is FO and donor is not archived (and user is either NC or Admin) or else disable
            btnAddNewFOProcHospital.Visible = IsFO
                                              && !donorIsArchived
                                              && (Master.IsNC || Master.IsAdmin || Master.IsSwisstransplant);
        }

        private void InitialiseDetailView()
        {
            // Set Visibility and enable controls
            pnlNC.Visible = false;
            pnlFOProcurementHospital.Visible = false;
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();

            // Initialise Controls with default values
            BindDropDownLists(null);
            txtDonorNumber.Text = String.Empty;
            lblOrganisation.Visible = false;
            ddlOrganisation.Visible = false;
            ddlDetectionHospital.SelectedIndex = -1;
            ddlReferralHospital.SelectedIndex = -1;
            ddlProcurementHospital.SelectedIndex = -1;
            ddlDonationPathway.SelectedIndex = -1;
            txtRegisterDate.Text = String.Empty;
            txtProcurementDate.Text = String.Empty;
            chkIncisionMade.Checked = false;
            chNut.Checked = false;
            ddlNC.SelectedIndex = -1;
            ddlTC.SelectedIndex = -1;
            txtComment.Text = String.Empty;

            InitialiseFOProcurementDetails();
        }

        private void InitialiseFOProcurementDetails()
        {
            txtFOProcHospitalName.Text = String.Empty;
            txtFOProcHospitalDisplay.Text = String.Empty;
            txtFOProcHospitalAddress1.Text = String.Empty;
            txtFOProcHospitalAddress2.Text = String.Empty;
            txtFOProcHospitalAddress3.Text = String.Empty;
            txtFOProcHospitalAddress4.Text = String.Empty;
            txtFOProcHospitalZip.Text = String.Empty;
            txtFOProcHospitalCity.Text = String.Empty;
            txtFOProcHospitalCountryISO.Text = String.Empty;
            txtFOProcHospitalPhone.Text = String.Empty;
            txtFOProcHospitalFax.Text = String.Empty;
            txtFOProcHospitalEmail.Text = String.Empty;
            txtFOTCLastname.Text = String.Empty;
            txtFOTCFirstname.Text = String.Empty;
            pnlFOProcurementHospital.Enabled = false;
        }

        private void SetPossibleDateValueRangesForDateControls()
        {
            // Search Filter Controls
            rvRegisterDateFrom.MinimumValue = new DateTime(1600, 01, 01).ToString("dd.MM.yyyy");
            rvRegisterDateFrom.MaximumValue = DateTime.Today.ToString("dd.MM.yyyy");
            rvRegisterDateTo.MinimumValue = new DateTime(1600, 01, 01).ToString("dd.MM.yyyy");
            rvRegisterDateTo.MaximumValue = DateTime.Today.ToString("dd.MM.yyyy");
            rvProcurementDateFrom.MinimumValue = new DateTime(1600, 01, 01).ToString("dd.MM.yyyy");
            rvProcurementDateFrom.MaximumValue = DateTime.Today.ToString("dd.MM.yyyy");
            rvProcurementDateTo.MinimumValue = new DateTime(1600, 01, 01).ToString("dd.MM.yyyy");
            rvProcurementDateTo.MaximumValue = DateTime.Today.ToString("dd.MM.yyyy");

            // Detailview Control
            rvRegisterDate.MinimumValue = new DateTime(1600, 01, 01).ToString("dd.MM.yyyy");
            rvRegisterDate.MaximumValue = new DateTime(9999, 12, 31).ToString("dd.MM.yyyy");
            rvProcurementDate.MinimumValue = new DateTime(1600, 01, 01).ToString("dd.MM.yyyy");
            rvProcurementDate.MaximumValue = new DateTime(9999, 12, 31).ToString("dd.MM.yyyy");
        }

        /// <summary>
        ///     Jumps to Page of DataGridView with given Donor ID and select its row
        /// </summary>
        /// <param name="donorID">Donor ID</param>
        private void SelectRowInGridView(int donorID)
        {
            if (!SelectRowInGridView(gvDonor, donorID))
            {
                Master.DonorID = 0;
                InitialiseDetailView();
                pnlDonor.Visible = false;
            }
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            SelectRowInGridView(Master.DonorID);

            if (gvDonor.SelectedIndex >= 0) LoadAndViewDataDetails();
            else pnlDonor.Visible = false;
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            Master.DonorID = 0;
            gvDonor.SelectedIndex = -1;
            gvDonor.DataBind();
            pnlDonor.Visible = false;
        }

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
            Response.Redirect(Page.ResolveUrl("~/IncidentCreate.aspx" + additional));
        }
        #endregion

        protected void cvIncisionMade_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = true;
            if (chkIncisionMade.Checked)
            {
                if (String.IsNullOrEmpty(txtProcurementDate.Text))
                {
                    args.IsValid = false;
                }
            }
        }

        protected void cvNut_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = true;
            if (chNut.Checked)
            {
                if (String.IsNullOrEmpty(txtProcurementDate.Text))
                {
                    args.IsValid = false;
                }
            }
        }
    }
}