using Pentag.SLIDS.Common;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public partial class SLIDSMaster : MasterPage
    {
        #region Properties
        /// <summary>
        ///     Public Selected DonorID which can be set and accessed from all ContentPages
        /// </summary>
        public int DonorID
        {
            get { return hidDonorID.Value == String.Empty ? 0 : Convert.ToInt32(hidDonorID.Value); }
            set { hidDonorID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        public bool IsAdmin
        {
            get { return Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.Admin.ToString()); }
        }

        public bool IsNC
        {
            get { return Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.NC.ToString()); }
        }

        public bool IsTC
        {
            get { return Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.TC.ToString()); }
        }

        public bool IsAAA
        {
            get { return Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.AAA.ToString()); }
        }

        public bool IsIncidentAdmin
        {
            get { return Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.IncidentAdmin.ToString()); }
        }

        public bool IsIncidentUser
        {
            get { return Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.IncidentUser.ToString()); }
        }

        public bool IsSwisstransplant
        {
            get { return Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.Swisstransplant.ToString()); }
        }

        public bool IsOnlyAAA
        {
            get { return (IsAAA && !IsAdmin && !IsIncidentAdmin && !IsIncidentUser && !IsNC && !IsSwisstransplant && !IsTC); }
        }
        #endregion

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            ResetInfoLabel();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // Every new Pageload should have a new DataContext, so Updated (by someone else) Data is read from Database.
            Session.Remove("DataContext");

            SetMenuVisibilityAccordingToAuthentication();

            lblVersion.Text = Assembly.GetExecutingAssembly().GetName().Name + " "
                              + Assembly.GetExecutingAssembly().GetName().Version;

            SetAlertMessage();
            lblHeaderMessage.Text = ConfigurationManager.AppSettings["headerMessage"];
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            Menu rootMenu = (Menu)FindControl("NavigationMenu");
            if (rootMenu != null)
            {
                // Append Querystring with DonorID on menu items
                AppendDonorToNavigateUrlOfMenuItemsRecursively(DonorID, rootMenu.Items);

                DisOrEnableMenues(rootMenu.Items, (DonorID != 0));
            }

            pnlSelectedDonor.Visible = DonorID > 0;
        }

        protected void lnkResetUserPassword_Init(object sender, EventArgs e)
        {
            lnkResetUserPassword.NavigateUrl = "~/Administration/ResetUserPassword.aspx?user=" + Page.User.Identity.Name;
        }

        /// <summary>
        ///     Selection/Fill Method for gvDonor
        /// </summary>
        /// <returns></returns>
        public IQueryable<Donor> gvSelectedDonor_GetData()
        {
            BasePage basePage = new BasePage();

            return basePage.GetDonors()
                           .Where(d => d.ID == DonorID);
        }

        #region Info Lable handling
        public enum LabelState
        {
            Success,
            Info,
            Warning,
            Error
        };

        public void SetInfoLabel(string text, LabelState state = LabelState.Info)
        {
            SetInfoLabelStatus(state);
            lblStatus.Text = text;
        }

        /// <summary>
        ///     Sets the info lable status and image to visible
        /// </summary>
        /// <param name="state">state</param>
        private void SetInfoLabelStatus(LabelState state)
        {
            switch (state)
            {
                case LabelState.Success:
                    imgStatus.ImageUrl = "~/resources/infoLabel_okay.png";
                    lblStatus.CssClass = "lblSuccess";
                    break;
                case LabelState.Info:
                    imgStatus.ImageUrl = "~/resources/infoLabel_info.png";
                    lblStatus.CssClass = "lblInfo";
                    break;
                case LabelState.Warning:
                    imgStatus.ImageUrl = "~/resources/infoLabel_warnung.png";
                    lblStatus.CssClass = "lblWarning";
                    break;
                case LabelState.Error:
                    imgStatus.ImageUrl = "~/resources/infoLabel_error.png";
                    lblStatus.CssClass = "lblError";
                    break;
            }
            imgStatus.Visible = true;
        }

        public void ResetInfoLabel()
        {
            lblStatus.Text = string.Empty;
            imgStatus.Visible = false;
        }
        #endregion

        #region Privates

        /// <summary>
        ///     Displays menu items according to logged in user role (via Membership)
        /// </summary>
        private void DisplayMenuItemsAccordingToUserRole()
        {
            Menu rootMenu = (Menu)FindControl("NavigationMenu");

            if (rootMenu == null) return;

            // Remove Menu Administration for Non-Admins and Non-IncidentAdmins
            MenuItem menuItemAdmin = rootMenu.FindItem("Administration");
            if (menuItemAdmin != null && !IsAdmin && !IsIncidentAdmin)
            {
                rootMenu.Items.Remove(menuItemAdmin);
            }

            // Hide Submenues of Administration for IncidentAdmin
            if (menuItemAdmin != null && !IsAdmin && IsIncidentAdmin)
            {
                // Collect menu items to remove
                List<MenuItem> menuItemsToRemove = new List<MenuItem>();
                foreach (MenuItem adminChildItem in menuItemAdmin.ChildItems)
                {
                    if (adminChildItem.Text != "Manage users") menuItemsToRemove.Add(adminChildItem);
                }

                // Remove menu items except "Manage users"
                foreach (MenuItem menuItemToRemove in menuItemsToRemove)
                {
                    menuItemAdmin.ChildItems.Remove(menuItemToRemove);
                }
            }

            // Remove Menu Costs for Non-NC and Non-Admins
            MenuItem menuItemCost = rootMenu.FindItem("Cost");
            if (menuItemCost != null && !IsNC && !IsAdmin)
            {
                rootMenu.Items.Remove(menuItemCost);
            }

            // Remove Menu Statistics for Non-NC and Non-Admins
            MenuItem menuItemStats = rootMenu.FindItem("Statistics");
            if (menuItemStats != null && !IsNC && !IsAdmin)
            {
                rootMenu.Items.Remove(menuItemStats);
            }

            // Remove Menu Incidents for AAA
            MenuItem menuItemIncident = rootMenu.FindItem("Incidents");
            if (menuItemIncident != null && IsAAA && !IsIncidentUser && !IsIncidentAdmin)
            {
                rootMenu.Items.Remove(menuItemIncident);
            }

            MenuItem menuItemIncidentOverview = null;
            // Remove Menu Add Incident for Incident User
            foreach (MenuItem menuItemIncidentSub in menuItemIncident.ChildItems)
            {
                if (menuItemIncidentSub.Text == "Overview")
                {
                    menuItemIncidentOverview = menuItemIncidentSub;
                }
            }
            if (menuItemIncidentOverview != null && !IsNC && !IsTC && !IsAdmin && !IsIncidentAdmin && !IsSwisstransplant && !(IsAAA && (IsIncidentAdmin || IsIncidentUser)))
            {
                menuItemIncident.ChildItems.Remove(menuItemIncidentOverview);
            }

            // Remove Menu Donor for Incident-Users which have no other role
            MenuItem menuItemDonor = rootMenu.FindItem("Donor");
            MenuItem menuItemOrgan = rootMenu.FindItem("Organs");
            MenuItem menuItemTransport = rootMenu.FindItem("Transport");
            MenuItem menuItemDelay = rootMenu.FindItem("Delay");
            if (
                menuItemDonor != null && menuItemOrgan != null && menuItemTransport != null && menuItemDelay != null
                && !IsNC && !IsTC && !IsAAA && !IsAdmin && !IsIncidentAdmin && !IsSwisstransplant
                )
            {
                rootMenu.Items.Remove(menuItemDonor);
                rootMenu.Items.Remove(menuItemOrgan);
                rootMenu.Items.Remove(menuItemTransport);
                rootMenu.Items.Remove(menuItemDelay);
            }
        }

        /// <summary>
        ///     Disable or enable Menus according to availability of Donor. If Donor is not available, disable all menus which are depending on Donor
        /// </summary>
        /// <param name="menuItemCollection"></param>
        /// <param name="enable"></param>
        private void DisOrEnableMenues(MenuItemCollection menuItemCollection, bool enable)
        {
            foreach (MenuItem menuItem in menuItemCollection)
            {
                if (menuItem.Text != "Donor" && menuItem.Text != "Statistics" && menuItem.Text != "Administration" && menuItem.Text != "Incidents")
                {
                    menuItem.Enabled = enable;
                }
            }
        }

        /// <summary>
        ///     Recursively navigate through all menu items to attach DonorID as param on NavigateUrl of menu items
        /// </summary>
        /// <param name="donorID">Donor ID</param>
        /// <param name="menuItemCollection">Menu Item Collection</param>
        private void AppendDonorToNavigateUrlOfMenuItemsRecursively(int donorID, MenuItemCollection menuItemCollection)
        {
            if (menuItemCollection == null) throw new Exception("MenuItemCollection was not provided!");

            foreach (MenuItem item in menuItemCollection)
            {
                if (MenuItemIsPartOfAdministrationMenu(item))
                    continue; // There's no need to update NavigationURL in Administration menu items

                AppendDonorToNavigateUrlOfMenuItem(donorID, item);

                if (item.ChildItems.Count > 0) AppendDonorToNavigateUrlOfMenuItemsRecursively(donorID, item.ChildItems);
            }
        }

        /// <summary>
        ///     Attach DonorID as param on NavigateUrl of menu item
        /// </summary>
        /// <param name="donorID">Donor ID</param>
        /// <param name="menuItem">Menu Item</param>
        private void AppendDonorToNavigateUrlOfMenuItem(int donorID, MenuItem menuItem)
        {
            const string fileExtension = ".aspx";

            if (menuItem.NavigateUrl.Contains(fileExtension))
            {
                string param = "?donorID=" + donorID.ToString(CultureInfo.InvariantCulture);
                int index = menuItem.NavigateUrl.LastIndexOf(fileExtension, StringComparison.Ordinal);
                string navigateUrlWithoutParam = menuItem.NavigateUrl.Substring(0, index + fileExtension.Length);

                StringBuilder cleanCompleteNavigateUrl = new StringBuilder();
                cleanCompleteNavigateUrl.Append(navigateUrlWithoutParam);
                if (DonorID != 0)
                {
                    cleanCompleteNavigateUrl.Append(param);
                }

                menuItem.NavigateUrl = cleanCompleteNavigateUrl.ToString();
            }
        }

        /// <summary>
        ///     Check if menu item is Administration or a child of Administration
        /// </summary>
        /// <param name="menuItem"></param>
        /// <returns>true if menu item is part of Administration menu, false else</returns>
        private bool MenuItemIsPartOfAdministrationMenu(MenuItem menuItem)
        {
            if (menuItem == null) throw new Exception("MenuItem was not provided!");

            if (menuItem.Value == "Administration") return true;

            if (menuItem.Parent == null) return false;

            MenuItemIsPartOfAdministrationMenu(menuItem.Parent);

            return false;
        }

        private void SetMenuVisibilityAccordingToAuthentication()
        {
            // Only show menu items when user is authenticated
            NavigationMenu.Visible = Request.IsAuthenticated;
            lnkResetUserPassword.Visible = Request.IsAuthenticated;
            lnkLogout.Visible = Request.IsAuthenticated;

            // Display menu items according to user role when user is authenticated
            if (Request.IsAuthenticated) DisplayMenuItemsAccordingToUserRole();
        }

        /// <summary>
        /// Set definied alert messages
        /// </summary>
        internal void SetAlertMessage()
        {
            bool isAdmin = IsIncidentAdmin || IsAdmin || IsSwisstransplant;
            // Get hospital of user
            BasePage bPage = new BasePage();
            int? userHospital = (from coord in bPage.Data.Coordinator
                                 where coord.Code == bPage.User.Identity.Name
                                 select coord.HospitalID).FirstOrDefault();

            // Set Day to Day without time
            DateTime day = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day);

            // Get all visible alert to user
            var alerts = from alert in bPage.Data.IncidentAlert
                         where day >= alert.StartDate
                         where day <= alert.EndDate
                         where alert.IsDeleted == false
                         where alert.Incident.IsDeleted == false
                         where alert.Incident.IsArchived == false
                         // No closed Incidents
                         where alert.Incident.IncidentState.Value != 3
                         // Only alerts to the users hospital
                         where alert.Hospital.Count(h => h.ID == userHospital) > 0 || isAdmin
                         select alert;

            // Prepare output
            String output = String.Empty;
            String template = "<p>{1}</p>\n";

            foreach (IncidentAlert alert in alerts)
            {
                output += template.Replace("{0}", alert.Incident.IncidentNo.ToString()).Replace("{1}", alert.AlertMessage);
            }

            // Set output
            if (output != String.Empty)
            {
                litAlert.Text = output;
                alertMessage.Style["display"] = "normal"; // from hidden to normal
            }
            else
            {
                litAlert.Text = String.Empty;
                alertMessage.Style["display"] = "none"; // from normal to hidden
            }
        }
        #endregion

        // The return type can be changed to IEnumerable, however to support
        // paging and sorting, the following parameters must be added:
        //     int maximumRows
        //     int startRowIndex
        //     out int totalRowCount
        //     string sortByExpression
        public IQueryable<Pentag.SLIDS.DAL.Incident> gvSelectedDonorIncident_GetData()
        {
            if (DonorID != 0 && !Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.AAA.ToString()))
            {
                Entities data = new BasePage().Data;

                IQueryable<DAL.Coordinator> coordinator = from aspuser in data.aspnet_Users
                                                          join coord in data.Coordinator
                                                          on aspuser.UserName equals coord.Code
                                                          where aspuser.UserName == Context.User.Identity.Name
                                                          select coord;

                string hospital = string.Empty;
                if (coordinator.Count() == 1)
                {
                    if (coordinator.First().Hospital != null)
                    {
                        hospital = coordinator.First().Hospital.Name;
                    }
                }
                bool isIncidentAdmin = Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.IncidentAdmin.ToString())
                    || Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.Swisstransplant.ToString());

                string donorNumber = new DataService<DAL.Donor>(new BasePage().Data).Get(DonorID).DonorNumber;
                IQueryable<DAL.Incident> incidents = new DataService<DAL.Incident>(new BasePage().Data)
                    .GetAll()
                    .Where(i => i.DonorNumber == donorNumber && i.IsArchived == false && i.IsDeleted == false && i.OriginalID != null)
                    .Where(i => i.CreatorCenter == hospital || isIncidentAdmin);

                IQueryable <DAL.Transport> transports = new DataService<DAL.Transport>(new BasePage().Data)
                    .GetAll()
                    .Where(t => t.DonorID == DonorID && t.Arrival < t.Departure);

                if (transports.Count() > 0)
                {
                    divNegTransport.Visible = true;
                }
                else
                {
                    divNegTransport.Visible = false;
                }

                if (incidents.Count() == 0)
                {
                    pnlSelectedDonorIncident.Visible = false;
                }
                else
                {
                    pnlSelectedDonorIncident.Visible = true;
                }
                return incidents;
            }

            pnlSelectedDonorIncident.Visible = false;
            divNegTransport.Visible = false;
            return null;
        }

        protected void gvSelectedDonorIncident_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onclick"] = "window.location.href = \"IncidentOverview.aspx?IncidentId=" + ((int)gvSelectedDonorIncident.DataKeys[e.Row.RowIndex].Value).ToString() + "\"";
            }
        }
    }
}