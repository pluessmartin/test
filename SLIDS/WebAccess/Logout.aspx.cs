using System;
using System.Web.Security;
using System.Web.UI;

namespace Pentag.SLIDS.WebAccess
{
    public partial class Logout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated) return;

            Session.Clear();
            FormsAuthentication.SignOut();

            // Redirect to login page
            Response.Redirect(FormsAuthentication.LoginUrl);
        }
    }
}