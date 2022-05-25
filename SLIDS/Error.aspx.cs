using Pentag.SLIDS.Constants;
using System;
using System.Web.Security;

namespace Pentag.SLIDS
{
    public partial class Error : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Roles.IsUserInRole(Context.User.Identity.Name, "IncidentUser"))
                {
                    lbBackToHome.PostBackUrl = "~/IncidentCreate.aspx";
                }
                else
                {
                    lbBackToHome.PostBackUrl = "~/Search.aspx";
                }

                if (!string.IsNullOrEmpty((string)Session[SessionObjects.Message]))
                {
                    litErrorMessage.Text = (string)Session[SessionObjects.Message];
                }
            }

            showErrorDetails.Visible = !String.IsNullOrWhiteSpace(litErrorMessage.Text);
        }

        protected void showErrorDetails_Click(object sender, EventArgs e)
        {
            litErrorMessage.Visible = !litErrorMessage.Visible;
        }
    }
}