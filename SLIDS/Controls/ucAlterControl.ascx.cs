using System;
using System.Web.UI;

namespace Pentag.SLIDS.Controls
{
    public partial class ucAlterControl : System.Web.UI.UserControl
    {
        private string Message;

        public ucAlterControl(string message)
        {
            Message = message;
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            //window.open("http://www.w3schools.com");
            string script = "windows = window.open(\"" + Message + "\", \"Mail\", \"width=650,height=450,scrollbars=yes\");"
            + "window.focus();";
            ScriptManager.RegisterStartupScript(this, GetType(), "ServerControlScript", script, true);
        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}