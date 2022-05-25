using System;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using Pentag.SLIDS.Common;

namespace Pentag.SLIDS
{
    public partial class ViewPDF : Page
    {
        private const string DOC_FILE_TYPE = "application/pdf";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Params["tID"] == null) return;
            byte[] doc;
            int tID = Convert.ToInt32(Request.Params["tID"]);

            if (tID != -1)
            {
                doc = Document.CreateDeliverySlip(tID);
            }
            else
            {
                doc = Document.CreateDeliverySlipBlank();
            }
            if (doc == null) return;

            // send file to user (download to browser)
            using (MemoryStream memStream = new MemoryStream())
            {
                memStream.Write(doc, 0, doc.Length);
                Response.Clear();
                Response.ContentType = DOC_FILE_TYPE;
                Response.ContentEncoding = Encoding.Default;
                Response.AppendHeader(
                    "Content-Disposition",
                    string.Format("{0};filename=\"{1}\"",
                                  (Request["dl"] != null && Request["dl"].Length > 0 ? "attachement" : "inline"),
                                  "Transport Document.pdf"));
                Response.AppendHeader("Content-Length", doc.Length.ToString(CultureInfo.InvariantCulture));
                memStream.WriteTo(Response.OutputStream);
                memStream.Flush();
            }

            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
    }
}