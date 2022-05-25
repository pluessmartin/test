using Pentag.SLIDS.DAL;
using System;
using System.Net;
using System.Web;

namespace Pentag.SLIDS
{
    public partial class MailSend : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string incidentId = HttpUtility.UrlDecode(Request.QueryString["IncidentId"]);
            string incidentMailId = HttpUtility.UrlDecode(Request.QueryString["IncidentMailId"]);
            if (incidentId == null || incidentMailId == null)
            {
                throw new HttpException((Int32)HttpStatusCode.NotFound, "Page Not Found");
            }
            if (!IsPostBack)
            {
                BasePage bp = new BasePage();
                Incident incident = new DataService<Incident>(bp.Data).Get(Convert.ToInt32(incidentId));
                IncidentMail incidentMail = new DataService<IncidentMail>(bp.Data).Get(Convert.ToInt32(incidentMailId));

                if (incident == null || incidentMail == null)
                {
                    throw new HttpException((Int32)HttpStatusCode.NotFound, "Page Not Found");
                }
                txtTo.Text = incidentMail.To.Replace("{Creator}", incident.CreatorEmail);
                txtSubject.Text = incidentMail.Subject.Replace("{IncidentNumber}", incident.IncidentNo.ToString());
                txtBody.Text = incidentMail.BodyText
                    .Replace("{IncidentNumber}", incident.IncidentNo.ToString())
                    .Replace("{CorrectiveAction}", incident.CorrectiveAction);
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            BasePage bp = new BasePage();
            string incidentId = HttpUtility.UrlDecode(Request.QueryString["IncidentId"]);
            string incidentMailId = HttpUtility.UrlDecode(Request.QueryString["IncidentMailId"]);

            Incident incident = new DataService<Incident>(bp.Data).Get(Convert.ToInt32(incidentId));
            IncidentMail incidentMail = new DataService<IncidentMail>(bp.Data).Get(Convert.ToInt32(incidentMailId));

            new BasePage().SendMail(txtSubject.Text, txtBody.Text, txtTo.Text, incidentMail.ReplyTo);
            string script = "window.close();";
            ClientScript.RegisterStartupScript(GetType(), "ServerControlScript", script, true);
        }
    }
}