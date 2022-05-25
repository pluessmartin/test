using Pentag.SLIDS.DAL;
using System;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.WebAccess
{
    public partial class Login : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.IsPostBack) return;

            if (Request.IsAuthenticated && !string.IsNullOrEmpty(Request.QueryString["ReturnUrl"]))
            {
                // This is an unauthorized, authenticated request...
                Response.Redirect("~/WebAccess/UnauthorisedAccess.aspx");
            }

            // Set Focus on UserName Textbox
            LoginPanel.FindControl("myLogin").FindControl("UserName").Focus();
        }

        protected void myLogin_Authenticate(object sender, AuthenticateEventArgs e)
        {
            // Verify that the username/password pair is valid
            if (!Membership.ValidateUser(myLogin.UserName, myLogin.Password)) return;

            // Username/password are valid, set authentication
            e.Authenticated = true;
            
            // Redirect to 2FA
            Session["UserName"] = myLogin.UserName;
            Response.Redirect("~/WebAccess/Authenticate.aspx");
        }

        protected void myLogin_LoginError(object sender, EventArgs e)
        {
            // Determine why the user could not login...        
            myLogin.FailureText = "Your login attempt was not successful. Please try again.";


            // Does there exist a User account for this user?
            MembershipUser usrInfo = Membership.GetUser(myLogin.UserName);
            if (usrInfo == null) return;

            // Is this user locked out?
            if (usrInfo.IsLockedOut)
            {
                myLogin.FailureText =
                    "Your account has been locked out because of too many invalid login attempts. Please contact the administrator to have your account unlocked.";
            }
            else if (!usrInfo.IsApproved)
            {
                myLogin.FailureText =
                    "Your account has not yet been approved. You cannot login until an administrator has approved your account.";
            }
        }
    }
}