using System;
using System.Text.RegularExpressions;
using System.Web.Security;

namespace Pentag.SLIDS.Administration
{
    public partial class ResetUserPassword : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If querystring value is missing, send the user to ManageUsers.aspx
            string userName = Request.QueryString["user"];
            if (string.IsNullOrEmpty(userName))
            {
                // Navigate back to last URL if UserName was not provided
                if (Request.UrlReferrer != null) Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                // otherwise throw exception about missing user param
                else throw new Exception("parameter user is missing!");
            }

            // Get information about this user
            MembershipUser usr = Membership.GetUser(userName);
            if (usr == null)
            {
                // Navigate back to last URL if UserName does not exist
                if (Request.UrlReferrer != null) Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                return;
            }

            UserNameLabel.Text = usr.UserName;
            CreationDateLabel.Text = usr.CreationDate.ToShortDateString();
            LastPasswordChangedDateLabel.Text = usr.LastPasswordChangedDate.ToShortDateString();
        }

        protected void UpdateUser_Click(object sender, EventArgs e)
        {
            Page.Validate("InputGroup");

            if (!Page.IsValid) return;

            // Update the user information as needed...
            string userName = Request.QueryString["user"];

            // Did the user supply a new password?
            if (NewPassword1.Text.Length <= 0) return;

            if (!ValidPassword(NewPassword1.Text)) return;

            MembershipUser membershipUser = Membership.GetUser(userName);
            if (membershipUser == null) return;

            string resetPwd = membershipUser.ResetPassword();
            membershipUser.ChangePassword(resetPwd, NewPassword1.Text);

            Master.SetInfoLabel("The password has been updated", SLIDSMaster.LabelState.Success);
            logger.Info("User successfuly updated. ID: {0}", membershipUser.UserName);
        }

        #region Privates
        private bool ValidPassword(string password)
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
                    Master.SetInfoLabel("The password does not meet the necessary strength requirements.",
                                        SLIDSMaster.LabelState.Error);
                    return false;
                }
            }

            // If we get this far, the password is valid
            return true;
        }
        #endregion
    }
}