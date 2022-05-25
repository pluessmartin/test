using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Controls
{
    public partial class ucIncident : System.Web.UI.UserControl
    {
        // Events
        public event EventHandler DonorNrChanged;

        // Donor Number
        public string DonorNr
        {
            set
            {
                txtSTRSFONo.Text = value;
                txtSTRSFONo_TextChanged(this, new EventArgs());
            }
            get { return txtSTRSFONo.Text; }
        }

        /// <summary>
        /// Execute on page load
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindDropDownLists();
            }
        }

        /// <summary>
        /// On Pre Render
        /// </summary>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            DisplayDonorAlert();
        }

        /// <summary>
        ///  Base Page
        /// </summary>
        protected BasePage BasePage
        {
            get { return new BasePage(); }
        }

        /// <summary>
        /// Validates entries
        /// </summary>
        public bool IsValid()
        {
            Page.Validate("InputGroup");
            return Page.IsValid;
        }

        /// <summary>
        /// On changing text in textbox ST/RS/FO Number
        /// </summary>
        protected void txtSTRSFONo_TextChanged(object sender, EventArgs e)
        {
            if (DonorNrChanged != null)
            {
                DonorNrChanged.Invoke(this, e);
            }
        }

        /// <summary>
        /// Shows donor alert
        /// </summary>
        private void DisplayDonorAlert()
        {
            if (txtSTRSFONo.Text.Length > 2 && (txtSTRSFONo.Text.Substring(0, 3).ToLower() == "fo-" || txtSTRSFONo.Text.Substring(0, 3).ToLower() == "st-"))
            {
                if ((from donor in BasePage.Data.Donor
                     where donor.DonorNumber == txtSTRSFONo.Text
                     select donor).Count() == 0)
                {
                    alert.Style.Clear();
                }
            }
            upAlert.Update();
        }

        public bool AllowEnable { get; set; }

        /// <summary>
        /// Enable/Disable controls
        /// </summary>
        public bool Enabled
        {
            get
            {
                return txtIncidentDescription.Enabled;
            }
            set
            {
                bool enabled = value;
                if (!AllowEnable && enabled)
                {
                    enabled = false;
                }
                BasePage.EnableOrDisableControls(PanelIncident, enabled);
                BasePage.EnableOrDisableControls(PanelCategorisation, enabled);
                // IncidentNo is allways disabled
                txtIncidentNo.Enabled = false;
            }
        }

        /// <summary>
        /// Sets new values to textboxes
        /// </summary>
        public void PopulateIncidentView(Incident incident)
        {
            hidCreationDate.Value = incident.CreationDate.ToShortDateString();
            txtIncidentNo.Text = incident.IncidentNo.ToString();
            txtSTRSFONo.Text = incident.DonorNumber;
            txtDateOfEvent.Text = incident.DateTimeOfIncident == null ? String.Empty : ((DateTime)incident.DateTimeOfIncident).ToShortDateString();
            txtTimeOfEvent.Text = incident.DateTimeOfIncident == null ? String.Empty : ((DateTime)incident.DateTimeOfIncident).ToShortTimeString();
            txtLocation.Text = incident.Location;
            txtIncidentDescription.Text = incident.IncidentDescription;
            txtPersonsInvolved.Text = incident.PersonsInvolved;
            txtImpact.Text = incident.Impact;
            txtSuggestionsPropositions.Text = incident.Suggestions;
            txtCategoryOther.Text = incident.CategoryOther;

            ddlProcess.SelectedIndex = ddlProcess.Items.IndexOf(ddlProcess.Items.FindByValue(incident.IncidentProcessID.ToString()));
            if (incident.IncidentProcessID.HasValue)
            {
                ddlCategoryLoadDataSource(incident.IncidentProcessID.Value, true);
            }
            ddlCategory.SelectedIndex = ddlCategory.Items.IndexOf(ddlCategory.Items.FindByValue(incident.IncidentCategoryID.ToString()));
            ddlCategory_SelectedIndexChanged(new object(), new EventArgs());
        }

        /// <summary>
        /// Assign value to incident object
        /// </summary>
        public Incident AssignValuesToIncident(Incident incident)
        {
            if (incident.ID == 0)
            {
                // Init Values
                DataService<aspnet_Users> aspUsers = new DataService<aspnet_Users>(BasePage.Data);
                aspnet_Users aspUser = aspUsers.GetAll().Where(user => user.UserName == BasePage.User.Identity.Name).FirstOrDefault<aspnet_Users>();

                DataService<Coordinator> coordinators = new DataService<Coordinator>(BasePage.Data);
                Coordinator coordinator = coordinators.GetAll().Where(co => co.Code == aspUser.UserName).FirstOrDefault<Coordinator>();

                // Get max value of Incident No
                var select = (from inc in BasePage.Data.Incident
                              select inc.IncidentNo);
                if (select.Count() > 0)
                {
                    incident.IncidentNo = select.Max() + 1;
                }
                else
                {
                    incident.IncidentNo = 1;
                }

                // Creator/Creating information
                incident.CreatorEmail = aspUser.aspnet_Membership.Email;
                if (coordinator != null)
                {
                    // coordinator could be null --> Case Pentag_User
                    if (coordinator.Address != null && coordinator.Address.Phone != String.Empty)
                    {
                        incident.CreatorPhone = coordinator.Address.Phone;
                    }
                    else
                    {
                        incident.CreatorPhone = coordinator.Hospital.Address.Phone;
                    }
                    incident.CreatorCenter = coordinator.Hospital.Name;
                }

                incident.CreationDate = DateTime.Now;
                incident.CreatorUserName = BasePage.User.Identity.Name;
                incident.IsArchived = false;
                incident.IsDeleted = false;
                incident.ModificationDate = DateTime.Now;
                incident.IncidentStateID = 1; // New
            }

            // Load values
            incident.DonorNumber = txtSTRSFONo.Text;
            incident.DateTimeOfIncident = !String.IsNullOrWhiteSpace(txtDateOfEvent.Text + " " + txtTimeOfEvent.Text)
                                  ? (DateTime?)Convert.ToDateTime(txtDateOfEvent.Text + " " + txtTimeOfEvent.Text)
                                  : null;
            incident.Location = txtLocation.Text;
            incident.IncidentDescription = txtIncidentDescription.Text;
            incident.PersonsInvolved = txtPersonsInvolved.Text;
            incident.Impact = txtImpact.Text;
            incident.Suggestions = txtSuggestionsPropositions.Text;
            incident.CategoryOther = txtCategoryOther.Text;
            int id = int.Parse(ddlProcess.SelectedValue);
            incident.IncidentProcessID = id == 0 ? null : (int?)id;
            id = int.Parse(ddlCategory.SelectedValue);
            incident.IncidentCategoryID = id == 0 ? null : (int?)id;

            return incident;
        }

        /// <summary>
        /// Cleans textboxes
        /// </summary>
        public void Clear()
        {
            hidCreationDate.Value = String.Empty;
            txtIncidentNo.Text = String.Empty;
            txtSTRSFONo.Text = String.Empty;
            txtDateOfEvent.Text = String.Empty;
            txtTimeOfEvent.Text = String.Empty;
            txtLocation.Text = String.Empty;
            txtIncidentDescription.Text = String.Empty;
            txtPersonsInvolved.Text = String.Empty;
            txtImpact.Text = String.Empty;
            txtSuggestionsPropositions.Text = String.Empty;
            txtCategoryOther.Text = String.Empty;
            ddlProcess.SelectedIndex = -1;
            ddlCategory.SelectedIndex = -1;

            txtSTRSFONo_TextChanged(this, new EventArgs());
        }

        /// <summary>
        /// Use for dropdownlist validate
        /// </summary>
        protected void cvDropDownList_ServerValidate(object source, ServerValidateEventArgs args)
        {
            BasePage.cvDropDownList_ServerValidate(source, args);
        }

        /// <summary>
        /// Validates Date
        /// </summary>
        protected void cvDateOfEvent_ServerValidate(object source, ServerValidateEventArgs args)
        {
            BasePage.cvDate_ServerValidate(source, args);
            if (args.IsValid)
            {
                DateTime dateOfEvent = DateTime.ParseExact(args.Value, "dd.MM.yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None);
                if (hidCreationDate.Value != String.Empty)
                {
                    DateTime creationDate = DateTime.ParseExact(hidCreationDate.Value, "dd.MM.yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None);
                    if (dateOfEvent > creationDate)
                    {
                        args.IsValid = false;
                    }
                }
                if (dateOfEvent > DateTime.Today)
                {
                    args.IsValid = false;
                }
            }
        }

        /// <summary>
        /// Load Drop Down Lists
        /// </summary>
        private void BindDropDownLists()
        {
            // Dropdown Category
            ddlProcess.ClearSelection();
            ddlProcess.DataSource = BasePage.GetIncidentProcesses().ToList();
            ddlProcess.DataValueField = "ID";
            ddlProcess.DataTextField = "Description";
            ddlProcess.DataBind();
            if (ddlProcess.Enabled)
            {
                ddlProcess.Items.Insert(0, new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT, DropDownDefaultValue.DDL_DEFAULT_VALUE));
            }

            // Dropdown Process
            ddlCategory.ClearSelection();
            if (ddlCategory.Enabled)
            {
                ddlCategory.Items.Insert(0, new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT, DropDownDefaultValue.DDL_DEFAULT_VALUE));
            }
        }

        /// <summary>
        /// Change Category-DataSource
        /// </summary>
        protected void ddlProcess_SelectedIndexChanged(object sender, EventArgs e)
        {
            string processId = ddlProcess.SelectedItem.Value;
            ddlCategoryLoadDataSource(int.Parse(processId), false);
        }

        /// <summary>
        /// Changing Category DropDown List
        /// </summary>
        /// <param name="processId">IncidenProcessId</param>
        /// <param name="changeValue">True: Doesn't set the old value, False: Tries to set old value</param>
        private void ddlCategoryLoadDataSource(int processId, bool changeValue)
        {
            string selectedItem = ddlCategory.SelectedItem.Value;

            ddlCategory.ClearSelection();
            ddlCategory.DataSource = BasePage.GetIncidentCategories(processId).ToList();
            ddlCategory.DataValueField = "ID";
            ddlCategory.DataTextField = "Description";
            ddlCategory.DataBind();
            if (ddlCategory.Enabled)
            {
                ddlCategory.Items.Insert(0, new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT, DropDownDefaultValue.DDL_DEFAULT_VALUE));
            }
            if (!changeValue)
            {
                int indexOfItem = ddlCategory.Items.IndexOf(ddlCategory.Items.FindByValue(selectedItem));
                if (indexOfItem > 0)
                {
                    ddlCategory.SelectedIndex = indexOfItem;
                }
            }
        }

        /// <summary>
        /// Hide/Unhide Other field
        /// </summary>
        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlCategory.SelectedItem.Text == "Other")
            {
                txtCategoryOther.Visible = true;
            }
            else
            {
                txtCategoryOther.Visible = false;
                txtCategoryOther.Text = String.Empty;
            }
        }
    }
}