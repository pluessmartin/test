using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public partial class Transport : BasePage
    {
        #region Properties
        protected int TransportID
        {
            get { return hidTransportID.Value == String.Empty ? 0 : Convert.ToInt32(hidTransportID.Value); }
            set { hidTransportID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Donor Transport called");

            if (IsPostBack) return;

            string donorID = HttpUtility.UrlDecode(Request.QueryString["donorID"]);
            if (donorID != null) Master.DonorID = Convert.ToInt32(donorID);

            // check if donor was selected, if not do nothing
            if (Master.DonorID <= 0) return;

            // set visibilty of "Add new..."-button initially depending on user rights
            btnAddNewTransport.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            btnIncidentCreate.Visible = !Master.IsOnlyAAA;

            // Bind dropdownlists and check-box repeaters
            BindGUISelectables();


            string transportID = HttpUtility.UrlDecode(Request.QueryString["transportID"]);
            if (transportID != null)
            {
                TransportID = Convert.ToInt32(transportID);
            }

            if (TransportID == 0) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
        }

        /// <summary>
        /// Select correct rows on given parameters
        /// </summary>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            if (TransportID != 0 && !IsPostBack)
            {
                SelectRowInGridView(gvTransport, TransportID);
            }

        }

        public IQueryable<DAL.Transport> gvTransport_GetData()
        {
            return GetTransportsByDonorID(Master.DonorID);
        }

        protected void gvTransport_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvTransport.SelectedIndex == -1 || gvTransport.SelectedDataKey == null) return;

            TransportID = Convert.ToInt32(gvTransport.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void cbTransportElement_CheckedChanged(object sender, EventArgs e)
        {
            CheckBox checkBox = sender as CheckBox;

            if (checkBox == null || !checkBox.Checked) return;

            // retutrn when departure-location or destination-location is already set
            if ((ddlDepartureHospital.SelectedValue != DropDownDefaultValue.DDL_DEFAULT_VALUE ||
                 !String.IsNullOrWhiteSpace(txtOtherDeparture.Text))
                &&
                (ddlDestinationHospital.SelectedValue != DropDownDefaultValue.DDL_DEFAULT_VALUE ||
                 !String.IsNullOrWhiteSpace(txtOtherDestination.Text))) return;

            HiddenField hidTransplantOrganID = checkBox.Parent.FindControl("hidTransplantOrganID") as HiddenField;
            HiddenField hidTransportItemID = checkBox.Parent.FindControl("hidTransportItemID") as HiddenField;

            if (hidTransplantOrganID != null)
            {
                // Initialise departure location if it's not already set
                if (ddlDepartureHospital.SelectedValue == DropDownDefaultValue.DDL_DEFAULT_VALUE &&
                    String.IsNullOrWhiteSpace(txtOtherDeparture.Text))
                    SetDepartureLocationAccordingToLastDestination(Convert.ToInt32(hidTransplantOrganID.Value), checkBox);

                // Initialise destination location if it's not already set
                if (ddlDestinationHospital.SelectedValue == DropDownDefaultValue.DDL_DEFAULT_VALUE &&
                    String.IsNullOrWhiteSpace(txtOtherDestination.Text))
                    SetDestinationLocationAccordingToTransplantCenterIDOfOrgan(
                        Convert.ToInt32(hidTransplantOrganID.Value));

                // Set Distance between departure and location
                SetTransportDistance();
            }

            // Initialise departure-location according to last destination-location (if available)
            if (hidTransportItemID != null)
            {
                // Initialise departure location if it's not already set
                if (ddlDepartureHospital.SelectedValue == DropDownDefaultValue.DDL_DEFAULT_VALUE &&
                    String.IsNullOrWhiteSpace(txtOtherDeparture.Text))
                    SetDepartureLocationAccordingToLastDestination(Convert.ToInt32(hidTransportItemID.Value), checkBox);
            }
        }

        protected void ddlDepartureOrDestinationHospital_SelectedIndexChanged(object sender, EventArgs e)
        {
            SetTransportDistance();
        }

        protected void txtDepartureDate_TextChanged(object sender, EventArgs e)
        {
            txtArrivalDate.Text = txtDepartureDate.Text;
        }

        protected void btnAddNewTransport_Click(object sender, EventArgs e)
        {
            TransportID = 0;

            gvTransport.SelectRow(-1);

            InitialiseTransportDetailView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                // Save Transport
                DAL.Transport t = AssignValuesToTransport();

                // Save transported organs
                AssignValuesToTransportedOrgans(t);

                // Save transported items
                AssignValuesToTransportedItems(t);

                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }

                TransportID = t.ID;

                // Refresh DataGridView
                gvTransport.DataBind();
                SelectRowInGridView(gvTransport, TransportID);
                BindDonorOverview();
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

                const string message = "Could not save Transport! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (gvTransport.SelectedDataKey != null)
                {
                    DAL.Transport t = GetTransportByID(Convert.ToInt32(gvTransport.SelectedDataKey.Value));
                    if (t == null)
                    {
                        throw new NullReferenceException(String.Format("Transport with ID {0} could not be found!", gvTransport.SelectedDataKey.Value));
                    }

                    t.IsDeleted = true;
                }
                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgDeleteSuccess, SLIDSMaster.LabelState.Success);

                    // Reset TransportID and refresh DataGrid
                    TransportID = 0;
                    gvTransport.SelectedIndex = -1;
                    gvTransport.DataBind();
                    pnlTransportDetails.Visible = false;
                    BindDonorOverview();
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
            }
            catch (NullReferenceException nullReferenceEx)
            {
                // record has been deleted in the meantime!
                HandlePageRefreshAfterNullReferenceException();

                Master.SetInfoLabel(StatusMessages.MsgConcurrencyDeleteNullException, SLIDSMaster.LabelState.Error);
                logger.Error("Failed updating configuration due to a concurrency error: " + nullReferenceEx.Message);
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not delete Transport! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }
        /// <summary>
        /// Reloads Donor Overview
        /// </summary>
        private void BindDonorOverview()
        {
            GridView gvSelectedDonor = (GridView)Master.FindControl("gvSelectedDonor");
            if (gvSelectedDonor != null)
            {
                gvSelectedDonor.DataBind();
            }
        }

        #region Validation

        protected void cvDeparture_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = (!String.IsNullOrWhiteSpace(txtOtherDeparture.Text) &&
                            ddlDepartureHospital.SelectedValue == DropDownDefaultValue.DDL_DEFAULT_VALUE)
                           ||
                           (ddlDepartureHospital.SelectedValue != DropDownDefaultValue.DDL_DEFAULT_VALUE &&
                            String.IsNullOrWhiteSpace(txtOtherDeparture.Text));
        }

        protected void cvDestination_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = (!String.IsNullOrWhiteSpace(txtOtherDestination.Text) &&
                            ddlDestinationHospital.SelectedValue == DropDownDefaultValue.DDL_DEFAULT_VALUE)
                           ||
                           (ddlDestinationHospital.SelectedValue != DropDownDefaultValue.DDL_DEFAULT_VALUE &&
                            String.IsNullOrWhiteSpace(txtOtherDestination.Text));
        }

        protected void cvTransportElements_ServerValidate(object source, ServerValidateEventArgs args)
        {
            int elementCounter = 0;

            foreach (RepeaterItem repItem in repTransplantOrgans.Items)
            {
                CheckBox cbTransplantOrgan = repItem.FindControl("cbTransplantOrgan") as CheckBox;
                if (cbTransplantOrgan != null && cbTransplantOrgan.Checked) elementCounter += 1;
            }

            foreach (RepeaterItem repItem in repTransportItems.Items)
            {
                CheckBox cbTransportItem = repItem.FindControl("cbTransportItem") as CheckBox;
                if (cbTransportItem != null && cbTransportItem.Checked) elementCounter += 1;
            }

            args.IsValid = elementCounter > 0;
        }
        #endregion

        #region Privates
        private void LoadAndViewDataDetails()
        {
            DAL.Transport t = GetTransportByID(TransportID);
            if (t == null) return;
            
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
            PopulateTransportDetailView(t);
        }

        private void BindGUISelectables()
        {

            // Operation Center
            ddlOperationCenter.ClearSelection();
            ddlOperationCenter.DataSource = Data.OperationCenter.Where(oc => oc.isActive).ToList();
            ddlOperationCenter.DataValueField = "ID";
            ddlOperationCenter.DataTextField = "Name";
            ddlOperationCenter.DataBind();
            ddlOperationCenter.Items.Insert(0,
                                            new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                         DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Vehicle
            ddlVehicle.ClearSelection();
            ddlVehicle.DataSource = Data.Vehicle.Where(v => v.isActive).OrderBy(v => v.Position).ToList();
            ddlVehicle.DataValueField = "ID";
            ddlVehicle.DataTextField = "Name";
            ddlVehicle.DataBind();
            ddlVehicle.Items.Insert(0,
                                    new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                 DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Create selectable list of alternate hospitals
            // Foreign Hospitals (FO) which are either set as TransplantCenter of an Organ or as Procurement-Hospital should also be selectable as transport departure or destination locations
            Donor d = GetDonorByID(Master.DonorID);
            List<int?> alternateHospitals = d != null
                                                ? d.TransplantOrgan.Select(to => to.TransplantCenterID).ToList()
                                                : null;
            if (d != null && d.ProcurementHospitalID != null && !alternateHospitals.Contains(d.ProcurementHospitalID))
                alternateHospitals.Add(d.ProcurementHospitalID);

            // Departure Hospital
            ddlDepartureHospital.ClearSelection();
            ddlDepartureHospital.DataSource = GetSwissHospitals(alternateHospitals)
                .Where(h => h.isActive)
                .OrderByDescending(h => h.IsTransplantation)
                .ThenBy(h => h.IsFo)
                .ThenBy(h => h.Display).ToList();
            ddlDepartureHospital.DataValueField = "ID";
            ddlDepartureHospital.DataTextField = "Display";
            ddlDepartureHospital.DataBind();
            ddlDepartureHospital.Items.Insert(0,
                                              new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                           DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Destination Hospital
            ddlDestinationHospital.ClearSelection();
            ddlDestinationHospital.DataSource = GetSwissHospitals(alternateHospitals)
                .Where(h => h.isActive)
                .OrderByDescending(h => h.IsTransplantation)
                .ThenBy(h => h.IsFo)
                .ThenBy(h => h.Display).ToList();
            ddlDestinationHospital.DataValueField = "ID";
            ddlDestinationHospital.DataTextField = "Display";
            ddlDestinationHospital.DataBind();
            ddlDestinationHospital.Items.Insert(0,
                                                new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                             DropDownDefaultValue.DDL_DEFAULT_VALUE));

            // Organ Transplant checkboxes           
            repTransplantOrgans.DataSource = GetTransplantOrgans().Where(to => to.DonorID == Master.DonorID).ToList();
            repTransplantOrgans.DataBind();

            // Transport Item checkboxes
            repTransportItems.DataSource = Data.TransportItem.Where(ti => ti.isActive).ToList();
            repTransportItems.DataBind();
        }

        private void PopulateTransportDetailView(DAL.Transport t)
        {
            if (t == null) throw new Exception("Transport datarow was not provided!");

            ddlOperationCenter.SelectedValue = t.OperationCenterID != null
                                                   ? t.OperationCenterID.ToString()
                                                   : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtProvider.Text = t.Provider;
            ddlVehicle.SelectedValue = t.VehicleID != null
                                           ? t.VehicleID.ToString()
                                           : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtFlightNo.Text = t.FlightNumber;
            txtImmatriculation.Text = t.Immatriculation;
            txtDistance.Text = t.Distance.ToString();
            cbPoliceEscort.Checked = Convert.ToBoolean(t.PoliceEscorted);
            ddlDepartureHospital.SelectedValue = t.DepartureHospitalID != null
                                                     ? t.DepartureHospitalID.ToString()
                                                     : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtOtherDeparture.Text = t.OtherDeparture;
            txtDepartureDate.Text = t.Departure != null ? String.Format("{0:dd.MM.yyyy}", t.Departure) : String.Empty;
            txtDepartureTime.Text = t.Departure != null ? String.Format("{0:HH:mm}", t.Departure) : String.Empty;
            ddlDestinationHospital.SelectedValue = t.DestinationHospitalID != null
                                                       ? t.DestinationHospitalID.ToString()
                                                       : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtOtherDestination.Text = t.OtherDestination;
            txtArrivalDate.Text = t.Arrival != null ? String.Format("{0:dd.MM.yyyy}", t.Arrival) : String.Empty;
            txtArrivalTime.Text = t.Arrival != null ? String.Format("{0:HH:mm}", t.Arrival) : String.Empty;
            txtWaitingTime.Text = t.WaitingTime.ToString();
            txtForeWarning.Text = t.Forewarning.ToString();
            txtComment.Text = t.Comment;

            PopulateTransplantOrganCheckboxes(t);
            PopulateTransportItemCheckboxes(t);
        }

        private void PopulateTransplantOrganCheckboxes(DAL.Transport t)
        {
            List<KeyValuePair<int, int?>> transportedOrganIDs = t.TransportedOrgan.Select(to => new KeyValuePair<int, int?>(to.TransplantOrganID, to.LifeportID)).ToList();

            foreach (RepeaterItem repItem in repTransplantOrgans.Items)
            {
                // Programmatically reference the CheckBox
                CheckBox cbTransplantOrgan = repItem.FindControl("cbTransplantOrgan") as CheckBox;
                HiddenField hidTransplantOrganID = repItem.FindControl("hidTransplantOrganID") as HiddenField;
           //     DropDownList ddlLifeportNumber = (DropDownList)repItem.FindControl("ddlLifeportNumber");

                if (cbTransplantOrgan == null) continue;

                //  See if cbTransplantOrgan.Name is in transportedOrganNames
                if (hidTransplantOrganID != null)
                {
                    int transplantOrganId = Convert.ToInt32(hidTransplantOrganID.Value);
                    cbTransplantOrgan.Checked = transportedOrganIDs.Exists(d => d.Key == transplantOrganId);
                }
            }
        }

        private void PopulateTransportItemCheckboxes(DAL.Transport t)
        {
            List<int> transportedItemIDs = t.TransportItem.Select(ti => ti.ID).ToList();

            foreach (RepeaterItem repItem in repTransportItems.Items)
            {
                CheckBox cbTransportItem = repItem.FindControl("cbTransportItem") as CheckBox;
                HiddenField hidTransportItemID = repItem.FindControl("hidTransportItemID") as HiddenField;

                if (cbTransportItem != null)
                {
                    //  See if cbTransportItem.Name is in transportedItemNames
                    if (hidTransportItemID != null)
                    {
                        cbTransportItem.Checked = transportedItemIDs.Contains<int>(Convert.ToInt32(hidTransportItemID.Value));
                    }
                }
            }
        }

        private void SetDepartureLocationAccordingToLastDestination(int elementID, CheckBox checkBox)
        {
            // Get last Transports
            List<DAL.Transport> previousTransportList = GetTransportsByDonorID(Master.DonorID)
                .Where(t => t.ID != TransportID)
                .OrderByDescending(t => t.Arrival).ToList();

            // If no previous transport exists, set Procurement location as default location and date and leave method
            if (previousTransportList.Count == 0)
            {
                SetProcurementLocationAndDateAsDefaultParams();
                return;
            }

            DAL.Transport previousTransport = GetPreviousTransport(previousTransportList, elementID,
                                                                                   checkBox);

            // If TransplantOrgan or TransportItem has no previous transportation, set Procurement location as default location and date, and leave method
            if (previousTransport == null)
            {
                SetProcurementLocationAndDateAsDefaultParams();
                return;
            }

            ddlDepartureHospital.SelectedValue = previousTransport.DestinationHospitalID != null
                                                     ? previousTransport.DestinationHospitalID.ToString()
                                                     : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtOtherDeparture.Text = previousTransport.OtherDestination ?? String.Empty;
            txtDepartureDate.Text = previousTransport.Arrival != null
                                        ? String.Format("{0:dd.MM.yyyy}", previousTransport.Arrival)
                                        : String.Empty;
            txtDepartureTime.Text = previousTransport.Arrival != null
                                        ? String.Format("{0:HH:mm}", previousTransport.Arrival)
                                        : String.Empty;
            txtArrivalDate.Text = txtDepartureDate.Text;
        }

        private void SetDestinationLocationAccordingToTransplantCenterIDOfOrgan(int transplantorganID)
        {
            TransplantOrgan to = GetTransplantOrganByID(transplantorganID);
            if (to != null)
            {
                ddlDestinationHospital.SelectedValue = to.TransplantCenterID != null
                                                           ? to.TransplantCenterID.ToString()
                                                           : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            }
        }

        private DAL.Transport GetPreviousTransport(List<DAL.Transport> previousTransportList, int elementID,
                                                            CheckBox checkBox)
        {
            if (checkBox.ID == "cbTransplantOrgan")
            {
                foreach (DAL.Transport t in previousTransportList)
                {
                    TransportedOrgan transOrg = t.TransportedOrgan.SingleOrDefault(to => to.TransplantOrgan.ID == elementID);
                    if (transOrg != null)
                    {
                        TransplantOrgan previousTransportedOrgan = transOrg.TransplantOrgan;
                        if (previousTransportedOrgan != null) return t;
                    }
                }
            }

            if (checkBox.ID == "cbTransportItem")
            {
                foreach (DAL.Transport t in previousTransportList)
                {
                    TransportItem previousTransportedItem = t.TransportItem.SingleOrDefault(ti => ti.ID == elementID);
                    if (previousTransportedItem != null) return t;
                }
            }

            return null;
        }

        private void SetProcurementLocationAndDateAsDefaultParams()
        {
            Donor d = GetDonorByID(Master.DonorID);

            ddlDepartureHospital.SelectedValue = d.ProcurementHospitalID != null
                                                     ? d.ProcurementHospitalID.ToString()
                                                     : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtDepartureDate.Text = d.ProcurementDate != null
                                        ? String.Format("{0:dd.MM.yyyy}", d.ProcurementDate)
                                        : String.Empty;
            txtArrivalDate.Text = txtDepartureDate.Text;

            SetTransportDistance();
        }

        private void SetTransportDistance()
        {
            if ((Convert.ToInt32(ddlDepartureHospital.SelectedValue) == 0
                 || Convert.ToInt32(ddlDestinationHospital.SelectedValue) == 0)
                || !String.IsNullOrWhiteSpace(txtOtherDeparture.Text)
                || !String.IsNullOrWhiteSpace(txtOtherDestination.Text)
                ) return;

            // If departure and destination hospital are equal, distance is 0
            if (ddlDepartureHospital.SelectedValue == ddlDestinationHospital.SelectedValue)
            {
                txtDistance.Text = "0";
                return;
            }

            int distance = GetTransportDistance(Convert.ToInt32(ddlDepartureHospital.SelectedValue),
                                                Convert.ToInt32(ddlDestinationHospital.SelectedValue));

            txtDistance.Text = distance > 0 ? distance.ToString(CultureInfo.InvariantCulture) : String.Empty;
        }

        private DAL.Transport AssignValuesToTransport()
        {

            bool isRowAdded = TransportID == 0;

            DAL.Transport t = null;

            try
            {
                // Save Transport
                if (isRowAdded)
                {
                    // create new datarow
                    t = new DAL.Transport();
                    Data.Transport.Add(t);
                }
                else
                {
                    // update existing datarow
                    t = GetTransportByID(TransportID);
                }

                t.DonorID = Master.DonorID;
                t.VehicleID = Convert.ToInt32(ddlVehicle.SelectedValue) > 0
                                  ? (int?)Convert.ToInt32(ddlVehicle.SelectedValue)
                                  : null;
                t.DepartureHospitalID = Convert.ToInt32(ddlDepartureHospital.SelectedValue) > 0
                                            ? (int?)Convert.ToInt32(ddlDepartureHospital.SelectedValue)
                                            : null;
                t.DestinationHospitalID = Convert.ToInt32(ddlDestinationHospital.SelectedValue) > 0
                                              ? (int?)Convert.ToInt32(ddlDestinationHospital.SelectedValue)
                                              : null;
                t.OperationCenterID = Convert.ToInt32(ddlOperationCenter.SelectedValue) > 0
                                          ? (int?)Convert.ToInt32(ddlOperationCenter.SelectedValue)
                                          : null;
                t.PoliceEscorted = cbPoliceEscort.Checked;
                t.OtherDeparture = !String.IsNullOrWhiteSpace(txtOtherDeparture.Text) ? txtOtherDeparture.Text : null;
                t.OtherDestination = !String.IsNullOrWhiteSpace(txtOtherDestination.Text)
                                         ? txtOtherDestination.Text
                                         : null;
                t.Departure = FormatDateTime(txtDepartureDate, txtDepartureTime);
                t.Arrival = FormatDateTime(txtArrivalDate, txtArrivalTime);
                t.Immatriculation = !String.IsNullOrWhiteSpace(txtImmatriculation.Text) ? txtImmatriculation.Text : null;
                t.FlightNumber = !String.IsNullOrWhiteSpace(txtFlightNo.Text) ? txtFlightNo.Text : null;
                t.Distance = !String.IsNullOrWhiteSpace(txtDistance.Text)
                                 ? (int?)Convert.ToInt32(txtDistance.Text)
                                 : null;
                t.Forewarning = !String.IsNullOrWhiteSpace(txtForeWarning.Text)
                                    ? (int?)Convert.ToInt32(txtForeWarning.Text)
                                    : null;
                t.WaitingTime = !String.IsNullOrWhiteSpace(txtWaitingTime.Text)
                                    ? (int?)Convert.ToInt32(txtWaitingTime.Text)
                                    : null;
                t.Provider = !String.IsNullOrWhiteSpace(txtProvider.Text) ? txtProvider.Text : null;
                t.Comment = !String.IsNullOrWhiteSpace(txtComment.Text) ? txtComment.Text : null;

                // TODO: Check with Sebi why t.Hospital and t.Hospital1 needs to be set in order to save new data accordingly if they are nowhere bound otherwise?
                if (Convert.ToInt32(ddlDepartureHospital.SelectedValue) > 0) t.Hospital = GetHospitalByID(Convert.ToInt32(ddlDepartureHospital.SelectedValue));
                if (Convert.ToInt32(ddlDestinationHospital.SelectedValue) > 0) t.Hospital1 = GetHospitalByID(Convert.ToInt32(ddlDestinationHospital.SelectedValue));
                if (Convert.ToInt32(ddlVehicle.SelectedValue) > 0) t.Vehicle = GetVehicleByID(Convert.ToInt32(ddlVehicle.SelectedValue));
                if (Convert.ToInt32(ddlOperationCenter.SelectedValue) > 0)
                {
                    int operationCenterID = Convert.ToInt32(ddlOperationCenter.SelectedValue);
                    t.OperationCenter = Data.OperationCenter.Where(oc => oc.isActive).SingleOrDefault(oc => oc.ID == operationCenterID);
                }
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not save Transport! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }

            return t;
        }

        private void AssignValuesToTransportedOrgans(DAL.Transport t)
        {
            try
            {
                // Set all transported Organ IDs of the appropriate Transport in a list for comparison
                List<int> transportedOrganIDs = t.TransportedOrgan.Select(to => to.TransplantOrgan.ID).ToList();

                foreach (RepeaterItem repItem in repTransplantOrgans.Items)
                {
                    // Programmatically reference the CheckBox and Hiddenfield(=> which contains the TransportOrgan ID)
                    CheckBox cbTransplantOrgan = repItem.FindControl("cbTransplantOrgan") as CheckBox;
                    HiddenField hidTransplantOrganID = repItem.FindControl("hidTransplantOrganID") as HiddenField;
                //    DropDownList ddlLifeportNumber = (DropDownList)repItem.FindControl("ddlLifeportNumber");

                    if (cbTransplantOrgan == null || hidTransplantOrganID == null) continue;

                    if (cbTransplantOrgan.Checked)
                    {
                        // if TransportOrgan is checked and not already exists in TransportedOrgan then insert
                        if (!transportedOrganIDs.Contains<int>(Convert.ToInt32(hidTransplantOrganID.Value)))
                        {
                            TransportedOrgan to = new TransportedOrgan();
                            TransplantOrgan transplantOrgan = GetTransplantOrganByID(Convert.ToInt32(hidTransplantOrganID.Value));
                            to.TransplantOrgan = transplantOrgan;
                            t.TransportedOrgan.Add(to);
                        }
                        else
                        {
                            // Set Lifeport if it is different
                            int transplantOrganID = Convert.ToInt32(hidTransplantOrganID.Value);
                            TransportedOrgan to = t.TransportedOrgan.Single(tranOrg => tranOrg.TransplantOrganID == transplantOrganID);
                            if(string.IsNullOrEmpty(to.TransplantOrgan.PrefusionMachineNumber))
                            {
                                
                            }
                        }
                    }
                    else
                    {
                        // if TransportOrgan is uncecked but exists in TransportedOrgan then remove
                        if (transportedOrganIDs.Contains<int>(Convert.ToInt32(hidTransplantOrganID.Value)))
                        {
                            int transplantOrganID = Convert.ToInt32(hidTransplantOrganID.Value);
                            TransportedOrgan to = t.TransportedOrgan.Single(tranOrg => tranOrg.TransplantOrganID == transplantOrganID);
                            t.TransportedOrgan.Remove(to);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not save Transport! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        private void AssignValuesToTransportedItems(DAL.Transport t)
        {
            try
            {
                // Set all transported Item IDs of the appropriate Transport in a list for comparison
                List<int> transportedItemIDs = t.TransportItem.Select(ti => ti.ID).ToList();

                foreach (RepeaterItem repItem in repTransportItems.Items)
                {
                    CheckBox cbTransportItem = repItem.FindControl("cbTransportItem") as CheckBox;
                    HiddenField hidTransportItemID = repItem.FindControl("hidTransportItemID") as HiddenField;

                    if (cbTransportItem == null || hidTransportItemID == null) continue;

                    if (cbTransportItem.Checked)
                    {
                        // if TransportItem is checked and not already exists in TransportedItem then insert
                        if (!transportedItemIDs.Contains<int>(Convert.ToInt32(hidTransportItemID.Value)))
                        {
                            t.TransportItem.Add(GetTransportItemByID(Convert.ToInt32(hidTransportItemID.Value)));
                        }
                    }
                    else
                    {
                        // if TransportItem is uncecked but exists in TransportedItem then remove
                        if (transportedItemIDs.Contains<int>(Convert.ToInt32(hidTransportItemID.Value)))
                        {
                            t.TransportItem.Remove(GetTransportItemByID(Convert.ToInt32(hidTransportItemID.Value)));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not save Transport! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        private void InitialiseTransportDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();

            ddlOperationCenter.SelectedValue = ddlOperationCenter.Items.Count > 0
                                                   ? "1"
                                                   : DropDownDefaultValue.DDL_DEFAULT_VALUE; // Preselect AAA
            txtProvider.Text = String.Empty;
            ddlVehicle.SelectedIndex = 0;
            txtFlightNo.Text = String.Empty;
            txtImmatriculation.Text = String.Empty;
            txtDistance.Text = String.Empty;
            cbPoliceEscort.Checked = false;
            ddlDepartureHospital.SelectedIndex = 0;
            txtDepartureDate.Text = String.Empty;
            txtDepartureTime.Text = String.Empty;
            txtOtherDeparture.Text = String.Empty;
            ddlDestinationHospital.SelectedIndex = 0;
            txtArrivalDate.Text = String.Empty;
            txtArrivalTime.Text = String.Empty;
            txtOtherDestination.Text = String.Empty;
            txtForeWarning.Text = String.Empty;
            txtWaitingTime.Text = String.Empty;
            txtComment.Text = String.Empty;
            InitialiseTransplantOrganCheckBoxes();
            InitialiseTransportItemCheckBoxes();
        }

        private void InitialiseTransplantOrganCheckBoxes()
        {
            foreach (RepeaterItem repItem in repTransplantOrgans.Items)
            {
                // Programmatically reference the CheckBox
                CheckBox cbTransplantOrgan = repItem.FindControl("cbTransplantOrgan") as CheckBox;
                if (cbTransplantOrgan != null) cbTransplantOrgan.Checked = false;
            }
        }

        private void InitialiseTransportItemCheckBoxes()
        {
            foreach (RepeaterItem repItem in repTransportItems.Items)
            {
                CheckBox cbTransportItem = repItem.FindControl("cbTransportItem") as CheckBox;
                if (cbTransportItem != null) cbTransportItem.Checked = false;
            }
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            // Enabling for all roles
            pnlTransportDetails.Visible = true;
            pnlTransportDetails.Enabled = !DonorIsArchived(Master.DonorID);
            btnSave.Visible = !DonorIsArchived(Master.DonorID);

            // Enabling depending on roles
            btnDelete.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && TransportID != 0 && !DonorIsArchived(Master.DonorID);
            ddlOperationCenter.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtProvider.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtFlightNo.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtImmatriculation.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtDistance.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            cbPoliceEscort.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlDepartureHospital.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtOtherDeparture.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlDestinationHospital.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtOtherDestination.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtForeWarning.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);

            //  Roles for not incident user/admin
            txtDepartureDate.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtDepartureTime.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtArrivalDate.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtArrivalTime.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlVehicle.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtWaitingTime.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtComment.Enabled = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            btnSave.Visible = (Master.IsAAA || Master.IsTC || Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);


            // Enable TransportedOrgan
            pnlTransportedOrgans.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);

            // Enable TransportedItem
            pnlTransportedItems.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            gvTransport.DataBind();

            if (gvTransport.SelectedIndex >= 0) LoadAndViewDataDetails();
            else pnlTransportDetails.Visible = false;
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            TransportID = 0;
            gvTransport.SelectedIndex = -1;
            gvTransport.DataBind();
            pnlTransportDetails.Visible = false;
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

            if (TransportID != 0)
            {
                if (additional == String.Empty)
                {
                    additional = "?";
                }
                else
                {
                    additional += "&";
                }
                additional += "transportID=" + TransportID.ToString();
            }

            Response.Redirect("IncidentCreate.aspx" + additional);
        }

        /// <summary>
        /// Set Oncklick Event on row-click
        /// </summary>
        public new void gridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink((GridView)sender, "Select$" + e.Row.RowIndex);
                DAL.Transport t = (DAL.Transport) e.Row.DataItem;
                if (t.Arrival < t.Departure)
                {
                    e.Row.BackColor = Color.Orange;
                }
            }
        }
    }
}