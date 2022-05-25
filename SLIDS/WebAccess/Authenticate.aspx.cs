using Pentag.SLIDS.Common;
using System;
using System.Timers;
using System.Web.Security;
using System.Web.UI;
using Timer = System.Timers.Timer;

namespace Pentag.SLIDS.WebAccess
{
    public partial class Authenticate : BasePage
    {
        private const string USER_NAME_STR = "UserName";
        private const string USER_EMAIL_STR = "UserEmail";
        private const string USER_INFO_STR = "UserInfo";
        private const string TOKEN_STR = "Token";
        private const string CAN_RESEND_TOKEN_STR = "CanResendToken";
        private const string NUMBER_RETRIES_STR = "NumberRetries";

        private const int RANDOM_STRING_LENGTH = 8;
        private const int RESEND_LIMIT_SEC = 30; // Can resend Email after 30 seconds
        private const int VALIDITY_PERIOD_SEC = 300; // 5 minutes until token expires
        private const int MAX_RETRIES = 5;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.IsPostBack)
            {
                return;
            }

            if (Session[USER_NAME_STR] == null)
            {
                Response.Redirect("~/WebAccess/Login.aspx");
            }

            // Get UserInfo
            string userName = Session[USER_NAME_STR].ToString();
            MembershipUser userInfo = Membership.GetUser(userName);
            Session[USER_INFO_STR] = userInfo;
            Session[USER_EMAIL_STR] = userInfo.Email;

            // Init data
            if (Session[CAN_RESEND_TOKEN_STR] == null)
            {
                Session[CAN_RESEND_TOKEN_STR] = true;
            }
            if(Session[NUMBER_RETRIES_STR] == null)
            {
                Session[NUMBER_RETRIES_STR] = MAX_RETRIES;
            }

            // Set EmailInfo
            EmailLabel.Text = Crypto.MaskEmail(userInfo.Email);

            CreateToken();

            SendToken();
        }

        protected void btnAuthenticate_Click(object sender, EventArgs e)
        {
            FailureText.Text = "";
            if (Page.IsValid)
            {
                // Check necessary data
                if (Session[USER_NAME_STR] == null)
                {
                    Response.Redirect("~/WebAccess/Login.aspx");
                }
                if (!IsTokenValid())
                {
                    return;
                }

                VerifyToken();
            }
        }

        protected void lbResendToken_Click(object sender, EventArgs e)
        {
            FailureText.Text = "";
            if (Session[USER_NAME_STR] == null)
            {
                Response.Redirect("~/WebAccess/Login.aspx");
            }
            if (!IsTokenValid())
            {
                return;
            }
            SendToken();
        }

        private bool IsTokenValid()
        {
            if (Session[TOKEN_STR] == null || string.IsNullOrEmpty(Session[TOKEN_STR].ToString()))
            {
                Session.Remove(USER_NAME_STR);
                FailureText.Text = "The generated Token has expired.";
                return false;
            }
            return true;
        }

        private void OnTokenValidityTimerElapsed(object sender, ElapsedEventArgs e)
        {
            logger.Debug($"Token has expired for user {((MembershipUser)Session[USER_INFO_STR]).ProviderUserKey}");
            Session.Remove(TOKEN_STR);
        }

        private void OnResendTokenTimerElapsed(object sender, ElapsedEventArgs e)
        {
            Session[CAN_RESEND_TOKEN_STR] = true;
        }

        private void SendToken()
        {
            if ((bool)Session[CAN_RESEND_TOKEN_STR])
            {
                SendMail("Authentication Token SLIDS", $"Your authentication token is: {Session[TOKEN_STR]}", Session[USER_EMAIL_STR].ToString());
                logger.Debug($"Email with 2FA-token sent to {((MembershipUser)Session[USER_INFO_STR]).ProviderUserKey}");

                Session[CAN_RESEND_TOKEN_STR] = false;
                Timer resendTokenTimer = new Timer();
                resendTokenTimer.Elapsed += new ElapsedEventHandler(OnResendTokenTimerElapsed);
                resendTokenTimer.Interval = RESEND_LIMIT_SEC * 1000;
                resendTokenTimer.Enabled = true;
            }
            else
            {
                FailureText.Text = "E-mail can be re-sent shortly.";
            }
        }

        private void CreateToken()
        {
            string token = Crypto.GenerateToken(RANDOM_STRING_LENGTH);
            Session[TOKEN_STR] = token;
            Timer tokenValidityTimer = new Timer();
            tokenValidityTimer.Elapsed += new ElapsedEventHandler(OnTokenValidityTimerElapsed);
            tokenValidityTimer.Interval = VALIDITY_PERIOD_SEC * 1000;
            tokenValidityTimer.Enabled = true;
        }

        private void VerifyToken()
        {
            if (Token.Text == Session[TOKEN_STR].ToString())
            {
                // Set Cookie
                FormsAuthentication.SetAuthCookie(Session[USER_NAME_STR].ToString(), true);
                Session.Remove(TOKEN_STR);
                Session.Remove(USER_NAME_STR);
                Response.Redirect("~/Search.aspx");
            }
            else
            {
                int triesLeft = (int)Session[NUMBER_RETRIES_STR];
                triesLeft--;
                if(triesLeft <= 0)
                {
                    FailureText.Text = $"You entered the wrong token {MAX_RETRIES} times. You need to log in again.";
                    logger.Warn($"User entered the wrong 2FA-token too many times. User: {((MembershipUser)Session[USER_INFO_STR]).ProviderUserKey}");
                    Session.Remove(TOKEN_STR);
                    Session.Remove(USER_NAME_STR);
                }
                else
                {
                    Session[NUMBER_RETRIES_STR] = triesLeft;
                    FailureText.Text = $"Your entered a wrong token, please try again. {triesLeft} tries left.";
                    logger.Warn($"User entered the wrong 2FA-token. User: {((MembershipUser)Session[USER_INFO_STR]).ProviderUserKey}");
                }
            }
        }

    }
}