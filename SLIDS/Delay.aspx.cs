using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Data.Entity.Infrastructure;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public partial class Delay : BasePage
    {
        #region Properties
        public int DelayID
        {
            get { return hidDelayID.Value == String.Empty ? 0 : Convert.ToInt32(hidDelayID.Value); }
            set { hidDelayID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        public int TransportID
        {
            get { return hidTransportID.Value == String.Empty ? 0 : Convert.ToInt32(hidTransportID.Value); }
            set { hidTransportID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Donor Transport Delay called");

            if (IsPostBack) return;

            string donorID = HttpUtility.UrlDecode(Request.QueryString["donorID"]);
            if (donorID != null) Master.DonorID = Convert.ToInt32(donorID);

            // check if donor was selected, if not do nothing
            if (Master.DonorID <= 0) return;

            // Bind dropdownlists and check-box repeaters
            BindDropDownLists();

            // set visibilty of "Add new..."-button initially depending on user rights
            btnAddNewDelay.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            btnIncidentCreate.Visible = !Master.IsOnlyAAA;

            // Only enable button Add New if Transports are available
            btnAddNewDelay.Enabled = gvTransport.Rows.Count > 0 && gvTransport.SelectedIndex >= 0;

            string delayID = HttpUtility.UrlDecode(Request.QueryString["delayID"]);
            if (delayID != null)
            {
                DelayID = Convert.ToInt32(delayID);
            }

            if (DelayID == 0) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
        }

        /// <summary>
        /// Select correct rows on given parameters
        /// </summary>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            if (DelayID != 0 && !IsPostBack)
            {
                DataService<DAL.Delay> delays = new DataService<DAL.Delay>(Data);
                DAL.Delay delay = delays.Get(DelayID);
                SelectRowInGridView(gvTransport, delay.TransportID);
                SelectRowInGridView(gvDelay, DelayID);
            }
        }

        public IQueryable<DAL.Transport> gvTransport_GetData()
        {
            return GetTransportsByDonorID(Master.DonorID);
        }

        public IQueryable<DAL.Delay> gvDelay_GetData()
        {
            return GetDelays()
                .Where(d => d.TransportID == TransportID);
        }

        protected void gvTransport_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvTransport.SelectedIndex == -1 || gvTransport.SelectedDataKey == null) return;

            TransportID = Convert.ToInt32(gvTransport.SelectedDataKey.Value);
            btnAddNewDelay.Enabled = true;
            gvDelay.DataBind();
            pnlDelayDetails.Visible = false;
        }

        protected void gvDelay_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvDelay.SelectedIndex == -1 || gvDelay.SelectedDataKey == null) return;

            DelayID = Convert.ToInt32(gvDelay.SelectedDataKey.Value);

            LoadAndViewDataDetails();
        }

        protected void btnAddNewDelay_Click(object sender, EventArgs e)
        {
            DelayID = 0;

            gvDelay.SelectRow(-1);

            InitialiseDelayDetailView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                DAL.Delay d = AssignValuesToDelay();

                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }

                DelayID = d.ID;

                // Refresh DataGridView
                gvTransport.DataBind();
                gvDelay.DataBind();
                SelectRowInGridView(gvDelay, DelayID);
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

                const string message = "Could not save Delay! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (gvDelay.SelectedDataKey != null)
                {
                    DAL.Delay d = GetDelayByID(Convert.ToInt32(gvDelay.SelectedDataKey.Value));
                    if (d == null)
                    {
                        throw new NullReferenceException(String.Format("Delay with ID {0} could not be found!", gvDelay.SelectedDataKey.Value));
                    }

                    d.IsDeleted = true;
                }
                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgDeleteSuccess, SLIDSMaster.LabelState.Success);

                    // Reset DelayID and refresh DataGrid
                    DelayID = 0;
                    gvDelay.SelectedIndex = -1;
                    gvDelay.DataBind();
                    gvTransport.DataBind();
                    pnlDelayDetails.Visible = false;
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

                const string message = "Could not delete Delay! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        protected string GetFormattedDuration(TimeSpan? duration)
        {
            if (duration == null) return String.Empty;

            TimeSpan myTimeSpan = TimeSpan.Parse(duration.ToString());
            DateTime myDate = new DateTime(myTimeSpan.Ticks);

            return String.Format("{0:HH:mm}", myDate);
        }

        #region Validation
        protected void cvDelayReason_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = (!String.IsNullOrWhiteSpace(txtOtherDelayReason.Text) &&
                            ddlDelayReason.SelectedValue == DropDownDefaultValue.DDL_DEFAULT_VALUE)
                           ||
                           (ddlDelayReason.SelectedValue != DropDownDefaultValue.DDL_DEFAULT_VALUE &&
                            String.IsNullOrWhiteSpace(txtOtherDelayReason.Text));
        }

        protected void cvDuration_ServerValidate(object source, ServerValidateEventArgs args)
        {
            DateTime d;
            args.IsValid = DateTime.TryParseExact(args.Value, "HH:mm", CultureInfo.InvariantCulture, DateTimeStyles.None,
                                                  out d);
        }

        protected void cvComment_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = ((ddlDelayReason.SelectedItem.Text.Contains("(comment)") &&
                             !String.IsNullOrWhiteSpace(txtComment.Text)) ||
                            (!ddlDelayReason.SelectedItem.Text.Contains("(comment)")));
        }
        #endregion

        #region Privates
        private void LoadAndViewDataDetails()
        {
            DAL.Delay d = GetDelayByID(DelayID);
            if (d == null) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
            PopulateDelayDetailView(d);
        }

        private DAL.Delay AssignValuesToDelay()
        {
            bool isRowAdded = DelayID == 0;
            DAL.Delay d;

            if (isRowAdded)
            {
                // create new datarow
                d = new DAL.Delay();
                Data.Delay.Add(d);
            }
            else
            {
                // update existing datarow
                d = GetDelayByID(DelayID);
            }

            d.TransportID = TransportID;
            d.DelayReasonID = Convert.ToInt32(ddlDelayReason.SelectedValue) > 0
                                  ? (int?)Convert.ToInt32(ddlDelayReason.SelectedValue)
                                  : null;
            d.OtherReason = !String.IsNullOrWhiteSpace(txtOtherDelayReason.Text) ? txtOtherDelayReason.Text : null;
            d.Duration = !String.IsNullOrWhiteSpace(txtDuration.Text)
                             ? (TimeSpan?)TimeSpan.Parse(txtDuration.Text)
                             : null;
            d.Comment = !String.IsNullOrWhiteSpace(txtComment.Text) ? txtComment.Text : null;
            d.IsOrganLost = cbIsOrganLost.Checked;

            if (Convert.ToInt32(ddlDelayReason.SelectedValue) > 0)
            {
                int delayReasonID = Convert.ToInt32(ddlDelayReason.SelectedValue);
                d.DelayReason = Data.DelayReason.SingleOrDefault(dr => dr.ID == delayReasonID);
            }

            return d;
        }

        private void PopulateDelayDetailView(DAL.Delay d)
        {
            if (d == null) throw new Exception("Delay datarow was not provided!");

            ddlDelayReason.SelectedValue = d.DelayReasonID != null
                                               ? d.DelayReasonID.ToString()
                                               : DropDownDefaultValue.DDL_DEFAULT_VALUE;
            txtOtherDelayReason.Text = d.OtherReason;
            txtDuration.Text = GetFormattedDuration(d.Duration);
            txtComment.Text = d.Comment;
            cbIsOrganLost.Checked = Convert.ToBoolean(d.IsOrganLost);
        }

        private void BindDropDownLists()
        {
            // Delay Reason
            ddlDelayReason.ClearSelection();
            ddlDelayReason.DataSource = Data.DelayReason.ToList();
            ddlDelayReason.DataValueField = "ID";
            ddlDelayReason.DataTextField = "Reason";
            ddlDelayReason.DataBind();
            ddlDelayReason.Items.Insert(0,
                                        new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                     DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        private void InitialiseDelayDetailView()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();

            ddlDelayReason.SelectedIndex = 0;
            txtOtherDelayReason.Text = String.Empty;
            txtDuration.Text = String.Empty;
            txtComment.Text = String.Empty;
            cbIsOrganLost.Checked = false;
        }

        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            pnlDelayDetails.Visible = true;

            btnSave.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            btnDelete.Visible = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && DelayID != 0 && !DonorIsArchived(Master.DonorID);
            pnlDelayDetails.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            ddlDelayReason.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtOtherDelayReason.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtDuration.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            txtComment.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
            cbIsOrganLost.Enabled = (Master.IsAdmin || Master.IsNC || Master.IsSwisstransplant) && !DonorIsArchived(Master.DonorID);
        }

        private void HandlePageRefreshAfterConcurrencyException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            gvTransport.DataBind();
            gvDelay.DataBind();

            if (gvDelay.SelectedIndex >= 0) LoadAndViewDataDetails();
            else pnlDelayDetails.Visible = false;
        }

        private void HandlePageRefreshAfterNullReferenceException()
        {
            // Remove Session "DataContext" so that Data is reloaded properly
            Session.Remove("DataContext");
            Data = null;

            // reinitialise params and refresh site without details
            gvTransport.DataBind();
            DelayID = 0;
            gvDelay.SelectedIndex = -1;
            gvDelay.DataBind();
            pnlDelayDetails.Visible = false;
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
                additional += "transportDelaysID=" + TransportID.ToString();
            }

            Response.Redirect("IncidentCreate.aspx" + additional);
        }
    }
}