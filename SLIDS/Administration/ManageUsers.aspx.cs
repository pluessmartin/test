using Pentag.SLIDS.Common;
using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Web.ModelBinding;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Administration
{
    public partial class ManageUsers : BasePage
    {
        #region Properties
        protected String UserName
        {
            get { return hidUserName.Value; }
            set { hidUserName.Value = value; }
        }
        #endregion

        /// <summary>
        /// On Page loading
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Manage users called");

            if (!Page.IsPostBack)
            {
                BindRoles();
                BindDropDownLists();
                if (Master.IsAdmin)
                {
                    cbIncludeInactive.Visible = true;
                    btnActiveHandling.Visible = true;
                }
            }
        }

        /// <summary>
        /// Binding drop down lists
        /// </summary>
        private void BindDropDownLists()
        {
            // Hospital
            ddlHospital.ClearSelection();
            ddlHospital.DataSource = GetHospitals().ToList();
            ddlHospital.DataValueField = "ID";
            ddlHospital.DataTextField = "Display";
            ddlHospital.DataBind();
            ddlHospital.Items.Insert(0,
                                     new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                                  DropDownDefaultValue.DDL_DEFAULT_VALUE));
        }

        /// <summary>
        /// On changing user
        /// </summary>
        protected void gvUser_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvUser.SelectedIndex == -1 || gvUser.SelectedDataKey == null)
            {
                UserName = String.Empty;
                return;
            }

            UserName = gvUser.SelectedDataKey.Value.ToString();

            MembershipUser membershipUser = Membership.GetUser(UserName);
            if (membershipUser == null) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
            PopulateDetailView(membershipUser);
        }

        /// <summary>
        /// Resetting password
        /// </summary>
        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            Response.Redirect("ResetUserPassword.aspx?user=" + UserName);
        }

        /// <summary>
        /// Record saving
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("InputGroup");
                if (!Page.IsValid) return;

                MembershipUser membershipUser = Membership.GetUser(txtUserName.Text);
                if (membershipUser == null && hidUserName.Value == String.Empty)
                {
                    // Create new membership

                    if (txtUserName.Text.Length != txtUserName.Text.Trim().Length)
                    {
                        // Show error message
                        Master.SetInfoLabel(StatusMessages.MsgNoLeadingOrTrailingSpaces, SLIDSMaster.LabelState.Error);
                        return;
                    }

                    // Username is valid, make sure that the password does not contain the username
                    if (txtPassword.Text.IndexOf(txtUserName.Text, StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        // Show error message
                        Master.SetInfoLabel(StatusMessages.MsgUsernameInPasswordNotAllowed, SLIDSMaster.LabelState.Error);
                        return;
                    }

                    if (PasswordIsValid(txtPassword.Text))
                    {
                        membershipUser = Membership.CreateUser(txtUserName.Text, txtPassword.Text);
                        hidUserName.Value = txtUserName.Text;
                    }
                    else
                    {
                        return;
                    }
                }

                if (hidUserName.Value == String.Empty && membershipUser != null)
                {
                    // Will create user, but user allready exists
                    Master.SetInfoLabel(StatusMessages.MsgUsernameAlreadyExists, SLIDSMaster.LabelState.Error);
                    return;
                }


                SaveCoordinator(membershipUser);
                SaveDataAndRefreshGUI(membershipUser);

                // Jump to last index after adding a row
                SkipToAppropriatePageAndSelectRow(gvUser, UserName);

                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            catch (Exception ex)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);

                const string message = "Could not save membership user! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
            }
        }

        private bool PasswordIsValid(string password)
        {
            // Ensure that the password is not too long or too short
            if (password.Length > 128)
            {
                Master.SetInfoLabel("The password cannot exceed 128 characters.", SLIDSMaster.LabelState.Error);
                return false;
            }
            if (password.Length < Membership.MinRequiredPasswordLength)
            {
                Master.SetInfoLabel(
                    string.Format("The password must contain at least {0} characters.",
                                  Membership.MinRequiredPasswordLength), SLIDSMaster.LabelState.Error);
                return false;
            }

            // Determine how many non-alphanumeric characters are in the password
            int nonAlphanumericCharacters = 0;
            for (int i = 0; i < password.Length; i++)
            {
                if (!char.IsLetterOrDigit(password, i))
                    nonAlphanumericCharacters++;
            }

            if (nonAlphanumericCharacters < Membership.MinRequiredNonAlphanumericCharacters)
            {
                Master.SetInfoLabel(
                    string.Format("The password must contain at least {0} non-alphanumeric characters.",
                                  Membership.MinRequiredNonAlphanumericCharacters), SLIDSMaster.LabelState.Error);
                return false;
            }

            // Check the PasswordStrengthRegularExpression, if specified
            if (!string.IsNullOrEmpty(Membership.PasswordStrengthRegularExpression))
            {
                if (!Regex.IsMatch(password, Membership.PasswordStrengthRegularExpression))
                {
                    Master.SetInfoLabel("The password does not meet the necessary strength requirements.", SLIDSMaster.LabelState.Error);
                    return false;
                }
            }

            // If we get this far, the password is valid
            return true;
        }

        /// <summary>
        /// Saving coordinator details
        /// </summary>
        private void SaveCoordinator(MembershipUser membershipUser)
        {
            DataService<Coordinator> dsCoord = new DataService<Coordinator>(Data);
            Coordinator coord = dsCoord.Find(c => c.Code == membershipUser.UserName);
            bool userIsNcOrTc = UserIsNCorTC();
            if (userIsNcOrTc)
            {
                ucAddressControl.AssignValuesToAddress();
            }

            if (coord == null && userIsNcOrTc)
            {
                // Create new
                coord = new Coordinator()
                {
                    FirstName = txtFirstName.Text,
                    LastName = txtLastName.Text,
                    AddressID = ucAddressControl.AddressID,
                    Code = txtUserName.Text,
                    HospitalID = Convert.ToInt32(ddlHospital.SelectedValue) > 0 ? (int?)Convert.ToInt32(ddlHospital.SelectedValue) : null,
                    isActive = membershipUser.IsApproved
                };
                coord = dsCoord.Add(coord);
                hidCoordinatorID.Value = coord.ID.ToString();
            }
            else if (userIsNcOrTc)
            {
                coord = dsCoord.Get(int.Parse(hidCoordinatorID.Value));
                if (coord == null)
                {
                    throw new Exception("Coordinator not found!");
                }

                coord.FirstName = txtFirstName.Text;
                coord.LastName = txtLastName.Text;
                coord.AddressID = ucAddressControl.AddressID;
                coord.Code = txtUserName.Text;
                coord.HospitalID = int.Parse(ddlHospital.SelectedValue);
                coord.isActive = membershipUser.IsApproved;
                dsCoord.Update(coord, coord.ID);
            }
            else if (coord != null)
            {
                coord.isActive = false;
                dsCoord.Update(coord, coord.ID);
            }
        }

        /// <summary>
        ///     Delete Membership user
        /// </summary>
        /// <param name="sender">sender</param>
        /// <param name="e">EventArgs</param>
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DataService<Coordinator> dsCoord = new DataService<Coordinator>(Data);
            Coordinator coord = dsCoord.Find(c => c.Code == UserName);
            if (coord != null)
            {
                coord.isActive = false;
                dsCoord.Update(coord, coord.ID);
            }
            MembershipUser membershipUser = Membership.GetUser(UserName);
            if (membershipUser == null) return;

            Membership.DeleteUser(membershipUser.UserName);

            gvUser.SelectRow(-1);
            gvUser.DataBind();

            PopulateDetailView(null);
            pnlUserDetails.Visible = false;
        }

        #region Privates

        /// <summary>
        /// Returns grid data
        /// </summary>
        /// <returns></returns>
        public IQueryable<gridUser> gvUser_GetData([Control] string filterText)
        {
            List<gridUser> users = (from membership in Data.aspnet_Membership
                                    where cbIncludeInactive.Checked || membership.IsApproved == true
                                    select new gridUser
                                    {
                                        UserName = membership.aspnet_Users.UserName,
                                        IsLockedOut = membership.IsLockedOut,
                                        LastLoginDate = membership.LastLoginDate,
                                        Email = membership.Email,
                                        Comment = membership.Comment,
                                        IsApproved = membership.IsApproved,
                                        IsAAA = membership.aspnet_Users.aspnet_Roles.Count(t => t.LoweredRoleName == "aaa") > 0,
                                        IsAdmin = membership.aspnet_Users.aspnet_Roles.Count(t => t.LoweredRoleName == "admin") > 0,
                                        IsIncidentAdmin = membership.aspnet_Users.aspnet_Roles.Count(t => t.LoweredRoleName == "incidentadmin") > 0,
                                        IsIncidentUser = membership.aspnet_Users.aspnet_Roles.Count(t => t.LoweredRoleName == "incidentuser") > 0,
                                        IsNC = membership.aspnet_Users.aspnet_Roles.Count(t => t.LoweredRoleName == "nc") > 0,
                                        IsSwisstransplant = membership.aspnet_Users.aspnet_Roles.Count(t => t.LoweredRoleName == "swisstransplant") > 0,
                                        IsTC = membership.aspnet_Users.aspnet_Roles.Count(t => t.LoweredRoleName == "tc") > 0
                                    }).ToList();

            if (!string.IsNullOrEmpty(filterText))
            {
                users = users.Where(c =>
                    c.UserName.ContainsCaseInsensitive(filterText) ||
                    c.Email.ContainsCaseInsensitive(filterText)).ToList();
            }

            return users.AsQueryable();
        }

        /// <summary>
        /// Bind Roles and show correct grid
        /// </summary>
        private void BindRoles()
        {
            string[] allRoles = Roles.GetAllRoles();
            string[] rolesToManageByAdmin = { "Admin", "NC", "TC", "AAA", "Swisstransplant" };
            string[] rolesToManageByIncidentAdmin = { "IncidentAdmin", "IncidentUser" };
            List<string> rolesToBind = new List<string>();

            foreach (string role in allRoles)
            {
                if (Master.IsAdmin)
                {
                    if (rolesToManageByAdmin.Contains(role)) rolesToBind.Add(role);
                }

                if (Master.IsIncidentAdmin)
                {
                    if (rolesToManageByIncidentAdmin.Contains(role)) rolesToBind.Add(role);
                }
            }

            cblRoles.DataSource = allRoles;
            cblRoles.DataBind();

            foreach (ListItem item in cblRoles.Items)
            {
                if (!rolesToBind.Contains(item.Text))
                {
                    item.Enabled = false;
                }
            }
        }

        /// <summary>
        /// Populate Data
        /// </summary>
        private void PopulateDetailView(MembershipUser membershipUser)
        {
            PopulateUserDetailView(membershipUser);
            PopulateUserRoles();
            PopulateCoordinatorDetailView();
        }

        /// <summary>
        /// Populate User
        /// </summary>
        private void PopulateUserDetailView(MembershipUser membershipUser)
        {
            if (membershipUser == null)
            {
                hidCoordinatorID.Value = 0.ToString();
                txtUserName.Enabled = true;
                txtUserName.Text = String.Empty;
                txtEmail.Text = String.Empty;
                txtComment.Text = String.Empty;
                trPW.Visible = true;
                txtPassword.Text = String.Empty;
                txtPassword.Attributes.Remove("value");
                trConfirmPW.Visible = true;
                txtConfirmPassword.Text = String.Empty;
                txtConfirmPassword.Attributes.Remove("value");
                btnActiveHandling.Visible = false;
                btnResetPassword.Visible = false;
                cbIsLockedOut.Visible = false;
            }
            else
            {
                txtUserName.Enabled = false;
                txtUserName.Text = membershipUser.UserName;
                txtEmail.Text = membershipUser.Email;
                txtComment.Text = membershipUser.Comment;
                cbIsLockedOut.Checked = membershipUser.IsLockedOut;
                trPW.Visible = false;
                trConfirmPW.Visible = false;

                if (Master.IsAdmin)
                {
                    btnActiveHandling.Visible = true;
                    btnActiveHandling.Text = membershipUser.IsApproved ? "Set inactive" : "Activate";
                }
                btnResetPassword.Visible = true;
                cbIsLockedOut.Visible = true;
            }
        }

        /// <summary>
        /// Populate Coordinator
        /// </summary>
        private void PopulateCoordinatorDetailView()
        {
            if (UserIsNCorTC())
            {
                pnlCoordinator.Visible = true;
                DataService<Coordinator> coordinators = new DataService<Coordinator>(Data);
                Coordinator coord = coordinators.Find(t => t.Code == txtUserName.Text);
                if (coord != null)
                {
                    hidCoordinatorID.Value = coord.ID.ToString();
                    txtLastName.Text = coord.LastName;
                    txtFirstName.Text = coord.FirstName;
                    if (coord.HospitalID != null) ddlHospital.SelectedValue = coord.HospitalID.ToString();
                    ucAddressControl.PopulateAddressDetailView(coord.Address);
                }
            }
            else
            {
                hidCoordinatorID.Value = 0.ToString();
                txtLastName.Text = String.Empty;
                txtFirstName.Text = String.Empty;
                ddlHospital.SelectedIndex = 0;
                ucAddressControl.InitialiseAddressDetailControls();
                pnlCoordinator.Visible = false;
            }
        }

        /// <summary>
        /// Populate Roles
        /// </summary>
        private void PopulateUserRoles()
        {
            string[] rolesAllocatedToUser = Roles.GetRolesForUser(UserName);

            foreach (ListItem roleItem in cblRoles.Items)
            {
                roleItem.Selected = rolesAllocatedToUser.Contains(roleItem.Text);
            }

            List<string> excludeObj = new List<string>();
            excludeObj.Add("txtUserName");
            excludeObj.Add("btnSave");
            if (!(rolesAllocatedToUser.Contains("IncidentAdmin") || rolesAllocatedToUser.Contains("IncidentUser")) && !Master.IsAdmin)
            {
                EnableOrDisableControls(UserDetails, false, excludeObj);
            }
            else
            {
                EnableOrDisableControls(pnlUserDetails, true, excludeObj);
            }

            ShowCoordinator();
        }

        /// <summary>
        /// Saving all user datas
        /// </summary>
        private void SaveDataAndRefreshGUI(MembershipUser membershipUser)
        {
            // Update the User account information
            membershipUser.Email = txtEmail.Text.Trim();
            membershipUser.Comment = txtComment.Text.Trim();

            Membership.UpdateUser(membershipUser);

            // Unlock user in case he was locked out and Admin unckecked LockOut Checkbox
            if (membershipUser.IsLockedOut && !cbIsLockedOut.Checked) membershipUser.UnlockUser();

            SaveRolesToUser();
            gvUser.DataBind();
        }

        /// <summary>
        /// Saving the roles ofthe user
        /// </summary>
        private void SaveRolesToUser()
        {
            string[] rolesAllocatedToUser = Roles.GetRolesForUser(UserName);

            foreach (ListItem roleItem in cblRoles.Items)
            {
                // Add role to user if it's selected and not already assigned to user
                if (roleItem.Selected && !rolesAllocatedToUser.Contains(roleItem.Text))
                {
                    Roles.AddUserToRole(UserName, roleItem.Text);
                }

                // Remove role of user if it's not selected but is assigned to user
                if (!roleItem.Selected && rolesAllocatedToUser.Contains(roleItem.Text))
                {
                    Roles.RemoveUserFromRole(UserName, roleItem.Text);
                }
            }
        }

        /// <summary>
        /// Setting the visibility on buttons
        /// </summary>
        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            pnlUserDetails.Visible = true;
            btnDelete.Visible = !String.IsNullOrWhiteSpace(UserName);
            btnSave.Visible = Master.IsAdmin || Master.IsIncidentAdmin;

            pnlUserDetails.Enabled = Master.IsAdmin || Master.IsIncidentAdmin;
        }

        /// <summary>
        ///     Jumps to Page of DataGridView with given ID in GridView and select its row
        /// </summary>
        /// <param name="gv">GridView in which selection is taking part of</param>
        /// <param name="userName">Item ID in GridView</param>
        private void SkipToAppropriatePageAndSelectRow(GridView gv, String userName)
        {
            // Initialise Gridview
            gv.SelectedIndex = -1;
            gv.PageIndex = 0;
            gv.DataBind();

            for (gv.PageIndex = 0; gv.PageIndex < gv.PageCount; gv.PageIndex++)
            {
                gv.DataBind();

                for (int i = 0; i < gv.Rows.Count; i++)
                {
                    var dataKey = gv.DataKeys[i];
                    if (dataKey != null && userName != dataKey.Value.ToString()) continue;

                    gv.SelectRow(i);
                    return;
                }
            }

            // if item was not found (no exit of this method via return in loop), set Gridview unselected and hide detail view
            gv.SelectedIndex = -1;
            gv.PageIndex = 0;
            UserName = String.Empty;
            pnlUserDetails.Visible = false;
        }
        #endregion

        /// <summary>
        /// On changing user roles
        /// </summary>
        protected void cblRoles_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (txtPassword.Visible)
            {
                txtPassword.Attributes.Add("value", txtPassword.Text);
                txtConfirmPassword.Attributes.Add("value", txtConfirmPassword.Text);
            }
            ShowCoordinator();
        }

        /// <summary>
        /// Sets coordinator panel visbility
        /// </summary>
        private void ShowCoordinator()
        {
            if (Master.IsAdmin)
            {
                bool visible = UserIsNCorTC();
                if (pnlCoordinator.Visible != visible)
                {
                    pnlCoordinator.Visible = visible;
                    PopulateCoordinatorDetailView();
                }
            }
        }

        /// <summary>
        /// Returns true if the selected user is a TC or NC
        /// </summary>
        private bool UserIsNCorTC()
        {
            bool userIs = false;
            foreach (ListItem roleItem in cblRoles.Items)
            {
                if (roleItem.Selected && (roleItem.Text == "TC" || roleItem.Text == "NC"))
                {
                    userIs = true;
                }
            }
            return userIs;
        }

        /// <summary>
        /// On adding a new user
        /// </summary>
        protected void btnAddNewUser_Click(object sender, EventArgs e)
        {
            gvUser.SelectedIndex = -1;
            gvUser_SelectedIndexChanged(gvUser, new EventArgs());
            pnlUserDetails.Visible = true;
            PopulateDetailView(null);
        }

        /// <summary>
        /// Sets Coordinator active or inactive
        /// </summary>
        protected void btnActiveHandling_Click(object sender, EventArgs e)
        {
            MembershipUser membershipUser = Membership.GetUser(UserName);
            DataService<Coordinator> coords = new DataService<Coordinator>(Data);
            Coordinator coordinator = coords.Get(int.Parse(hidCoordinatorID.Value));
            if (coordinator != null)
            {
                coordinator.isActive = !membershipUser.IsApproved;
                coords.Update(coordinator, coordinator.ID);
            }

            membershipUser.IsApproved = !membershipUser.IsApproved;
            Membership.UpdateUser(membershipUser);
            PopulateDetailView(membershipUser);
            gvUser.DataBind();
            UserOverview.Update();
            Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
        }

        /// <summary>
        /// Refresh records
        /// </summary>
        protected void cbIncludeInactive_CheckedChanged(object sender, EventArgs e)
        {
            gvUser.DataBind();
        }
    }

    /// <summary>
    /// Class for grid
    /// </summary>
    public class gridUser
    {
        public string UserName { get; set; }
        public string Email { get; set; }
        public DateTime LastLoginDate { get; set; }
        public bool IsLockedOut { get; set; }
        public string Comment { get; set; }
        public bool IsApproved { get; set; }
        public bool IsAAA { get; set; }
        public bool IsAdmin { get; set; }
        public bool IsIncidentAdmin { get; set; }
        public bool IsIncidentUser { get; set; }
        public bool IsNC { get; set; }
        public bool IsSwisstransplant { get; set; }
        public bool IsTC { get; set; }
    }
}