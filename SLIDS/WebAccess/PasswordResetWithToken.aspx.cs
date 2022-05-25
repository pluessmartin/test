using Pentag.SLIDS.DAL;
using System;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Security;
using System.Web.UI;

namespace Pentag.SLIDS.WebAccess
{
    public partial class PasswordResetWithToken : BasePage
    {
        private const int TOKEN_VALIDITY_PERIOD_MIN = 30; // Token valid for X minutes

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.IsPostBack) return;

            string userName = Request.QueryString["user"];
            string token = Request.QueryString["token"];

            IsTokenValid(token,userName);
        }

        protected void UpdateUser_Click(object sender, EventArgs e)
        {
            Page.Validate("InputGroup");

            if (!Page.IsValid) return;

            // Update the user information as needed...
            string userName = Request.QueryString["user"];
            string token = Request.QueryString["token"];

            if (!IsTokenValid(token, userName)) return;

            // Did the user supply a new password?
            if (NewPassword1.Text.Length <= 0) return;

            if (!ValidPassword(NewPassword1.Text)) return;

            MembershipUser membershipUser = Membership.GetUser(userName);
            if (membershipUser == null) return;

            string resetPwd = membershipUser.ResetPassword();
            membershipUser.ChangePassword(resetPwd, NewPassword1.Text);

            Master.SetInfoLabel("The password has been updated", SLIDSMaster.LabelState.Success);
            logger.Info("User successfuly updated. ID: {0}", membershipUser.ProviderUserKey);

            // Delete user tokens to prevent additional PW change with same link
            DeleteUserTokens(membershipUser.UserName);
        }

        #region Privates
        private void DeleteUserTokens(string userName)
        {
            DataService<PasswordResetToken> passwordResetTokens = new DataService<PasswordResetToken>(Data);

            var userTokens = passwordResetTokens.FindAll(prt => prt.UserName == userName).ToList();

            foreach (var userToken in userTokens)
            {
                passwordResetTokens.Delete(userToken);
            }
        }

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

        private bool IsTokenValid(string token, string userName)
        {
            if (string.IsNullOrEmpty(userName) || string.IsNullOrEmpty(token) || !VerifyToken(token, userName))
            {
                string userId = string.IsNullOrEmpty(userName) ? "null" : Membership.GetUser(userName).ProviderUserKey.ToString();
                Master.SetInfoLabel("The token is not valid anymore.", SLIDSMaster.LabelState.Error);
                logger.Warn("Failed password reset with token. UserName: {0}.", userId);
                btnUpdate.Visible = false;
                return false;
            };
            return true;
        }

        private bool VerifyToken(string token, string userName)
        {
            DataService<PasswordResetToken> passwordResetTokens = new DataService<PasswordResetToken>(Data);
            PasswordResetToken passwordResetToken = passwordResetTokens.Find(prt => prt.Token == token && prt.UserName == userName);
            return passwordResetToken != null && (passwordResetToken.DateCreated - DateTime.Now).TotalMinutes < TOKEN_VALIDITY_PERIOD_MIN;
        }
        #endregion
    }
}