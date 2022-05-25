using System;
using System.Linq;
using System.Web.Security;
using System.Web.UI.WebControls;
using Pentag.SLIDS.Constants;

namespace Pentag.SLIDS.Administration
{
    public partial class ManageUserAndRoleAllocation : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                // Bind users and roles
                BindUsersToUserList(UserList);
                BindUsersToUserList(UserToAllocateToRoleList);
                BindRolesToRoleList();

                // Check the selected user's roles
                CheckRolesAllocatedToSelectedUser();

                // Display those users belonging to the currently selected role
                DisplayUsersAllocatedToRole();
            }
        }

        #region 'By User' Interface-Specific Methods
        protected void UserList_SelectedIndexChanged(object sender, EventArgs e)
        {
            CheckRolesAllocatedToSelectedUser();
        }

        protected void RoleAllocatedToUserCheckBox_CheckChanged(object sender, EventArgs e)
        {
            // Reference the CheckBox that raised this event
            CheckBox RoleAllocatedToUserCheckBox = sender as CheckBox;
            if (RoleAllocatedToUserCheckBox == null) return;

            if (UserList.SelectedIndex == 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSelectUsernameInDropDownList, SLIDSMaster.LabelState.Error);
                RoleAllocatedToUserCheckBox.Checked = false;
                return;
            }

            // Get the currently selected user and role
            string selectedUserName = UserList.SelectedValue;
            string roleName = RoleAllocatedToUserCheckBox.Text;

            // Determine if we need to add or remove the user from this role
            if (RoleAllocatedToUserCheckBox.Checked)
            {
                // Add the user to the role
                Roles.AddUserToRole(selectedUserName, roleName);

                // Display a status message
                Master.SetInfoLabel(string.Format("User {0} was added to role {1}.", selectedUserName, roleName),
                                    SLIDSMaster.LabelState.Success);
            }
            else
            {
                // Remove the user from the role
                Roles.RemoveUserFromRole(selectedUserName, roleName);

                // Display a status message
                Master.SetInfoLabel(string.Format("User {0} was removed to role {1}.", selectedUserName, roleName),
                                    SLIDSMaster.LabelState.Success);
            }

            // Refresh the "by role" interface
            DisplayUsersAllocatedToRole();
        }
        #endregion

        #region 'By Role' Interface-Specific Methods
        protected void RoleList_SelectedIndexChanged(object sender, EventArgs e)
        {
            DisplayUsersAllocatedToRole();
        }

        protected void UsersAllocatedToRolesList_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            // Get the selected role
            string selectedRoleName = RoleList.SelectedValue;

            // Reference the UserNameLabel
            Label UserNameLabel = UsersAllocatedToRolesList.Rows[e.RowIndex].FindControl("UserNameLabel") as Label;
            if (UserNameLabel == null) return;

            // Remove the user from the role
            Roles.RemoveUserFromRole(UserNameLabel.Text, selectedRoleName);

            // Refresh the GridView
            DisplayUsersAllocatedToRole();

            // Display a status message
            Master.SetInfoLabel(
                string.Format("User {0} was removed from role {1}.", UserNameLabel.Text, selectedRoleName),
                SLIDSMaster.LabelState.Success);

            // Refresh the "by user" interface
            CheckRolesAllocatedToSelectedUser();
        }

        protected void UserToAllocateToRoleButton_Click(object sender, EventArgs e)
        {
            // Get the selected role and username
            string selectedRoleName = RoleList.SelectedValue;
            string userNameToAllocateToRole = UserToAllocateToRoleList.SelectedValue;

            // Make sure that a value was entered
            if (RoleList.SelectedIndex == 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSelectRoleInDropDownList, SLIDSMaster.LabelState.Error);
                return;
            }

            // Make sure that a value was entered
            if (UserToAllocateToRoleList.SelectedIndex == 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSelectUsernameInDropDownList, SLIDSMaster.LabelState.Error);
                return;
            }

            // Make sure that the user doesn't already belong to this role
            if (Roles.IsUserInRole(userNameToAllocateToRole, selectedRoleName))
            {
                Master.SetInfoLabel(
                    string.Format("User {0} already is a member of role {1}.", userNameToAllocateToRole,
                                  selectedRoleName), SLIDSMaster.LabelState.Error);
                return;
            }

            // If we reach here, we need to add the user to the role
            Roles.AddUserToRole(userNameToAllocateToRole, selectedRoleName);

            // Clear out the TextBox
            //UserNameToAllocateToRole.Text = string.Empty;

            // Refresh the GridView
            DisplayUsersAllocatedToRole();

            // Display a status message
            Master.SetInfoLabel(
                string.Format("User {0} was added to role {1}.", userNameToAllocateToRole, selectedRoleName),
                SLIDSMaster.LabelState.Success);

            // Refresh the "by user" interface
            CheckRolesAllocatedToSelectedUser();
        }
        #endregion

        #region Privates
        private void BindUsersToUserList(DropDownList userlist)
        {
            // Get all user accounts
            MembershipUserCollection users = Membership.GetAllUsers();
            userlist.AppendDataBoundItems = true;
            userlist.Items.Insert(0,
                                  new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                               DropDownDefaultValue.DDL_DEFAULT_VALUE));
            userlist.DataSource = users;
            userlist.DataBind();
        }

        private void BindRolesToRoleList()
        {
            // Get all roles
            string[] roles = Roles.GetAllRoles();
            RolesAllocatedToUser.DataSource = roles;
            RolesAllocatedToUser.DataBind();

            RoleList.AppendDataBoundItems = true;
            RoleList.Items.Insert(0,
                                  new ListItem(DropDownDefaultValue.DDL_DEFAULT_TEXT,
                                               DropDownDefaultValue.DDL_DEFAULT_VALUE));
            RoleList.DataSource = roles;
            RoleList.DataBind();
        }

        private void DisplayUsersAllocatedToRole()
        {
            // Get the selected role
            string selectedRoleName = RoleList.SelectedValue;

            // Get the list of usernames that belong to the role
            if (Roles.RoleExists(selectedRoleName))
            {
                // Bind the list of users to the GridView
                UsersAllocatedToRolesList.DataSource = Roles.GetUsersInRole(selectedRoleName).ToList();
                UsersAllocatedToRolesList.DataBind();
            }
            else
            {
                UsersAllocatedToRolesList.DataSourceID = string.Empty;
                UsersAllocatedToRolesList.DataBind();
            }
        }

        private void CheckRolesAllocatedToSelectedUser()
        {
            // Determine what roles the selected user belongs to
            string selectedUserName = UserList.SelectedValue;
            string[] rolesAllocatedToUser = Roles.GetRolesForUser(selectedUserName);

            // Loop through the Repeater's Items and check or uncheck the checkbox as needed
            foreach (RepeaterItem ri in RolesAllocatedToUser.Items)
            {
                // Programmatically reference the CheckBox
                CheckBox RoleAllocatedToUserCheckBox = ri.FindControl("RoleAllocatedToUserCheckBox") as CheckBox;
                if (RoleAllocatedToUserCheckBox == null) return;

                // See if RoleCheckBox.Text is in selectedUsersRoles
                RoleAllocatedToUserCheckBox.Checked = rolesAllocatedToUser.Contains(RoleAllocatedToUserCheckBox.Text);
            }
        }
        #endregion
    }
}