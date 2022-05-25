using Pentag.SLIDS.Common;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Specialized;
using System.Linq;
using System.Timers;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using Timer = System.Timers.Timer;

namespace Pentag.SLIDS.WebAccess
{
    public partial class PasswordRecovery : BasePage
    {
        private const int TOKEN_LENGTH = 12;
        private const int RESEND_LIMIT_SEC = 30; // Can resend Email after 30 seconds
        private const string CAN_RESEND_EMAIL_STR = "CanResendEmail";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.IsPostBack) return;

            if (Session[CAN_RESEND_EMAIL_STR] == null)
            {
                Session[CAN_RESEND_EMAIL_STR] = true;
            }
        }

        protected void btnPwRecovery_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                if ((bool)Session[CAN_RESEND_EMAIL_STR])
                {
                    if (string.IsNullOrEmpty(UserName.Text))
                    {
                        FailureText.Text = "Username is needed for password recovery.";
                        return;
                    }
                    MembershipUser userInfo = Membership.GetUser(UserName.Text);

                    if (userInfo == null || string.IsNullOrEmpty(userInfo.Email))
                    {
                        FailureText.Text = "No account or e-mail has been found for this user.";
                        logger.Debug($"Missing data for user {userInfo?.ProviderUserKey}");
                        return;
                    }

                    // Generate Token and save in DB
                    string token = Crypto.GenerateToken(TOKEN_LENGTH);
                    SaveTokenToDb(token, userInfo);

                    // Generate link
                    string url = GetLinkString(userInfo.UserName, token);

                    // Send email
                    SendLink(userInfo, url);
                }
                else
                {
                    FailureText.Text = "E-mail can be re-sent shortly.";
                }
            }
        }

        private void SendLink(MembershipUser userInfo, string url)
        {

            SendMail("SLIDS Reset Password", $"Please follow this link to reset the password: {url}", userInfo.Email);
            logger.Debug($"Email with reset token sent to : {userInfo.ProviderUserKey}");
            Session[CAN_RESEND_EMAIL_STR] = false;
            Timer resendMailTimer = new Timer();
            resendMailTimer.Elapsed += new ElapsedEventHandler(OnResendMailTimerElapsed);
            resendMailTimer.Interval = RESEND_LIMIT_SEC * 1000;
            resendMailTimer.Enabled = true;

            SuccessText.Text = $"E-mail recovery has been sent to {Crypto.MaskEmail(userInfo.Email)}.";
        }

        private void OnResendMailTimerElapsed(object sender, ElapsedEventArgs e)
        {
            Session[CAN_RESEND_EMAIL_STR] = true;
        }

        private void SaveTokenToDb(string token, MembershipUser user)
        {
            DataService<PasswordResetToken> passwordResetTokens = new DataService<PasswordResetToken>(Data);

            var userTokens = passwordResetTokens.FindAll(prt => prt.UserName == user.UserName).ToList();

            foreach (var userToken in userTokens)
            {
                passwordResetTokens.Delete(userToken);
            }

            PasswordResetToken passwordResetToken = new PasswordResetToken()
            {
                Token = token,
                UserName = user.UserName,
                DateCreated = DateTime.Now
            };
            passwordResetTokens.Add(passwordResetToken);
            logger.Debug($"New reset token created for {user.ProviderUserKey}");
        }

        private string GetLinkString(string userName, string token)
        {
            NameValueCollection queryString = HttpUtility.ParseQueryString(string.Empty);
            queryString.Add("user", userName);
            queryString.Add("token", token);
            string query = ToQueryString(queryString);
            string baseUrl = Request.Url.Scheme + "://" + Request.Url.Authority +
                Request.ApplicationPath.TrimEnd('/') + "/";
            string requestPage = "WebAccess/PasswordResetWithToken.aspx";
            return $"<a href='" + baseUrl + requestPage + query + "'>Reset Password</a>";
        }

        private string ToQueryString(NameValueCollection nvc)
        {
            var array = (
                from key in nvc.AllKeys
                from value in nvc.GetValues(key)
                select string.Format(
            "{0}={1}",
            HttpUtility.UrlEncode(key),
            HttpUtility.UrlEncode(value))
                ).ToArray();
            return "?" + string.Join("&", array);
        }
    }
}