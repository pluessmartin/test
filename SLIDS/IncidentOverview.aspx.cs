using Pentag.SLIDS.Common;
using Pentag.SLIDS.Constants;
using Pentag.SLIDS.Controls;
using Pentag.SLIDS.DAL;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.Objects;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public partial class IncidentOverview : BasePage
    {
        private int _incidentId;
        public int IncidentId
        {
            get { return _incidentId; }
            set
            {
                _incidentId = value;
                icIncidentDocumentsControl.IncidentID = _incidentId;
                icIncidentDonorControl.IncidentId = _incidentId;
            }
        }

        public int IncidentTaskId { get; set; }
        public int IncidentAlertId { get; set; }
        public int IncidentAnalysisId { get; set; }

        // Lazyloading DataService Incident
        private DataService<Incident> _dsIncident;
        private DataService<Incident> dsIncident
        {
            get
            {
                if (_dsIncident == null)
                {
                    _dsIncident = new DataService<Incident>(Data);
                }
                return _dsIncident;
            }
        }

        // Lazyloading DataService IncidentTask
        private DataService<IncidentTask> _dsIncidentTask;
        private DataService<IncidentTask> dsIncidentTask
        {
            get
            {
                if (_dsIncidentTask == null)
                {
                    _dsIncidentTask = new DataService<IncidentTask>(Data);
                }
                return _dsIncidentTask;
            }
        }



        // Lazyloading DataService IncidentTask
        private DataService<IncidentAnalysis> _dsIncidentAnalysis;
        private DataService<IncidentAnalysis> dsIncidentAnalysis
        {
            get
            {
                if (_dsIncidentAnalysis == null)
                {
                    _dsIncidentAnalysis = new DataService<IncidentAnalysis>(Data);
                }
                return _dsIncidentAnalysis;
            }
        }


        // Lazyloading DataService IncidentAlert
        private DataService<IncidentAlert> _dsIncidentAlert;
        private DataService<IncidentAlert> dsIncidentAlert
        {
            get
            {
                if (_dsIncidentAlert == null)
                {
                    _dsIncidentAlert = new DataService<IncidentAlert>(Data);
                }
                return _dsIncidentAlert;
            }
        }

        /// <summary>
        /// On loading page setting all selected IDs
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                if (gvIncidents.SelectedPersistedDataKey != null)
                {
                    IncidentId = Convert.ToInt32(gvIncidents.SelectedPersistedDataKey.Value);
                    divIncidentsLexiconHelpAdd.Attributes.CssStyle.Clear();
                }
                if (gvTasks.SelectedPersistedDataKey != null)
                {
                    IncidentTaskId = Convert.ToInt32(gvTasks.SelectedPersistedDataKey.Value);
                }
                if (gvAlerts.SelectedPersistedDataKey != null)
                {
                    IncidentAlertId = Convert.ToInt32(gvAlerts.SelectedPersistedDataKey.Value);
                }
                if (gvAnalysis.SelectedPersistedDataKey != null)
                {
                    IncidentAnalysisId = Convert.ToInt32(gvAnalysis.SelectedPersistedDataKey.Value);
                }
            }
            else
            {
                BindDropDownLists();
                SetToolTipps();
                SetVisbility();

                string incidentId = HttpUtility.UrlDecode(Request.QueryString["IncidentId"]);
                if (incidentId != null)
                {
                    IncidentId = int.Parse(incidentId);
                }
            }
            icIncidentControl.DonorNrChanged += icIncidentControl_DonorNrChanged;
            icIncidentDocumentsControl.ErrorMsg += icIncidentDocumentsControl_ErrorMsg;
        }


        /// <summary>
        /// Displays Error messages when thrown
        /// </summary>
        void icIncidentDocumentsControl_ErrorMsg(object sender, EventArgs e)
        {
            if (sender is KeyValuePair<SLIDSMaster.LabelState, string>)
            {
                KeyValuePair<SLIDSMaster.LabelState, string> error = (KeyValuePair<SLIDSMaster.LabelState, string>)sender;
                Master.SetInfoLabel(error.Value, error.Key);
            }
        }

        private void SetVisbility()
        {
            if (!Master.IsIncidentAdmin)
            {
                chkShowOriginalDeclaration.Visible = false;
                chkShowOverdueFollowUpTasksOnly.Visible = false;
                pnlDeclarer.Visible = false;
                tpAlerts.Visible = false;
                tpFollowUp.Visible = false;
                tpProcessing.Visible = false;
                btnIncidentReport.Visible = false;
            }
        }

        /// <summary>
        /// Select correct rows on given parameters
        /// </summary>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            if (IncidentId != 0 && !IsPostBack)
            {
                SelectRowInGridView(gvIncidents, IncidentId);
            }

        }

        void icIncidentControl_DonorNrChanged(object sender, EventArgs e)
        {
            if (!Master.IsIncidentUser)
            {
                icIncidentDonorControl.DonorNumber = icIncidentControl.DonorNr;
                icIncidentDonorControl.Enabled = icIncidentControl.Enabled;
                icIncidentDonorControl.DataBind();
            }
        }

        /// <summary>
        /// Calculates risk scaling number and potential risk number
        /// </summary>
        private void CalculateRiskNumbers()
        {
            int likelihoodToRepeatId = int.Parse(ddlLikelihoodToRepeat.Items[ddlLikelihoodToRepeat.SelectedIndex].Value);
            int damageCategoryId = int.Parse(ddlDamageCategory.Items[ddlDamageCategory.SelectedIndex].Value);

            if (likelihoodToRepeatId != 0 && damageCategoryId != 0)
            {
                // risk scaling number
                int likelihoodToRepeatValue = (int)(new DataService<IncidentLikelihoodToRepeat>(Data)).Get(likelihoodToRepeatId).Value;
                int damageCategoryValue = (int)(new DataService<IncidentDamageCategory>(Data)).Get(damageCategoryId).Value;
                txtRiskScalingNumber.Text = (((decimal)(likelihoodToRepeatValue * damageCategoryValue))).ToString("0.##");

                int potentialDamageId = int.Parse(ddlPotentialDamage.Items[ddlPotentialDamage.SelectedIndex].Value);
                if (potentialDamageId != 0)
                {
                    // potential risk number
                    int potentialDamageValue = (int)(new DataService<IncidentPotentialDamage>(Data)).Get(potentialDamageId).Value;
                    txtPotentialRiskNumber.Text = (((decimal)(likelihoodToRepeatValue * potentialDamageValue * damageCategoryValue))).ToString("0.##");
                }
                else
                {
                    txtPotentialRiskNumber.Text = String.Empty;
                }
            }
            else
            {
                txtRiskScalingNumber.Text = String.Empty;
                txtPotentialRiskNumber.Text = String.Empty;
            }
        }

        /// <summary>
        /// Load Drop Down Lists
        /// </summary>
        private void BindDropDownLists()
        {
            ddlCategory.ClearSelection();
            ddlCategory.DataSource = GetIncidentCategories().ToList();
            ddlCategory.DataValueField = "ID";
            ddlCategory.DataTextField = "Description";
            ddlCategory.DataBind();
            if (ddlCategory.Enabled)
                ddlCategory.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));

            ddlProcess.ClearSelection();
            ddlProcess.DataSource = GetIncidentProcesses().ToList();
            ddlProcess.DataValueField = "ID";
            ddlProcess.DataTextField = "Description";
            ddlProcess.DataBind();
            if (ddlProcess.Enabled)
                ddlProcess.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));

            ddlState.ClearSelection();
            ddlState.DataSource = GetIncidentStates().ToList();
            ddlState.DataValueField = "ID";
            ddlState.DataTextField = "Description";
            ddlState.DataBind();
            if (ddlState.Enabled)
                ddlState.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));

            ddlStateOfIncident.ClearSelection();
            ddlStateOfIncident.DataSource = GetIncidentStates().ToList();
            ddlStateOfIncident.DataValueField = "ID";
            ddlStateOfIncident.DataTextField = "Description";
            ddlStateOfIncident.DataBind();
            if (ddlStateOfIncident.Enabled)
                ddlStateOfIncident.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));

            ddlDamageCategory.ClearSelection();
            ddlDamageCategory.DataSource = (new DataService<IncidentDamageCategory>(Data)).GetAll().OrderBy(idc => idc.Position).ToList();
            ddlDamageCategory.DataValueField = "ID";
            ddlDamageCategory.DataTextField = "Description";
            ddlDamageCategory.DataBind();
            if (ddlDamageCategory.Enabled)
                ddlDamageCategory.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));

            ddlPotentialDamage.ClearSelection();
            ddlPotentialDamage.DataSource = (new DataService<IncidentPotentialDamage>(Data)).GetAll().OrderBy(ipd => ipd.Position).ToList();
            ddlPotentialDamage.DataValueField = "ID";
            ddlPotentialDamage.DataTextField = "Description";
            ddlPotentialDamage.DataBind();
            if (ddlPotentialDamage.Enabled)
                ddlPotentialDamage.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));

            ddlLikelihoodToRepeat.ClearSelection();
            ddlLikelihoodToRepeat.DataSource = (new DataService<IncidentLikelihoodToRepeat>(Data)).GetAll().OrderBy(iltr => iltr.Position).ToList();
            ddlLikelihoodToRepeat.DataValueField = "ID";
            ddlLikelihoodToRepeat.DataTextField = "Description";
            ddlLikelihoodToRepeat.DataBind();
            if (ddlLikelihoodToRepeat.Enabled)
                ddlLikelihoodToRepeat.Items.Insert(0,
                                   new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        #region gvIncidents
        /// <summary>
        /// Selection/Fill Method for gvOrgans
        /// </summary>
        /// <returns></returns>
        public IQueryable<Incident> gvIncidents_GetData()
        {
            IQueryable<DAL.Coordinator> coordinator = from aspuser in Data.aspnet_Users
                                                      join coord in Data.Coordinator
                                                      on aspuser.UserName equals coord.Code
                                                      where aspuser.UserName == User.Identity.Name
                                                      select coord;

            string hospital = string.Empty;
            if (coordinator.Count() == 1)
            {
                hospital = coordinator.First().Hospital.Name;
            }


            DateTime dateFrom = DateTime.MinValue;
            DateTime dateTo = DateTime.MaxValue;
            int processID = int.Parse(ddlProcess.SelectedItem.Value);
            int categoryID = int.Parse(ddlCategory.SelectedItem.Value);
            int stateID = int.Parse(ddlState.SelectedItem.Value);

            int riskScale = 0;
            if (txtRiskScale.Text != "")
            {
                riskScale = int.Parse(txtRiskScale.Text);
            }

            if (txtDateFrom.Text != String.Empty)
            {
                dateFrom = Convert.ToDateTime(txtDateFrom.Text);
            }

            if (txtDateTo.Text != string.Empty)
            {
                dateTo = Convert.ToDateTime(txtDateTo.Text);
            }

            bool showAllIncidents =
                Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.IncidentAdmin.ToString())
                || Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.Swisstransplant.ToString())
                || Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.Admin.ToString())
                || Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.NC.ToString())
                || Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.TC.ToString());

            bool showOnlyTransport = Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.IncidentUser.ToString()) && Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.AAA.ToString());


            return from incident in Data.Incident

                   where incident.DonorNumber.Contains(txtSTRSFONo.Text)
                                      && (txtRiskScale.Text == "" || (incident.IncidentDamageCategory != null && incident.IncidentLikelihoodToRepeat != null && ((incident.IncidentDamageCategory.Value * incident.IncidentLikelihoodToRepeat.Value) == riskScale)))
                                      && (
                                        (incident.DateTimeOfIncident.HasValue && dateFrom <= EntityFunctions.TruncateTime(incident.DateTimeOfIncident) && dateTo >= EntityFunctions.TruncateTime(incident.DateTimeOfIncident))
                                        || !incident.DateTimeOfIncident.HasValue
                                        )
                                      && (processID == 0 || incident.IncidentProcessID == processID)
                                      && (categoryID == 0 || incident.IncidentCategoryID == categoryID)
                                      && (stateID == 0 || incident.IncidentStateID == stateID)
                                      && (incident.IsArchived == false || chkIncludeArchives.Checked)
                                      && incident.IsDeleted == false
                                      && incident.OriginalID != null
                                      && ((chkShowOverdueFollowUpTasksOnly.Checked && incident.IncidentTask.Any(t => t.Deadline < DateTime.Now && !t.IsDone)) || !chkShowOverdueFollowUpTasksOnly.Checked)
                                    &&
                                        (
                                            incident.IncidentProcess.Description == "Transport"
                                            ||
                                            !showOnlyTransport
                                        )
                   orderby incident.IncidentNo descending
                   select incident;
        }

        /// <summary>
        /// Shows correct record in fields
        /// </summary>
        protected void gvIncidents_SelectedIndexChanged(object sender, EventArgs e)
        {
            // If a row was selected, set DonorID Property and populate detail view
            if (gvIncidents.SelectedIndex != -1)
            {
                IncidentId = Convert.ToInt32(gvIncidents.SelectedPersistedDataKey.Value);
                IncidentTaskId = 0;
                IncidentAlertId = 0;
                IncidentAnalysisId = 0;
                LoadAndViewDataDetails();
                divIncidentsLexiconHelpAdd.Attributes.CssStyle.Clear();
                CalculateRiskNumbers();
            }
            gvIncidents.DataBind();
            upIncidentView.Update();
        }
        #endregion

        #region gvAnalysis
        /// <summary>
        /// Selection/Fill Method for gvAnalysis
        /// </summary>
        /// <returns></returns>
        public IQueryable<IncidentAnalysis> gvAnalysis_GetData()
        {
            return dsIncidentAnalysis.GetAll().Where(it => it.IncidentID == IncidentId).OrderBy(incTask => incTask.CreationDate); ;
        }

        /// <summary>
        /// Change IncidentTask View
        /// </summary>
        protected void gvAnalysis_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvAnalysis.SelectedIndex != -1)
            {
                pnlAnalyse.Visible = true;
                IncidentAnalysisId = Convert.ToInt32(gvAnalysis.SelectedPersistedDataKey.Value);
                LoadIncidentAnalysis();
            }
        }
        #endregion

        #region gvTasks
        /// <summary>
        /// Selection/Fill Method for gvTasks
        /// </summary>
        /// <returns></returns>
        public IQueryable<IncidentTask> gvTasks_GetData()
        {
            return dsIncidentTask.GetAll().Where(it => it.IncidentID == IncidentId).OrderBy(incTask => incTask.CreationDate); ;
        }

        /// <summary>
        /// Change IncidentTask View
        /// </summary>
        protected void gvTasks_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvTasks.SelectedIndex != -1)
            {
                pnlTask.Visible = true;
                IncidentTaskId = Convert.ToInt32(gvTasks.SelectedPersistedDataKey.Value);
                LoadIncidentTask();
            }
        }
        #endregion

        #region gvAlerts
        /// <summary>
        /// Selection/Fill Method for gvAlerts
        /// </summary>
        /// <returns></returns>
        public IQueryable<IncidentAlert> gvAlerts_GetData()
        {
            return dsIncidentAlert.GetAll().Where(ia => ia.IncidentID == IncidentId && ia.IsDeleted == false);
        }

        /// <summary>
        /// On incident alert change
        /// </summary>
        protected void gvAlerts_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvAlerts.SelectedIndex != -1)
            {
                IncidentAlertId = Convert.ToInt32(gvAlerts.SelectedPersistedDataKey.Value);
                LoadIncidentAlert();
            }
            gvHospitalVisible.DataBind();
        }
        #endregion

        protected void txtSearchField_TextChanged(object sender, EventArgs e)
        {
            gvIncidents.DataBind();
        }

        /// <summary>
        /// Load incident
        /// </summary>
        private void LoadAndViewDataDetails()
        {
            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
            PopulateIncidentDetailView();
        }

        /// <summary>
        /// Populate Incident detail view
        /// </summary>
        private void PopulateIncidentDetailView()
        {
            if (IncidentId > 0)
            {
                Incident incident = dsIncident.Get(IncidentId);

                icIncidentControl.PopulateIncidentView(incident);
                icIncidentControl.AllowEnable = true;
                icIncidentDocumentsControl.DataBind();

                // Tab Incident
                txtUserName.Text = incident.CreatorUserName;
                txtEmail.Text = incident.CreatorEmail;
                txtHospital.Text = incident.CreatorCenter;
                txtHospitalTel.Text = incident.CreatorPhone;
                txtCreationDate.Text = incident.CreationDate.ToShortDateString();
                txtCreationTime.Text = incident.CreationDate.ToShortTimeString();

                // Tab proccessing
                ddlStateOfIncident.SelectedIndex = incident.IncidentStateID != null ? (int)incident.IncidentState.Position : 0;
                ddlDamageCategory.SelectedIndex = incident.IncidentDamageCategoryID != null ? (int)incident.IncidentDamageCategory.Position : 0;
                ddlPotentialDamage.SelectedIndex = incident.IncidentPotentialDamageID != null ? (int)incident.IncidentPotentialDamage.Position : 0;
                ddlLikelihoodToRepeat.SelectedIndex = incident.IncidentLikelihoodToRepeatID != null ? (int)incident.IncidentLikelihoodToRepeat.Position : 0;

                txtDamageDescription.Text = incident.DamageDescription;
                txtCorrectiveAction.Text = incident.CorrectiveAction;
                txtPreventiveAction.Text = incident.PreventiveAction;
                //txtAnalysis.Text = incident.Analysis;

                // Tab follow up
                gvTasks.SelectedIndex = -1;
                gvTasks.DataBind();
                gvAnalysis.DataBind();
                IncidentTaskId = 0;
                IncidentAnalysisId = 0;

                // Tab Alerts
                gvAlerts.SelectedIndex = -1;
                gvAlerts.DataBind();
                pnlAlertBannerMessage.Visible = false;
                IncidentAlertId = 0;
                btnIncidentReport.NavigateUrl = "Reports/IncidentReportViewPDF.aspx?Id=" + incident.ID.ToString();

                List<string> excludedControl = new List<string>();
                excludedControl.Add("txtRiskScalingNumber");
                excludedControl.Add("pnlDeclarer");
                excludedControl.Add("chkShowOriginalDeclaration");
                excludedControl.Add("txtPotentialRiskNumber");
                excludedControl.Add("btnIncidentReport");
                bool enableControls = !(incident.IncidentState != null && incident.IncidentState.Description == "Closed")
                    && Master.IsIncidentAdmin;
                EnableOrDisableControls(tcTabs, enableControls, excludedControl);
            }
            else
            {
                icIncidentControl.Clear();
            }
            icIncidentControl_DonorNrChanged(this, new EventArgs());
        }

        /// <summary>
        /// Set Visibility
        /// </summary>
        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            if (IncidentId > 0)
            {
                tcTabs.Visible = true;
            }
            else
            {
                tcTabs.Visible = false;
            }
        }

        #region IncidentTask
        /// <summary>
        /// Create a new IncidentTask record (on view)
        /// </summary>
        protected void btnTaskAdd_Click(object sender, EventArgs e)
        {
            pnlTask.Visible = true;
            btnTaskDelete.Enabled = false;
            CleanIncidentTask();
        }

        /// <summary>
        /// Cleans IncidentTask fields
        /// </summary>
        private void CleanIncidentTask()
        {
            IncidentTaskId = 0;
            txtToDo.Text = String.Empty;
            txtDeadline.Text = String.Empty;
            chkDone.Checked = false;
            gvTasks.SelectedIndex = -1;
        }

        /// <summary>
        /// Load existing IncidentTask record
        /// </summary>
        private void LoadIncidentTask()
        {
            if (IncidentTaskId == 0)
            {
                pnlTask.Visible = false;
                btnTaskDelete.Enabled = false;
            }
            else
            {
                IncidentTask it = dsIncidentTask.Get(IncidentTaskId);
                txtToDo.Text = it.Description;
                txtDeadline.Text = it.Deadline == null ? String.Empty : ((DateTime)it.Deadline).ToShortDateString();
                chkDone.Checked = it.IsDone;
                pnlTask.Visible = true;
                btnTaskDelete.Enabled = true;
            }
        }

        protected void btnAnalysisAdd_Click(object sender, EventArgs e)
        {
            pnlAnalyse.Visible = true;
            btnAnalysisDelete.Enabled = false;
            CleanIncidentAnalysis();
        }

        /// <summary>
        /// Cleans IncidentTask fields
        /// </summary>
        private void CleanIncidentAnalysis()
        {
            IncidentAnalysisId = 0;
            txtAnalysis_.Text = String.Empty;
            txtACreationDate.Text = String.Empty;
            gvAnalysis.SelectedIndex = -1;
        }

        /// <summary>
        /// Load existing IncidentTask record
        /// </summary>
        private void LoadIncidentAnalysis()
        {
            if (IncidentAnalysisId == 0)
            {
                pnlAnalyse.Visible = false;
                btnAnalysisDelete.Enabled = false;
            }
            else
            {
                IncidentAnalysis it = dsIncidentAnalysis.Get(IncidentAnalysisId);
                txtAnalysis_.Text = it.Analysis;
                txtACreationDate.Text = it.CreationDate == null ? String.Empty : ((DateTime)it.CreationDate).ToShortDateString();
                pnlAnalysis.Visible = true;
                btnAnalysisDelete.Enabled = true;
            }
        }


        /// <summary>
        /// Saves IncidentTask
        /// </summary>
        protected void btnAnalysisSave_Click(object sender, EventArgs e)
        {
            IncidentAnalysis it;
            if (IncidentAnalysisId == 0)
            {
                // Create new record if not exists
                it = new IncidentAnalysis()
                {

                    IncidentID = IncidentId,
                    CreationDate = DateTime.Now
                };
            }
            else
            {
                // Load existing record
                it = dsIncidentAnalysis.Get(IncidentAnalysisId);
            }
            // Write fields
            it.Analysis = txtAnalysis_.Text;
            if (txtACreationDate.Text == "")
            {
                it.CreationDate = DateTime.Now;
            }
            else
            {
                it.CreationDate = (DateTime)DateTime.Parse(txtACreationDate.Text);
            }

            // Update existing record
            if (IncidentAnalysisId == 0)
            {
                it = dsIncidentAnalysis.Add(it);
                IncidentAnalysisId = it.ID;
                btnAnalysisDelete.Enabled = true;
            }
            else
            {
                dsIncidentAnalysis.Update(it, it.ID);
            }
            gvAnalysis.DataBind();
            SelectRowInGridView(gvAnalysis, it.ID);
        }

        /// <summary>
        /// Delete incident task
        /// </summary>
        protected void btnAnalysisDelete_Click(object sender, EventArgs e)
        {
            dsIncidentAnalysis.Delete(dsIncidentAnalysis.Get(IncidentAnalysisId));
            IncidentAnalysisId = 0;
            LoadIncidentAnalysis();
            btnAnalysisDelete.Enabled = false;
            gvAnalysis.DataBind();

            Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
        }

        /// <summary>
        /// Saves IncidentTask
        /// </summary>
        protected void btnTaskSave_Click(object sender, EventArgs e)
        {
            IncidentTask it;
            if (IncidentTaskId == 0)
            {
                // Create new record if not exists
                it = new IncidentTask()
                {
                    IncidentID = IncidentId,
                    CreationDate = DateTime.Now
                };
            }
            else
            {
                // Load existing record
                it = dsIncidentTask.Get(IncidentTaskId);
            }
            // Write fields
            it.Description = txtToDo.Text;
            it.Deadline = txtDeadline.Text != String.Empty ? (DateTime?)DateTime.Parse(txtDeadline.Text) : null;
            it.IsDone = chkDone.Checked;

            // Update existing record
            if (IncidentTaskId == 0)
            {
                it = dsIncidentTask.Add(it);
                IncidentTaskId = it.ID;
                btnTaskDelete.Enabled = true;
            }
            else
            {
                dsIncidentTask.Update(it, it.ID);
            }
            gvTasks.DataBind();
            gvAnalysis.DataBind();
            SelectRowInGridView(gvTasks, it.ID);
        }

        /// <summary>
        /// Delete incident task
        /// </summary>
        protected void btnTaskDelete_Click(object sender, EventArgs e)
        {
            dsIncidentTask.Delete(dsIncidentTask.Get(IncidentTaskId));
            IncidentTaskId = 0;
            LoadIncidentTask();
            btnTaskDelete.Enabled = false;
            gvTasks.DataBind();
            gvAnalysis.DataBind();

            Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
        }
        #endregion

        #region IncidentAlert

        /// <summary>
        /// Load incident alert
        /// </summary>
        private void LoadIncidentAlert()
        {
            if (IncidentAlertId == 0)
            {
                pnlAlertBannerMessage.Visible = false;
                btnAlertDelete.Enabled = false;
            }
            else
            {
                pnlAlertBannerMessage.Visible = true;
                btnAlertDelete.Enabled = true;
                IncidentAlert ia = dsIncidentAlert.Get(IncidentAlertId);
                txtAlertMessage.Text = ia.AlertMessage;
                txtStartDate.Text = ((DateTime)ia.StartDate).ToShortDateString();
                txtEndDate.Text = ((DateTime)ia.EndDate).ToShortDateString();
            }
            gvHospitalVisible.DataBind();
        }

        /// <summary>
        /// Adds Incident Alert
        /// </summary>
        protected void btnAlertAdd_Click(object sender, EventArgs e)
        {
            gvAlerts.SelectedIndex = -1;
            IncidentAlertId = 0;
            LoadIncidentAlert();
            pnlAlertBannerMessage.Visible = true;
            txtAlertMessage.Text = String.Empty;
            txtStartDate.Text = String.Empty;
            txtEndDate.Text = String.Empty;
        }

        /// <summary>
        /// Save Incident Alert
        /// </summary>
        protected void btnAlertSave_Click(object sender, EventArgs e)
        {
            if (IsValid)
            {
                try
                {
                    ICollection<Hospital> hospitals = GetAlertHospital();

                    if (IncidentAlertId == 0)
                    {
                        CreateIncidentAlert(hospitals);
                    }
                    else
                    {
                        UpdateIncidentAlert(hospitals);
                    }
                    Master.SetAlertMessage();
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                    gvAlerts.DataBind();
                    SelectRowInGridView(gvAlerts, IncidentAlertId);
                }
                catch (System.FormatException)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);
                }
            }
        }

        /// <summary>
        /// Returns all Hospital with Alert potential
        /// </summary>
        private ICollection<Hospital> GetAlertHospital()
        {
            ICollection<Hospital> hospitals = new List<Hospital>();
            // selected abgleich
            foreach (GridViewRow row in gvHospitalVisible.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    CheckBox chkSelected = (row.Cells[0].FindControl("chkSelect") as CheckBox);
                    if (chkSelected.Checked)
                    {
                        int hospitalId = (int)gvHospitalVisible.DataKeys[row.DataItemIndex].Value;
                        hospitals.Add(new DataService<Hospital>(Data).Get(hospitalId));
                    }
                }
            }
            return hospitals;
        }

        /// <summary>
        /// Refresh IncidentAlert record
        /// </summary>
        private void UpdateIncidentAlert(ICollection<Hospital> hospitals)
        {
            IncidentAlert ia;
            ia = dsIncidentAlert.Get(IncidentAlertId);
            ia.AlertMessage = txtAlertMessage.Text;
            ia.StartDate = Convert.ToDateTime(txtStartDate.Text);
            ia.EndDate = Convert.ToDateTime(txtEndDate.Text);
            ia.Hospital.Clear();
            foreach (Hospital hospital in hospitals)
            {
                ia.Hospital.Add(hospital);
            }
            dsIncidentAlert.Update(ia, ia.ID);
        }

        /// <summary>
        /// Creating IncidentAlert record
        /// </summary>
        private void CreateIncidentAlert(ICollection<Hospital> hospitals)
        {
            IncidentAlert ia;
            ia = new IncidentAlert()
            {
                CreationDate = DateTime.Now,
                IncidentID = IncidentId,
                IsDeleted = false,
                AlertMessage = txtAlertMessage.Text,
                StartDate = Convert.ToDateTime(txtStartDate.Text),
                EndDate = Convert.ToDateTime(txtEndDate.Text),
                Hospital = hospitals
            };
            ia = dsIncidentAlert.Add(ia);
            IncidentAlertId = ia.ID;
        }

        /// <summary>
        /// Delete Incident Alert
        /// </summary>
        protected void btnAlertDelete_Click(object sender, EventArgs e)
        {
            if (IncidentAlertId != 0)
            {
                IncidentAlert ia = dsIncidentAlert.Get(IncidentAlertId);
                ia.IsDeleted = true;
                ia = dsIncidentAlert.Update(ia, ia.ID);
                IncidentAlertId = 0;
                pnlAlertBannerMessage.Visible = false;
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                gvAlerts.DataBind();
                Master.SetAlertMessage();
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }
        }
        #endregion

        /// <summary>
        /// Saves all data in tab Processing
        /// </summary>
        protected void btnIncidentProcessingSave_Click(object sender, EventArgs e)
        {
            if (IncidentId != 0 && IsValid)
            {
                bool sendMail = false;
                bool infoLabelSet = false;
                Incident inc = dsIncident.Get(IncidentId);
                // sending mail on closing incident
                int stateId = int.Parse(ddlStateOfIncident.SelectedItem.Value);
                int selectedIndex = ddlStateOfIncident.Items.IndexOf(ddlStateOfIncident.Items.FindByValue(inc.IncidentStateID.ToString()));
                if (inc.IncidentStateID != stateId && stateId == 3)
                {
                    // Can't close incident if there are open tasks
                    var openTasks = from tasks in Data.IncidentTask
                                    where tasks.IncidentID == inc.ID
                                    where !tasks.IsDone
                                    select tasks;
                    if (openTasks.Count() > 0)
                    {
                        Master.SetInfoLabel(StatusMessages.MsgIncidentOpenTasks, SLIDSMaster.LabelState.Warning);
                        ddlStateOfIncident.SelectedIndex = selectedIndex;
                        infoLabelSet = true;
                    }
                    else
                    {
                        inc.IncidentStateID = stateId;
                        EnableOrDisableControls(tcTabs, false);
                        sendMail = true;
                    }
                }
                else
                {
                    inc.IncidentStateID = stateId;
                }
                inc.IncidentDamageCategoryID = int.Parse(ddlDamageCategory.SelectedItem.Value);
                inc.IncidentPotentialDamageID = int.Parse(ddlPotentialDamage.SelectedItem.Value);
                inc.IncidentLikelihoodToRepeatID = int.Parse(ddlLikelihoodToRepeat.SelectedItem.Value);
                inc.DamageDescription = txtDamageDescription.Text;
                inc.CorrectiveAction = txtCorrectiveAction.Text;
                inc.PreventiveAction = txtPreventiveAction.Text;
                //inc.Analysis = txtAnalysis.Text;
                inc = dsIncident.Update(inc, inc.ID);
                if (!infoLabelSet)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                }
                gvIncidents.DataBind();
                if (sendMail)
                {
                    List<string> mailLinks = SendMail(inc);
                    foreach (string link in mailLinks)
                    {
                        placeholder.Controls.Add(new ucAlterControl(link));
                    }
                }
                gvIncidents.DataBind();
                upIncidentView.Update();
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }
        }

        #region gvHospitalVisible
        /// <summary>
        /// Shows all possible alert hospital
        /// </summary>
        public IQueryable<Hospital> gvHospitalVisible_GetData()
        {
            return new DataService<Hospital>(Data).GetAll().Where(h => h.Coordinator.Where(c => c.isActive).Any());
        }

        /// <summary>
        /// Setting the checkbox for alert
        /// </summary>
        protected void gvHospitalVisible_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            GridView gv = (GridView)sender;
            int counter = 0;
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                CheckBox chkSelected = (e.Row.Cells[0].FindControl("chkSelect") as CheckBox);
                int hospitalId = (int)gvHospitalVisible.DataKeys[e.Row.DataItemIndex].Value;
                chkSelected.Checked = Data.Hospital.Where(h => h.IncidentAlert.Where(i => i.ID == IncidentAlertId).Any() && h.ID == hospitalId).Any();
                if (chkSelected.Checked)
                    counter++;
            }
        }

        #endregion

        protected void btnIncidentSave_Click(object sender, EventArgs e)
        {
            if (IsValid && icIncidentControl.IsValid())
            {
                icIncidentDonorControl.Save();
                Incident incident = dsIncident.Get(IncidentId);
                incident = icIncidentControl.AssignValuesToIncident(incident);
                dsIncident.Update(incident, incident.ID);
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                gvIncidents.DataBind();
                upIncidentView.Update();
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified, SLIDSMaster.LabelState.Info);
            }
        }

        protected void chkShowOriginalDeclaration_CheckedChanged(object sender, EventArgs e)
        {
            icIncidentControl.AllowEnable = dsIncident.Get(IncidentId).IncidentState.Value != 3;
            icIncidentControl.Enabled = !chkShowOriginalDeclaration.Checked;


            if (chkShowOriginalDeclaration.Checked)
            {
                icIncidentControl.PopulateIncidentView(dsIncident.Get(IncidentId).Incident2);
                icIncidentDocumentsControl.IncidentID = dsIncident.Get(IncidentId).Incident2.ID;
                icIncidentDocumentsControl.Enabled = false;
            }
            else
            {
                icIncidentControl.PopulateIncidentView(dsIncident.Get(IncidentId));
                icIncidentDocumentsControl.IncidentID = dsIncident.Get(IncidentId).ID;
                icIncidentDocumentsControl.Enabled = true;
            }
            icIncidentDocumentsControl.DataBind();
            upIncidentView.Update();
        }

        protected void chkboxSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            CheckBox chkBox = (CheckBox)sender;
            foreach (GridViewRow row in gvHospitalVisible.Rows)
            {
                ((CheckBox)row.FindControl("chkSelect")).Checked = chkBox.Checked;
            }
        }

        protected void chkSelect_CheckedChanged(object sender, EventArgs e)
        {
            foreach (GridViewRow row in gvHospitalVisible.Rows)
            {
                if (!((CheckBox)row.FindControl("chkSelect")).Checked)
                {
                    ((CheckBox)gvHospitalVisible.HeaderRow.FindControl("chkboxSelectAll")).Checked = false;
                    return;
                }
            }
            ((CheckBox)gvHospitalVisible.HeaderRow.FindControl("chkboxSelectAll")).Checked = true;
        }

        protected void gvHospitalVisible_PreRender(object sender, EventArgs e)
        {
            foreach (GridViewRow row in gvHospitalVisible.Rows)
            {
                if (!((CheckBox)row.FindControl("chkSelect")).Checked)
                {
                    ((CheckBox)gvHospitalVisible.HeaderRow.FindControl("chkboxSelectAll")).Checked = false;
                    return;
                }
            }
            ((CheckBox)gvHospitalVisible.HeaderRow.FindControl("chkboxSelectAll")).Checked = true;
        }

        protected void ddlLikelihoodToRepeat_SelectedIndexChanged(object sender, EventArgs e)
        {
            CalculateRiskNumbers();
        }

        protected void btnIncidentDelete_Click(object sender, EventArgs e)
        {
            if (IncidentId != 0)
            {
                Incident inc = dsIncident.Get(IncidentId);
                inc.IsDeleted = true;
                inc = dsIncident.Update(inc, inc.ID);
                IncidentId = 0;
                LoadAndViewDataDetails();
                upIncidentView.Update();
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                gvIncidents.DataBind();
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }
        }
    }
}